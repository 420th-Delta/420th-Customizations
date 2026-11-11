import ast
import logging
import re
import tomllib
from collections import Counter
from collections.abc import Callable, Collection, Iterator
from contextlib import suppress
from dataclasses import dataclass
from functools import cached_property
from pathlib import Path
from typing import Self

REPO_ROOT = Path(__file__).parent.parent
with suppress(ValueError):
    REPO_ROOT = REPO_ROOT.relative_to(Path().absolute())

log = logging.getLogger(__name__)


def main() -> str | None:
    logging.basicConfig(format="{message}", style="{", level=logging.INFO)
    ctx = Context.load(REPO_ROOT, ignore_invalid_addons=True)

    total_findings = 0
    for addon in ctx.addons:
        for lint in ADDON_LINTS:
            for finding in lint(ctx, addon):
                log.warning("%s", finding)
                total_findings += 1

    for lint in PROJECT_LINTS:
        for finding in lint(ctx):
            log.warning("%s", finding)
            total_findings += 1

    if total_findings:
        return f"Found {total_findings} errors."


@dataclass(frozen=True, kw_only=True)
class Project:
    prefix: str
    mainprefix: str

    @classmethod
    def load(cls, path: Path) -> Self:
        with path.open("rb") as f:
            data = tomllib.load(f)

        return cls(prefix=data["prefix"], mainprefix=data["mainprefix"])


@dataclass(frozen=True, kw_only=True)
class Addon:
    path: Path

    @property
    def name(self) -> str:
        return self.path.name

    @property
    def pboprefix_path(self) -> Path:
        return self.path / "$PBOPREFIX$"

    @property
    def config_path(self) -> Path:
        return self.path / "config.cpp"

    @cached_property
    def pboprefix(self) -> str:
        return self.pboprefix_path.read_text("utf-8")

    @cached_property
    def config(self) -> str:
        return self.config_path.read_text("utf-8")

    @classmethod
    def load(cls, path: Path) -> Self:
        addon = cls(path=path)
        # Side effects: read mandatory files to ensure they exist
        _ = addon.pboprefix
        _ = addon.config
        return addon


@dataclass(frozen=True, kw_only=True)
class Context:
    project: Project
    addons: tuple[Addon, ...]

    @classmethod
    def load(cls, root: Path, *, ignore_invalid_addons: bool) -> Self:
        project = Project.load(root / ".hemtt" / "project.toml")

        addons: list[Addon] = []
        for path in (root / "addons").iterdir():
            try:
                addons.append(Addon.load(path))
            except FileNotFoundError as e:
                if not ignore_invalid_addons:
                    raise
                log.warning("Invalid addon: %s", e.filename)

        return cls(project=project, addons=tuple(addons))


@dataclass(frozen=True, kw_only=True)
class Finding:
    path: Path
    lineno: int | None
    message: str

    def __str__(self) -> str:
        if self.lineno is None:
            path = str(self.path)
        else:
            path = f"{self.path}:{self.lineno}"
        return f"{path:50} {self.message}"


def lint_pbo_prefix(ctx: Context, addon: Addon) -> Iterator[Finding]:
    expected = f"{ctx.project.mainprefix}\\{ctx.project.prefix}\\addons\\{addon.name}"
    if addon.pboprefix == expected + "\n":
        return
    elif addon.pboprefix.strip() == expected:
        message = f"Expected '{expected}', got extra or missing whitespace"
        yield Finding(path=addon.pboprefix_path, lineno=1, message=message)
    else:
        message = f"Expected '{expected}', got '{addon.pboprefix.strip()}'"
        yield Finding(path=addon.pboprefix_path, lineno=1, message=message)


def lint_cfgpatches_name(ctx: Context, addon: Addon) -> Iterator[Finding]:
    m = re.search(
        r"^class\s+CfgPatches\s*{(?:\n *class\s+(\S+))?",
        addon.config,
        re.MULTILINE | re.IGNORECASE,
    )
    if m is None:
        message = "Expected CfgPatches class (maybe mis-formatted?)"
        yield Finding(path=addon.config_path, lineno=None, message=message)
        return

    root_lineno = _lineno_from_content_match(addon.config, m)
    patch_lineno = root_lineno + 1
    if m[1] is None:
        message = "Expected patch class after CfgPatches"
        yield Finding(path=addon.config_path, lineno=patch_lineno, message=message)
        return

    patch_name = m[1]
    expected = f"{ctx.project.prefix}_{addon.name}"
    if patch_name != expected:
        message = f"Expected {expected}, got {patch_name}"
        yield Finding(path=addon.config_path, lineno=patch_lineno, message=message)


def _lineno_from_content_match(content: str, m: re.Match) -> int:
    return content.count("\n", 0, m.start()) + 1


