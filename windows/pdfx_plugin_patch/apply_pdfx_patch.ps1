# Apply pdfx Windows CMake patch (local pdfium, VERSION, NOMINMAX).
# Run from repo root: .\windows\pdfx_plugin_patch\apply_pdfx_patch.ps1

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path

$PatchCMake = Join-Path $ScriptDir "CMakeLists.txt"
$PatchIn = Join-Path $ScriptDir "DownloadProject.CMakeLists.cmake.in"

if (-not (Test-Path $PatchCMake)) { throw "Patch file not found: $PatchCMake" }
if (-not (Test-Path $PatchIn)) { throw "Patch file not found: $PatchIn" }

# Prefer Pub cache; fallback to typical path
$PubCache = $env:LOCALAPPDATA + "\Pub\Cache\hosted\pub.dev"
$PdfxWindows = Join-Path $PubCache "pdfx-2.9.2\windows"

if (-not (Test-Path $PdfxWindows)) {
  # Try resolving via pub cache root from flutter
  $PubCacheRoot = $env:PUB_CACHE
  if (-not $PubCacheRoot) { $PubCacheRoot = Join-Path $env:LOCALAPPDATA "Pub\Cache" }
  $PdfxWindows = Join-Path $PubCacheRoot "hosted\pub.dev\pdfx-2.9.2\windows"
}
if (-not (Test-Path $PdfxWindows)) {
  Write-Host "pdfx plugin windows folder not found at: $PdfxWindows"
  Write-Host "Run 'flutter pub get' first, or set PUB_CACHE. Then run this script again."
  exit 1
}

Copy-Item -Path $PatchCMake -Destination (Join-Path $PdfxWindows "CMakeLists.txt") -Force
Copy-Item -Path $PatchIn -Destination (Join-Path $PdfxWindows "DownloadProject.CMakeLists.cmake.in") -Force
Write-Host "Patch applied to: $PdfxWindows"
Write-Host "Next: flutter clean && flutter pub get && flutter build windows"
Write-Host "Optional (if download fails): flutter build windows -- -DPDFIUM_USE_LOCAL=ON -DPDFIUM_SOURCE_DIR=C:/path/to/extracted/pdfium"
