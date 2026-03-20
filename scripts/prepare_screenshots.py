#!/usr/bin/env python3
"""
Prepare screenshots for Google Play Store upload.

Phone: 2-8 screenshots, 320-3,840 px per side, 16:9 or 9:16
Tablet (10"): up to 8 screenshots, 1,080-7,680 px per side, 16:9 or 9:16

Usage:
  pip install -r scripts/requirements-images.txt
  python scripts/prepare_screenshots.py                     # phone: raw/ -> ready/
  python scripts/prepare_screenshots.py --tablet            # tablet: tablet/raw/ -> tablet/ready/
  python scripts/prepare_screenshots.py --aspect 9:16       # portrait (default)
  python scripts/prepare_screenshots.py --aspect 16:9       # landscape
  python scripts/prepare_screenshots.py --target-size 1080  # longest side in px
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


# Play Store limits
PHONE_MIN, PHONE_MAX = 320, 3840
TABLET_MIN, TABLET_MAX = 1080, 7680
MAX_BYTES = 8 * 1024 * 1024  # 8 MB
SUPPORTED = (".png", ".jpg", ".jpeg")
JPEG_QUALITY = 90


def get_project_root() -> Path:
    root = Path(__file__).resolve().parent.parent
    if not (root / "pubspec.yaml").exists():
        raise SystemExit("Run from provider-app root.")
    return root


def parse_aspect(s: str) -> tuple[int, int]:
    """Parse '16:9' or '9:16' -> (w, h)."""
    parts = s.strip().split(":")
    if len(parts) != 2:
        raise ValueError(f"Invalid aspect ratio: {s}")
    w, h = int(parts[0]), int(parts[1])
    if w < 1 or h < 1:
        raise ValueError(f"Invalid aspect ratio: {s}")
    return w, h


def fit_to_aspect(img: Image.Image, aspect_w: int, aspect_h: int) -> Image.Image:
    """Crop and resize to exact aspect ratio (cover: fill target, crop excess)."""
    w, h = img.size
    target_ratio = aspect_w / aspect_h
    current_ratio = w / h

    if current_ratio > target_ratio:
        # Too wide: crop sides
        new_w = int(h * target_ratio)
        left = (w - new_w) // 2
        img = img.crop((left, 0, left + new_w, h))
    else:
        # Too tall: crop top/bottom
        new_h = int(w / target_ratio)
        top = (h - new_h) // 2
        img = img.crop((0, top, w, top + new_h))

    return img


def clamp_dimensions(
    w: int, h: int, target_longest: int, min_side: int, max_side: int
) -> tuple[int, int]:
    """Scale so longest side = target_longest, but keep within min/max."""
    longest = max(w, h)
    if longest <= 0:
        return w, h
    scale = target_longest / longest
    new_w = max(min_side, min(max_side, int(round(w * scale))))
    new_h = max(min_side, min(max_side, int(round(h * scale))))
    return new_w, new_h


def process_one(
    path: Path,
    out_dir: Path,
    aspect_w: int,
    aspect_h: int,
    target_longest: int,
    min_side: int,
    max_side: int,
    dry_run: bool,
) -> bool:
    """Process one screenshot. Returns True if successful."""
    try:
        img = Image.open(path).convert("RGB")
    except Exception as e:
        print(f"  Skip (open error): {path} - {e}")
        return False

    img = fit_to_aspect(img, aspect_w, aspect_h)
    w, h = img.size
    new_w, new_h = clamp_dimensions(w, h, target_longest, min_side, max_side)
    img = img.resize((new_w, new_h), Image.Resampling.LANCZOS)

    out_name = path.stem + ".png"
    out_path = out_dir / out_name

    if not dry_run:
        img.save(out_path, "PNG", optimize=True, compress_level=6)
        size = out_path.stat().st_size
        if size > MAX_BYTES:
            # Fallback to JPEG if PNG too large
            out_path_jpg = out_dir / (path.stem + ".jpg")
            img.save(out_path_jpg, "JPEG", quality=JPEG_QUALITY, optimize=True)
            out_path.unlink(missing_ok=True)
            out_path = out_path_jpg
            size = out_path.stat().st_size
        if size > MAX_BYTES:
            print(f"  WARNING: {out_path.name} is {size // 1024} KB (max 8 MB)")
    else:
        size = 0  # estimate
        out_name = out_path.name

    print(f"  {'[dry-run] ' if dry_run else ''}{path.name} -> {out_name} ({new_w}x{new_h})")
    return True


def main() -> None:
    ap = argparse.ArgumentParser(description="Prepare Play Store screenshots (16:9 or 9:16).")
    ap.add_argument("--tablet", action="store_true", help="10-inch tablet mode (1,080-7,680 px)")
    ap.add_argument("--aspect", default="9:16", help="Aspect ratio: 9:16 (portrait) or 16:9 (landscape)")
    ap.add_argument("--target-size", type=int, help="Longest side in px (default: 1080 phone, 1920 tablet)")
    ap.add_argument("--dry-run", action="store_true", help="Do not write files")
    ap.add_argument("--input", type=Path, help="Input folder")
    ap.add_argument("--output", type=Path, help="Output folder")
    args = ap.parse_args()

    root = get_project_root()
    is_tablet = args.tablet
    min_side, max_side = (TABLET_MIN, TABLET_MAX) if is_tablet else (PHONE_MIN, PHONE_MAX)

    if args.input and args.output:
        raw, ready = args.input, args.output
    elif is_tablet:
        raw = root / "playstore" / "screenshots" / "tablet" / "raw"
        ready = root / "playstore" / "screenshots" / "tablet" / "ready"
    else:
        raw = root / "playstore" / "screenshots" / "raw"
        ready = root / "playstore" / "screenshots" / "ready"

    target = args.target_size or (1920 if is_tablet else 1080)
    target = max(min_side, min(max_side, target))

    if not raw.exists():
        print(f"Input folder not found: {raw}")
        print("Create it and add 2-8 PNG/JPEG screenshots, then run this script.")
        sys.exit(1)

    ready.mkdir(parents=True, exist_ok=True)
    aspect_w, aspect_h = parse_aspect(args.aspect)

    files = sorted(p for p in raw.iterdir() if p.is_file() and p.suffix.lower() in SUPPORTED)
    if not files:
        print(f"No PNG/JPEG files in {raw}")
        sys.exit(1)

    if len(files) > 8:
        print(f"Found {len(files)} images. Play Store accepts up to 8. Using first 8.")
        files = files[:8]

    device = "10-inch tablet" if is_tablet else "phone"
    print(f"Processing {len(files)} {device} screenshot(s) -> {ready}")
    print(f"Aspect: {aspect_w}:{aspect_h}, target longest side: {target}px ({min_side}-{max_side})")
    for path in files:
        process_one(path, ready, aspect_w, aspect_h, target, min_side, max_side, args.dry_run)
    print(f"Done. Upload from {ready} to Play Console -> {device} screenshots.")


if __name__ == "__main__":
    main()