def lint_decade_loadorder(ctx: Context, addon: Addon) -> Iterator[Finding]:
    try:
        required, lineno = _parse_required_addons(addon.config)
    except KeyError as e:
        yield Finding(path=addon.config_path, lineno=None, message=f"Expected {e}")
        return

    decade = "A3_Data_F_Decade_Loadorder"
    if decade not in required:
        message = f"Expected '{decade}' in requiredAddons[]"
        yield Finding(path=addon.config_path, lineno=lineno, message=message)


def _parse_required_addons(config: str) -> tuple[Collection[str], int]:
    m = re.search(
        r"^\s*requiredAddons\[\]\s*=\s*(\{[^}]+\})",
        config,
        re.MULTILINE | re.IGNORECASE,
    )
    if m is None:
        raise KeyError("requiredAddons[]")

    # Close enough
    lineno = config.count("\n", 0, m.start()) + 1
    required = re.sub(r"\s*//.+?\n", "", m[1])
    required = required.replace("{", "[").replace("}", "]")
    required = ast.literal_eval(required)

    return required, lineno


def lint_skip_when_missing(ctx: Context, addon: Addon) -> Iterator[Finding]:
    try:
        required, _ = _parse_required_addons(addon.config)
    except KeyError as e:
        yield Finding(path=addon.config_path, lineno=None, message=f"Expected {e}")
        return

    internal_prefixes = ("a3_", f"{ctx.project.prefix}_")
    external_addons = [
        req
        for req in required
        if not any(req.lower().startswith(p) for p in internal_prefixes)
    ]

    expected = int(len(external_addons) > 0)
    m = re.search(
        r"^\s*skipWhenMissingDependencies = (\d)",
        addon.config,
        re.MULTILINE | re.IGNORECASE,
    )
    if m is None:
        message = f"Expected 'skipWhenMissingDependencies = {expected}', declaration not found"
        yield Finding(path=addon.config_path, lineno=None, message=message)
        return

    lineno = _lineno_from_content_match(addon.config, m)
    value = ast.literal_eval(m[1])
    if value != expected:
        message = (
            f"Expected 'skipWhenMissingDependencies = {expected}', got '{value}' "
            f"(external addons: {', '.join(external_addons)})"
        )
        yield Finding(path=addon.config_path, lineno=lineno, message=message)


def lint_magazine_well_prefix(ctx: Context, addon: Addon) -> Iterator[Finding]:
    magwells_root = re.search(
        r"^class\s+CfgMagazineWells\s*\{(.+?)^\}",
        addon.config,
        re.DOTALL | re.MULTILINE | re.IGNORECASE,
    )
    if magwells_root is None:
        return  # class is optional

    magwells_root_body = addon.config[magwells_root.start(1) : magwells_root.end(1)]
    expected = f"{ctx.project.prefix}_{addon.name}_"
    exceptions = ("BI_akmags", "BI_links")
    for m in re.finditer(r"(\w+)\[\]\s*=\s*\{", magwells_root_body):
        if m[1].startswith(expected) or m[1] in exceptions:
            continue

        lineno = addon.config.count("\n", 0, magwells_root.start(1) + m.start()) + 1
        message = f"Expected '{expected}' prefix, got {m[1]}"
        yield Finding(path=addon.config_path, lineno=lineno, message=message)


def lint_no_tabs(ctx: Context, addon: Addon) -> Iterator[Finding]:
    i = addon.config.find("\t")
    if i >= 0:
        lineno = addon.config.count("\n", 0, i) + 1
        yield Finding(path=addon.config_path, lineno=lineno, message="No tabs allowed")


def lint_required_version(ctx: Context) -> Iterator[Finding]:
    version_lines: list[tuple[Addon, str, int]] = []
    for addon in ctx.addons:
        version, lineno = _extract_required_version(addon)
        if version is None:
            message = "Expected requiredVersion, declaration not found"
            yield Finding(path=addon.config_path, lineno=None, message=message)
            continue

        assert version is not None and lineno is not None
        version_lines.append((addon, version, lineno))

    if not version_lines:
        return

    version_counts = Counter(version for _, version, _ in version_lines)
    expected = version_counts.most_common(1)[0][0]

    mismatched_versions = (v for v in version_lines if v[1] != expected)
    for addon, version, lineno in mismatched_versions:
        message = f"Expected requiredVersion = {expected}, got '{version}'"
        yield Finding(path=addon.config_path, lineno=lineno, message=message)


def _extract_required_version(addon: Addon) -> tuple[str, int] | tuple[None, None]:
    m = re.search(
        r"^\s*requiredVersion = ([\d.]+);", addon.config, re.MULTILINE | re.IGNORECASE
    )
    if m is None:
        return None, None

    lineno = _lineno_from_content_match(addon.config, m)
    return m[1], lineno


ADDON_LINTS: list[Callable[[Context, Addon], Iterator[Finding]]] = [
    lint_pbo_prefix,
    lint_cfgpatches_name,
    lint_decade_loadorder,
    lint_skip_when_missing,
    lint_magazine_well_prefix,
    lint_no_tabs,
]
PROJECT_LINTS: list[Callable[[Context], Iterator[Finding]]] = [
    lint_required_version,
]
