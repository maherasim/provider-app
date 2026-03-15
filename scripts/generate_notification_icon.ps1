# Resize assets/persotel provider pro.png for Android notification icon (small sizes)
# Creates ic_stat_ic_notification.png in drawable-mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$src = Join-Path $root "assets\persotel provider pro.png"
$res = Join-Path $root "android\app\src\main\res"

if (-not (Test-Path $src)) {
    Write-Error "Source image not found: $src"
    exit 1
}

$sizes = @(
    @{ dir = "drawable-mdpi";   size = 24 },
    @{ dir = "drawable-hdpi";   size = 36 },
    @{ dir = "drawable-xhdpi";  size = 48 },
    @{ dir = "drawable-xxhdpi"; size = 72 },
    @{ dir = "drawable-xxxhdpi"; size = 96 }
)

Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile($src)
try {
    foreach ($s in $sizes) {
        $dir = Join-Path $res $s.dir
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        $out = Join-Path $dir "ic_stat_ic_notification.png"
        $bmp = New-Object System.Drawing.Bitmap($s.size, $s.size)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.DrawImage($img, 0, 0, $s.size, $s.size)
        $g.Dispose()
        $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()
        Write-Host "Created $out ($($s.size)x$($s.size))"
    }
} finally {
    $img.Dispose()
}
Write-Host "Done. Notification icon drawables created."
