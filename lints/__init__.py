import argparse
import ast
import logging
import re
import tomllib
from abc import ABC, abstractmethod
from collections import Counter
from collections.abc import Collection, Iterator
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
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--fix",
        action="store_true",
        help="Automatically fix lints if possible",
    )

    # args = parser.parse_args()
    # fix: bool = args.fix

    logging.basicConfig(format="{message}", style="{", level=logging.INFO)
    ctx = Context.load(REPO_ROOT, ignore_invalid_addons=True)

    total_findings = 0
    for addon in ctx.addons:
        for rule_cls in ADDON_RULES:
            rule = rule_cls(ctx=ctx, addon=addon)
            for finding in rule.lint():
                log.warning("%s", finding)
                total_findings += 1

    for rule_cls in PROJECT_RULES:
        rule = rule_cls(ctx=ctx)
        for finding in rule.lint():
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


class Rule(ABC):
    @abstractmethod
    def can_fix(self) -> bool:
        raise NotImplementedError

    @abstractmethod
    def fix(self) -> None:
        raise NotImplementedError

    @abstractmethod
    def lint(self) -> Iterator[Finding]:
        raise NotImplementedError


@dataclass(frozen=True, kw_only=True)
class AddonRule(Rule, ABC):
    ctx: Context
    addon: Addon


@dataclass(frozen=True, kw_only=True)
class ProjectRule(Rule, ABC):
    ctx: Context


class PboPrefixRule(AddonRule):
    def can_fix(self) -> bool:
        return True

    def fix(self) -> None:
        self.addon.pboprefix_path.write_text(self._expected_pboprefix() + "\n")

    def lint(self) -> Iterator[Finding]:
        project = self.ctx.project
        addon = self.addon

        expected = f"{project.mainprefix}\\{project.prefix}\\addons\\{addon.name}"
        if addon.pboprefix == expected + "\n":
            return
        elif addon.pboprefix.strip() == expected:
            message = f"Expected '{expected}', got extra or missing whitespace"
            yield Finding(path=addon.pboprefix_path, lineno=1, message=message)
        else:
            message = f"Expected '{expected}', got '{addon.pboprefix.strip()}'"
            yield Finding(path=addon.pboprefix_path, lineno=1, message=message)

    def _expected_pboprefix(self) -> str:
        project = self.ctx.project
        addon = self.addon
        return f"{project.mainprefix}\\{project.prefix}\\addons\\{addon.name}"


class CfgPatchesNameRule(AddonRule):
    def can_fix(self) -> bool:
        return False

    def fix(self) -> None:
        raise NotImplementedError

    def lint(self) -> Iterator[Finding]:
        project = self.ctx.project
        addon = self.addon
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
        expected = f"{project.prefix}_{addon.name}"
        if patch_name != expected:
            message = f"Expected {expected}, got {patch_name}"
            yield Finding(path=addon.config_path, lineno=patch_lineno, message=message)


def _lineno_from_content_match(content: str, m: re.Match) -> int:
    return content.count("\n", 0, m.start()) + 1


class DecadeLoadorderRule(AddonRule):
    def can_fix(self) -> bool:
        return False

    def fix(self) -> None:
        raise NotImplementedError

    def lint(self) -> Iterator[Finding]:
        addon = self.addon

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


