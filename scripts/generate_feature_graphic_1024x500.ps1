# Google Play Feature Graphic: PNG or JPEG, up to 15 MB, exactly 1,024 x 500 px.
# Creates one graphic per source image (3 total from the WhatsApp images you provided).
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$assetsDir = Join-Path $root "assets"
$sources = @(
    (Join-Path $assetsDir "WhatsApp Image 2026-03-19 at 2.44.07 PM.jpeg"),
    (Join-Path $assetsDir "WhatsApp Image 2026-03-19 at 2.44.08 PM (1).jpeg"),
    (Join-Path $assetsDir "WhatsApp Image 2026-03-19 at 2.44.08 PM.jpeg")
)
$targetW = 1024
$targetH = 500
$maxBytes = 15 * 1MB

Add-Type -AssemblyName System.Drawing
$encoder = [System.Drawing.Imaging.Encoder]::Quality
$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }

$index = 1
foreach ($src in $sources) {
    if (-not (Test-Path $src)) { continue }
    $outPath = Join-Path $assetsDir "play_store_feature_graphic_1024x500_$index.jpg"
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

        $quality = 90
        do {
            $eps = New-Object System.Drawing.Imaging.EncoderParameters(1)
            $eps.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($encoder, [long]$quality)
            $outBmp.Save($outPath, $codec, $eps)
            $sizeBytes = (Get-Item $outPath).Length
            if ($sizeBytes -le $maxBytes) { break }
            $quality -= 10
        } while ($quality -ge 10)
        $outBmp.Dispose()

        $sizeMB = [math]::Round($sizeBytes / 1MB, 2)
        Write-Host "Created: play_store_feature_graphic_1024x500_$index.jpg - 1024 x 500 px, $sizeMB MB"
        if ($sizeBytes -gt $maxBytes) { Write-Warning "  Over 15 MB; try a simpler source." }
        $index++
    } finally {
        $img.Dispose()
    }
}
Write-Host "Done. Three feature graphics in assets/ - use any one in Play Console (Store listing > Feature graphic)."