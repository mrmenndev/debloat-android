$version="1.6.0"

$current = Get-Location
$root = $current #(Split-Path $current)

$files = @(
        (Join-Path $root "config"),
        (Join-Path $root "debloat.ps1")
        (Join-Path $root "download_adb.ps1"))

$output = "debloat_android_v$version.zip"

Compress-Archive -Force -Path $files -DestinationPath $output