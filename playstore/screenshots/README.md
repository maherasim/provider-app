# Play Store Screenshots

Prepare phone and 10-inch tablet screenshots for Google Play Console.

## Requirements

| Type | Format | Size | Aspect | Dimensions |
|------|--------|------|--------|------------|
| **Phone** | PNG or JPEG | ≤ 8 MB each | 16:9 or 9:16 | 320–3,840 px per side |
| **10-inch tablet** | PNG or JPEG | ≤ 8 MB each | 16:9 or 9:16 | 1,080–7,680 px per side |

## Quick start

1. **Capture screenshots** from your app (emulator or device):
   - Android: `adb shell screencap -p /sdcard/screen.png` then pull, or use device screenshot
   - Or run the app in an emulator and capture

2. **Put raw screenshots** in the right folder:
   - Phone: `playstore/screenshots/raw/` (2–8 images)
   - Tablet: `playstore/screenshots/tablet/raw/` (up to 8 images)

3. **Run the script:**
   ```bash
   pip install -r scripts/requirements-images.txt
   python scripts/prepare_screenshots.py              # phone
   python scripts/prepare_screenshots.py --tablet     # 10-inch tablet
   ```

4. **Upload** to Play Console:
   - Phone: `playstore/screenshots/ready/` → Store listing → Phone screenshots
   - Tablet: `playstore/screenshots/tablet/ready/` → Store listing → 10-inch tablet screenshots

## Options

```bash
# Phone (default)
python scripts/prepare_screenshots.py

# 10-inch tablet (1,080–7,680 px)
python scripts/prepare_screenshots.py --tablet

# Portrait (9:16) or landscape (16:9)
python scripts/prepare_screenshots.py --aspect 9:16
python scripts/prepare_screenshots.py --tablet --aspect 16:9

# Custom size (e.g. 2560px for tablet)
python scripts/prepare_screenshots.py --tablet --target-size 2560

# Preview only (no files written)
python scripts/prepare_screenshots.py --dry-run
python scripts/prepare_screenshots.py --tablet --dry-run
```