class SkipWhenMissingRule(AddonRule):
    def can_fix(self) -> bool:
        return False

    def fix(self) -> None:
        raise NotImplementedError

    def lint(self) -> Iterator[Finding]:
        project = self.ctx.project
        addon = self.addon

        try:
            required, _ = _parse_required_addons(addon.config)
        except KeyError as e:
            yield Finding(path=addon.config_path, lineno=None, message=f"Expected {e}")
            return

        internal_prefixes = ("a3_", f"{project.prefix}_")
        external_addons = [
            req for req in required if not any(req.lower().startswith(p) for p in internal_prefixes)
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


class MagazineWellPrefixRule(AddonRule):
    def can_fix(self) -> bool:
        return False

    def fix(self) -> None:
        raise NotImplementedError

    def lint(self) -> Iterator[Finding]:
        project = self.ctx.project
        addon = self.addon

        magwells_root = re.search(
            r"^class\s+CfgMagazineWells\s*\{(.+?)^\}",
            addon.config,
            re.DOTALL | re.MULTILINE | re.IGNORECASE,
        )
        if magwells_root is None:
            return  # class is optional

        magwells_root_body = addon.config[magwells_root.start(1) : magwells_root.end(1)]
        expected = f"{project.prefix}_{addon.name}_"
        exceptions = ("BI_akmags", "BI_links")
        for m in re.finditer(r"(\w+)\[\]\s*=\s*\{", magwells_root_body):
            if m[1].startswith(expected) or m[1] in exceptions:
                continue

            lineno = addon.config.count("\n", 0, magwells_root.start(1) + m.start()) + 1
            message = f"Expected '{expected}' prefix, got {m[1]}"
            yield Finding(path=addon.config_path, lineno=lineno, message=message)


class NoTabsRule(AddonRule):
    def can_fix(self) -> bool:
        return False

    def fix(self) -> None:
        raise NotImplementedError

    def lint(self) -> Iterator[Finding]:
        addon = self.addon
        i = addon.config.find("\t")
        if i >= 0:
            lineno = addon.config.count("\n", 0, i) + 1
            yield Finding(path=addon.config_path, lineno=lineno, message="No tabs allowed")


class IndentationRule(AddonRule):
    def can_fix(self) -> bool:
        return False

    def fix(self) -> None:
        raise NotImplementedError

    def lint(self) -> Iterator[Finding]:
        addon = self.addon
        for m in re.finditer(r"^( +)", addon.config, re.MULTILINE):
            length = len(m[1])
            if length % 4 == 0:
                continue

            lineno = _lineno_from_content_match(addon.config, m)
            message = f"Expected indentation in multiples of 4, got {length}"
            yield Finding(path=addon.config_path, lineno=lineno, message=message)


class BracePlacementRule(AddonRule):
    def can_fix(self) -> bool:
        return False

    def fix(self) -> None:
        raise NotImplementedError

    def lint(self) -> Iterator[Finding]:
        addon = self.addon
        for m in re.finditer(r"^\s*\{", addon.config, re.MULTILINE):
            lineno = _lineno_from_content_match(addon.config, m)
            message = "Open brace not inline with construct"
            yield Finding(path=addon.config_path, lineno=lineno, message=message)


class SingleLineCommentSpaceRule(AddonRule):
    def can_fix(self) -> bool:
        return False

    def fix(self) -> None:
        raise NotImplementedError

    def lint(self) -> Iterator[Finding]:
        addon = self.addon
        for m in re.finditer(r"(?<!:)//(\S+)", addon.config, re.MULTILINE):
            lineno = _lineno_from_content_match(addon.config, m)
            message = f"Expected space at start of comment, got '{m[1]}'"
            yield Finding(path=addon.config_path, lineno=lineno, message=message)


class MaxLineLengthRule(AddonRule):
    def can_fix(self) -> bool:
        return False

    def fix(self) -> None:
        raise NotImplementedError

    def lint(self) -> Iterator[Finding]:
        addon = self.addon
        line_length = 100
        for m in re.finditer(rf"^(.{{{line_length + 1},}})", addon.config, re.MULTILINE):
            length = len(m[1])
            lineno = _lineno_from_content_match(addon.config, m)
            message = f"Expected line length <= 100, got {length}"
            yield Finding(path=addon.config_path, lineno=lineno, message=message)


class RequiredVersionRule(ProjectRule):
    def can_fix(self) -> bool:
        return False

    def fix(self) -> None:
        raise NotImplementedError

    def lint(self) -> Iterator[Finding]:
        version_lines: list[tuple[Addon, str, int]] = []
        for addon in self.ctx.addons:
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
    m = re.search(r"^\s*requiredVersion = ([\d.]+);", addon.config, re.MULTILINE | re.IGNORECASE)
    if m is None:
        return None, None

    lineno = _lineno_from_content_match(addon.config, m)
    return m[1], lineno


ADDON_RULES: list[type[AddonRule]] = [
    PboPrefixRule,
    CfgPatchesNameRule,
    DecadeLoadorderRule,
    SkipWhenMissingRule,
    MagazineWellPrefixRule,
    NoTabsRule,
    IndentationRule,
    BracePlacementRule,
    SingleLineCommentSpaceRule,
    MaxLineLengthRule,
]
PROJECT_RULES: list[type[ProjectRule]] = [
    RequiredVersionRule,
]
