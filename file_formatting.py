import re
from pathlib import Path

for file in Path(".").rglob("*.luau"):
    try:
        text = file.read_text(encoding="utf-8")
        text = re.sub(r'\n{3,}', '\n\n', text)
        file.write_text(text, encoding="utf-8")
        print(f"✓ {file}")
    except Exception as e:
        print(f"✗ {file}: {e}")
