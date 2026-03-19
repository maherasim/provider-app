# Google Play phone screenshots: 16:9 or 9:16, 320-3840 px each side, up to 8 MB each.
# Output: 9:16 portrait (1080 x 1920 px) - standard for phone screenshots.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$assetsDir = Join-Path $root "assets"
$sources = @(
    (Join-Path $assetsDir "WhatsApp Image 2026-03-19 at 2.44.07 PM.jpeg"),
    (Join-Path $assetsDir "WhatsApp Image 2026-03-19 at 2.44.08 PM (1).jpeg"),
    (Join-Path $assetsDir "WhatsApp Image 2026-03-19 at 2.44.08 PM.jpeg")
)
$outDir = Join-Path $assetsDir "play_store_screenshots"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

# 9:16 portrait (e.g. 1080 x 1920) - within 320-3840 and under 8 MB
$targetW = 1080
$targetH = 1920

Add-Type -AssemblyName System.Drawing
$index = 1
foreach ($src in $sources) {
    if (-not (Test-Path $src)) { continue }
    $outPath = Join-Path $outDir "play_store_screenshot_$index.jpg"
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
        Write-Host "Created: play_store_screenshot_$index.jpg ($targetW x $targetH, $sizeMB MB)"
        $index++
    } finally {
        $img.Dispose()
    }
}
Write-Host "Done. Screenshots in: $outDir"
Write-Host "Upload 2-8 of these in Play Console (Store listing > Phone screenshots). 9:16, 1080x1920, under 8 MB each."
