# 420th Customizations

- Style rules and best practices: `CONTRIBUTING.md`.
- Addon metadata and formatting rules: `lints/__init__.py`; run them with
  `uv run -m lints`.
- Before finishing a change, all of these must pass: `uv run -m lints`,
  `pre-commit run --all-files`, `hemtt check`.
