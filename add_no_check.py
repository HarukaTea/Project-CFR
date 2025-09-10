#!/usr/bin/env python3
"""
批量修正 .luau 文件：
1. 先清除所有指令行（--!strict / --!nocheck / --!nolint LocalUnused / --!nolint LocalShadow）
2. 在顶部重新写入固定三行
用法: python fix_luau.py [项目根目录，默认当前目录]
"""
import sys
from pathlib import Path

# 需要被清理的“整行”集合（strip 后精确匹配）
REMOVE_LINES = {
    "--!strict",
    "--!nocheck",
    "--!nolint LocalUnused",
    "--!nolint LocalShadow",
    "--!nolint SameLineStatement",
    "--!nolint ImplicitReturn"
}

HEAD_LINES = [
    "--!nocheck",
    "--!nolint LocalUnused",
    "--!nolint LocalShadow",
    "--!nolint SameLineStatement",
    "--!nolint ImplicitReturn"
]

def process_file(path: Path) -> bool:
    """返回是否做了修改"""
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except Exception as e:
        print(f"❌ 读取失败: {path}  {e}")
        return False

    # 1. 删除所有指令行
    lines = [ln for ln in lines if ln.strip() not in REMOVE_LINES]

    # 2. 去掉顶部连续空行
    while lines and lines[0].strip() == "":
        lines.pop(0)

    # 3. 组装：三行 + 1 空行 + 剩余内容
    final_lines = HEAD_LINES + [""] + lines

    # 如果内容没变，跳过写入
    if final_lines == path.read_text(encoding="utf-8").splitlines():
        return False

    try:
        path.write_text("\n".join(final_lines), encoding="utf-8")
        print(f"✅ 已更新: {path}")
        return True
    except Exception as e:
        print(f"❌ 写入失败: {path}  {e}")
        return False

def main(root_dir: Path) -> None:
    luau_files = list(root_dir.rglob("*.luau"))
    if not luau_files:
        print("未找到任何 .luau 文件")
        return

    changed = sum(process_file(f) for f in luau_files)
    print(f"\n处理完成，共更新 {changed}/{len(luau_files)} 个文件")

if __name__ == "__main__":
    project_root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
    if not project_root.is_dir():
        print(f"目录不存在: {project_root}")
        sys.exit(1)
    main(project_root)