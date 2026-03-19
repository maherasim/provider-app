# Google Play 10-inch tablet screenshots: 16:9 or 9:16, each side 1,080–7,680 px, up to 8 MB each.
# Output: 9:16 portrait (1620 x 2880 px) - within 1080–7680 and under 8 MB.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$assetsDir = Join-Path $root "assets"
$sources = @(
    (Join-Path $assetsDir "WhatsApp Image 2026-03-19 at 2.44.07 PM.jpeg"),
    (Join-Path $assetsDir "WhatsApp Image 2026-03-19 at 2.44.08 PM (1).jpeg"),
    (Join-Path $assetsDir "WhatsApp Image 2026-03-19 at 2.44.08 PM.jpeg")
)
$outDir = Join-Path $assetsDir "play_store_screenshots_10inch"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

# 9:16 portrait; both sides in [1080, 7680]
$targetW = 1620
$targetH = 2880

Add-Type -AssemblyName System.Drawing
$index = 1
foreach ($src in $sources) {
    if (-not (Test-Path $src)) { continue }
    $outPath = Join-Path $outDir "play_store_10inch_screenshot_$index.jpg"
    $img = [System.Drawing.Image]::FromFile($src)
    try {
        $srcW = $img.Width
        $srcH = $img.Height
        $scale = [Math]::Max($targetW / $srcW, $targetH / $srcH)
        $scaledW = [int]([Math]::Round($srcW * $scale))
        $scaledH = [int]([Math]::Round($srcH * $scale))
        $srcRect = [System.Drawing.Rectangle]::new(0, 0, $srcW, $srcH)
        $destRect = [System.Drawing.Rectangle]::new(0, 0, $scaledW, $scaledH)
        $bmpScale = New-Object System.Drawing.Bitmap($scaledW, $scaledH)
        $gScale = [System.Drawing.Graphics]::FromImage($bmpScale)
        $gScale.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $gScale.DrawImage($img, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
        $gScale.Dispose()
        $x = [Math]::Max(0, ($scaledW - $targetW) / 2)
        $y = [Math]::Max(0, ($scaledH - $targetH) / 2)
        $cropRect = [System.Drawing.Rectangle]::new([int]$x, [int]$y, $targetW, $targetH)
        $outBmp = $bmpScale.Clone($cropRect, $bmpScale.PixelFormat)
        $bmpScale.Dispose()
        $outBmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
        $outBmp.Dispose()
        $sizeBytes = (Get-Item $outPath).Length
        $sizeMB = [math]::Round($sizeBytes / 1MB, 2)
        Write-Host "Created: play_store_10inch_screenshot_$index.jpg ($targetW x $targetH, $sizeMB MB)"
        $index++
    } finally {
        $img.Dispose()
    }
}
Write-Host "Done. 10-inch tablet screenshots in: $outDir"
Write-Host "Upload up to 8 in Play Console (Store listing > 10-inch tablet screenshots). 9:16, 1620x2880, 1080-7680 px, under 8 MB each."
