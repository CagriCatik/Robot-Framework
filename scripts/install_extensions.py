#!/usr/bin/env python3
"""Install recommended Robot Framework extensions into VS Code-compatible editors.

Reads extension IDs from `.vscode/extensions.json` and installs them into
detected editors (VS Code, Antigravity, Cursor, Windsurf, VSCodium).
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
EXTENSIONS_FILE = REPO_ROOT / ".vscode" / "extensions.json"

# (display_name, cli_names, macos_bundle_bins)
EDITORS: list[tuple[str, list[str], list[str]]] = [
    (
        "VS Code",
        ["code"],
        ["/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"],
    ),
    (
        "Antigravity",
        ["antigravity", "antigravity-ide", "agy"],
        [
            "/Applications/Antigravity.app/Contents/Resources/app/bin/antigravity",
            "/Applications/Antigravity IDE.app/Contents/Resources/app/bin/antigravity-ide",
        ],
    ),
    (
        "Cursor",
        ["cursor"],
        ["/Applications/Cursor.app/Contents/Resources/app/bin/cursor"],
    ),
    (
        "Windsurf",
        ["windsurf"],
        ["/Applications/Windsurf.app/Contents/Resources/app/bin/windsurf"],
    ),
    (
        "VSCodium",
        ["codium"],
        ["/Applications/VSCodium.app/Contents/Resources/app/bin/codium"],
    ),
]


def load_extensions() -> list[str]:
    """Load recommended extension IDs from `.vscode/extensions.json`."""
    if not EXTENSIONS_FILE.exists():
        raise FileNotFoundError(f"Missing {EXTENSIONS_FILE}")
    data = json.loads(EXTENSIONS_FILE.read_text(encoding="utf-8"))
    return list(data.get("recommendations", []))


def find_editor_cli(cli_names: list[str], macos_bins: list[str]) -> str | None:
    """Return the first available executable path for an editor."""
    for name in cli_names:
        found = shutil.which(name)
        if found:
            return found
    if sys.platform == "darwin":
        for path in macos_bins:
            if os.path.isfile(path) and os.access(path, os.X_OK):
                return path
    return None


def discover_editors() -> dict[str, str]:
    """Return mapping of detected editor display name -> CLI path."""
    found: dict[str, str] = {}
    for label, cli_names, macos_bins in EDITORS:
        cli = find_editor_cli(cli_names, macos_bins)
        if cli:
            found[label] = cli
    return found


def install_for_editor(label: str, cli: str, extensions: list[str], dry_run: bool) -> bool:
    """Install all extensions for a single editor CLI. Returns True if all succeeded."""
    print(f"\n[{label}] Using CLI: {cli}")
    all_ok = True
    for ext in extensions:
        cmd = [cli, "--install-extension", ext]
        if dry_run:
            print(f"  (dry-run) {' '.join(cmd)}")
            continue
        print(f"  Installing {ext} ...")
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"  [OK] {ext}")
        else:
            all_ok = False
            err = (result.stderr or result.stdout).strip()
            print(f"  [FAIL] {ext}: {err}")
    return all_ok


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Install Robot Framework editor extensions from .vscode/extensions.json"
    )
    parser.add_argument(
        "--editor",
        help="Target editor name (e.g. 'VS Code', 'Antigravity', 'Cursor') or CLI name",
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="Install extensions into all detected editors",
    )
    parser.add_argument(
        "--list",
        action="store_true",
        help="List detected editors and recommended extensions without installing",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print install commands without executing them",
    )
    args = parser.parse_args()

    extensions = load_extensions()
    detected = discover_editors()

    if args.list:
        print("Recommended extensions (.vscode/extensions.json):")
        for ext in extensions:
            print(f"  - {ext}")
        print("\nDetected editors:")
        if not detected:
            print("  (none found)")
        for label, cli in detected.items():
            print(f"  - {label}: {cli}")
        return 0

    if not detected:
        print("No supported editor CLI found (code, antigravity, cursor, windsurf, codium).")
        print("Install extensions manually from .vscode/extensions.json:", ", ".join(extensions))
        return 1

    targets: dict[str, str]
    if args.editor:
        needle = args.editor.lower()
        targets = {
            k: v
            for k, v in detected.items()
            if needle in k.lower() or needle in Path(v).name.lower()
        }
        if not targets:
            print(f"Editor '{args.editor}' not found. Detected: {', '.join(detected)}")
            return 1
    elif args.all:
        targets = detected
    else:
        first_label = next(iter(detected))
        targets = {first_label: detected[first_label]}
        if len(detected) > 1:
            print(
                f"Multiple editors detected ({', '.join(detected)}). "
                f"Installing for {first_label}. Use --all to install for all."
            )

    success = True
    for label, cli in targets.items():
        if not install_for_editor(label, cli, extensions, args.dry_run):
            success = False

    return 0 if success else 1


if __name__ == "__main__":
    raise SystemExit(main())
