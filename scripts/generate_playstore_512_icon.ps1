# Generate 512x512 PNG for Google Play Store (max 1 MB).
# Uses: assets\provider 36x36.png (or ic_app_logo.png as fallback)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$assetsDir = Join-Path $root "assets"
$sources = @(
    (Join-Path $assetsDir "provider 36x36.png"),
    (Join-Path $assetsDir "ic_app_logo.png"),
    (Join-Path $assetsDir "frobster Pro app logo.png")
)
$src = $null
foreach ($p in $sources) {
    if (Test-Path $p) { $src = $p; break }
}
if (-not $src) {
    Write-Error "No source image found. Add one of: provider 36x36.png, ic_app_logo.png, frobster Pro app logo.png in assets/"
    exit 1
}

$outDir = Join-Path $root "assets"
$outPath = Join-Path $outDir "play_store_icon_512.png"
Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile($src)
try {
    $bmp = New-Object System.Drawing.Bitmap(512, 512)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.DrawImage($img, 0, 0, 512, 512)
    $g.Dispose()
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    $sizeBytes = (Get-Item $outPath).Length
    $sizeKB = [math]::Round($sizeBytes / 1KB, 1)
    Write-Host "Created: $outPath (512x512, $sizeKB KB)"
    if ($sizeBytes -gt 1MB) {
        Write-Host "WARNING: File is over 1 MB. Play Store requires under 1 MB. Consider using a simpler icon or JPEG."
    } else {
        Write-Host "Ready to upload to Play Console as app icon (512x512, under 1 MB)."
    }
} finally {
    $img.Dispose()
}
