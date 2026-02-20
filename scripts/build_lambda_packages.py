import os
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / ".build"

def ensure_dir(p: Path):
    p.mkdir(parents=True, exist_ok=True)

def clean_build():
    if BUILD.exists():
        shutil.rmtree(BUILD)
    ensure_dir(BUILD)

def copy_tree(src: Path, dst: Path):
    if dst.exists():
        shutil.rmtree(dst)
    shutil.copytree(src, dst)

def copy_file(src: Path, dst: Path):
    ensure_dir(dst.parent)
    shutil.copy2(src, dst)

def main():
    clean_build()

    services = [
        ("catalog", ROOT / "services" / "catalog" / "handler.py"),
        ("cart",    ROOT / "services" / "cart" / "handler.py"),
        ("orders",  ROOT / "services" / "orders" / "handler.py"),
    ]

    shared_src = ROOT / "services" / "shared"
    if not shared_src.exists():
        raise FileNotFoundError(f"Missing shared folder: {shared_src}")

    for name, handler in services:
        service_root = BUILD / name
        ensure_dir(service_root / "services")

        # copy shared utils into build/services/shared
        copy_tree(shared_src, service_root / "services" / "shared")

        # copy handler.py to build/<service>/handler.py
        if not handler.exists():
            raise FileNotFoundError(f"Missing handler: {handler}")
        copy_file(handler, service_root / "handler.py")

    print(f"Build prepared at: {BUILD}")

if __name__ == "__main__":
    main()