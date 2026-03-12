# Image optimization (reduce app size)

This script resizes and compresses PNG/JPEG/WebP images in `assets/` and `android/app/src/main/res/` to reduce APK size.

## Setup

```bash
pip install -r scripts/requirements-images.txt
```

## Run

From project root (`provider-app/`):

```bash
# Preview only (no files changed)
python scripts/optimize_images.py --dry-run

# Optimize assets + Android res
python scripts/optimize_images.py

# Only assets
python scripts/optimize_images.py --assets-only

# Only Android drawable/mipmap
python scripts/optimize_images.py --android-only

# Stricter max size for assets (e.g. 800px)
python scripts/optimize_images.py --max-size 800

# Only replace when the new file is smaller (avoids a few icons growing)
python scripts/optimize_images.py --shrink-only
```

## What it does

- **Assets**: Icons/flags max 256px, other images max 1024px (or `--max-size`). PNGs compressed; JPEGs saved at quality 82.
- **Android res**: All PNGs in `res/` limited to 192px max dimension and compressed (fixes oversized notification icons etc.).

After running, rebuild the app to see the smaller size.
