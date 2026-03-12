#!/usr/bin/env python3
"""
Resize and compress images to reduce Flutter app size.
Use for: assets/, android/app/src/main/res/ (drawable, mipmap).

Usage:
  pip install -r scripts/requirements-images.txt
  python scripts/optimize_images.py                    # optimize assets + android res
  python scripts/optimize_images.py --assets-only      # only assets
  python scripts/optimize_images.py --dry-run          # show what would be done
  python scripts/optimize_images.py --max-size 800     # max dimension for assets (default 1024)
  python scripts/optimize_images.py --shrink-only     # only replace when new file is smaller
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Install Pillow: pip install Pillow")
    sys.exit(1)


# Default max dimension (longest side) for images in assets
ASSETS_MAX_DIM = 1024
ASSETS_ICON_MAX_DIM = 256
# Android notification icon (24dp) in px per density: mdpi=24, hdpi=36, xhdpi=48, xxhdpi=72, xxxhdpi=96
ANDROID_NOTIFICATION_DP = 24
ANDROID_DENSITY_SCALE = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
# Max dimension for any drawable/mipmap PNG (avoid huge icons)
ANDROID_DRAWABLE_MAX_DIM = 192
# JPEG quality (1-95)
JPEG_QUALITY = 82
# PNG compression (0-9, 9 = max)
PNG_COMPRESS = 9


def get_project_root() -> Path:
    root = Path(__file__).resolve().parent.parent
    if not (root / "pubspec.yaml").exists():
        raise SystemExit("Run from provider-app root or scripts/ folder.")
    return root


def should_skip(path: Path, assets_only: bool) -> bool:
    name = path.name.lower()
    # Skip Lottie and non-image
    if path.suffix.lower() not in (".png", ".jpg", ".jpeg", ".webp"):
        return True
    if ".json" in path.parts:
        return True
    if assets_only and "android" in path.parts:
        return True
    return False


def resize_to_max(img: Image.Image, max_dim: int) -> Image.Image:
    w, h = img.size
    if w <= max_dim and h <= max_dim:
        return img
    if w >= h:
        new_w, new_h = max_dim, int(h * max_dim / w)
    else:
        new_w, new_h = int(w * max_dim / h), max_dim
    return img.resize((new_w, new_h), Image.Resampling.LANCZOS)


def optimize_image(
    path: Path,
    max_dim: int,
    jpeg_quality: int = JPEG_QUALITY,
    dry_run: bool = False,
    shrink_only: bool = False,
) -> tuple[int, int]:
    """Optimize one file: resize if needed and compress. Returns (original_bytes, new_bytes)."""
    try:
        img = Image.open(path).convert("RGBA" if path.suffix.lower() == ".png" else "RGB")
    except Exception as e:
        print(f"  Skip (open error): {path} - {e}")
        return 0, 0

    original_size = path.stat().st_size
    img = resize_to_max(img, max_dim)

    buf = Path(str(path) + ".tmp")
    try:
        if path.suffix.lower() == ".webp":
            # Re-save webp as webp with lower quality
            img.save(buf, "WEBP", quality=85, method=6)
        elif path.suffix.lower() == ".png":
            img.save(buf, "PNG", compress_level=PNG_COMPRESS, optimize=True)
        else:
            img.save(buf, "JPEG", quality=jpeg_quality, optimize=True)
        new_size = buf.stat().st_size
        if shrink_only and new_size >= original_size:
            return 0, 0  # skip: would not shrink
        if not dry_run:
            buf.replace(path)
    finally:
        try:
            if buf.exists():
                buf.unlink()
        except OSError:
            pass
    return original_size, new_size


def process_assets(root: Path, max_dim: int, dry_run: bool, shrink_only: bool = False) -> tuple[int, int]:
    total_old, total_new = 0, 0
    assets_dir = root / "assets"
    if not assets_dir.exists():
        return 0, 0

    for path in assets_dir.rglob("*"):
        if not path.is_file() or should_skip(path, False):
            continue
        # Icons and flags: smaller max dimension
        rel = path.relative_to(assets_dir)
        if rel.parts[0] in ("icons", "flag"):
            use_max = ASSETS_ICON_MAX_DIM
        else:
            use_max = max_dim
        old_b, new_b = optimize_image(path, use_max, dry_run=dry_run, shrink_only=shrink_only)
        total_old += old_b
        total_new += new_b
        if old_b or new_b:
            print(f"  {'[dry-run] ' if dry_run else ''}{path.relative_to(root)}: {old_b//1024} KB -> {new_b//1024} KB")

    return total_old, total_new


def process_android_res(root: Path, dry_run: bool, shrink_only: bool = False) -> tuple[int, int]:
    total_old, total_new = 0, 0
    res = root / "android" / "app" / "src" / "main" / "res"
    if not res.exists():
        return 0, 0

    for path in res.rglob("*.png"):
        if not path.is_file():
            continue
        # Notification icons and logos: keep small
        old_b, new_b = optimize_image(path, ANDROID_DRAWABLE_MAX_DIM, dry_run=dry_run, shrink_only=shrink_only)
        total_old += old_b
        total_new += new_b
        if old_b or new_b:
            print(f"  {'[dry-run] ' if dry_run else ''}{path.relative_to(root)}: {old_b//1024} KB -> {new_b//1024} KB")

    return total_old, total_new


def main() -> None:
    ap = argparse.ArgumentParser(description="Resize and compress images to reduce app size.")
    ap.add_argument("--assets-only", action="store_true", help="Only process assets/")
    ap.add_argument("--android-only", action="store_true", help="Only process android res/")
    ap.add_argument("--dry-run", action="store_true", help="Do not write files")
    ap.add_argument("--max-size", type=int, default=ASSETS_MAX_DIM, help=f"Max dimension for assets (default {ASSETS_MAX_DIM})")
    ap.add_argument("--shrink-only", action="store_true", help="Only replace file if new size is smaller")
    args = ap.parse_args()

    root = get_project_root()
    total_old, total_new = 0, 0

    if not args.android_only:
        print("Optimizing assets/ ...")
        o, n = process_assets(root, args.max_size, args.dry_run, args.shrink_only)
        total_old += o
        total_new += n
    if not args.assets_only:
        print("Optimizing android res/ ...")
        o, n = process_android_res(root, args.dry_run, args.shrink_only)
        total_old += o
        total_new += n

    saved = total_old - total_new
    print(f"\nTotal: {total_old // 1024} KB -> {total_new // 1024} KB (saved {saved // 1024} KB)" + (" [dry-run]" if args.dry_run else ""))


if __name__ == "__main__":
    main()
