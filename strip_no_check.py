#!/usr/bin/env python3

import sys
from pathlib import Path

def strip_directives(path: Path) -> bool:
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except Exception as e:
        print(f"❌ Load file failed: {path}  {e}")
        return False

    new_lines = [ln for ln in lines if not ln.strip().startswith("--!")]

    if new_lines == lines:
        return False

    try:
        path.write_text("\n".join(new_lines), encoding="utf-8")
        print(f"Done: {path}")
        return True
    except Exception as e:
        print(f"Write file failed: {path}  {e}")
        return False

def main(root: Path) -> None:
    files = list(root.rglob("*.luau"))
    if not files:
        print("No .luau file found")
        return
    changed = sum(strip_directives(f) for f in files)
    print(f"\nCompleted, updated {changed}/{len(files)} files")

if __name__ == "__main__":
    root_dir = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
    if not root_dir.is_dir():
        print(f"No directory found: {root_dir}")
        sys.exit(1)
    main(root_dir)