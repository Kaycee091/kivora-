# Runs Kivora on an Android phone connected by USB, with the local email API reachable.
# Usage (from the app folder):  .\run-android.ps1
# Optional:                      .\run-android.ps1 -ApiUrl https://your-admin-domain.com
# Requires the web admin server running: cd ..\web\admin; pnpm dev
param(
    [string]$ApiUrl = "http://localhost:3000"
)

$ErrorActionPreference = "Stop"

$sdkDir = $env:ANDROID_HOME
if (-not $sdkDir) { $sdkDir = Join-Path $env:LOCALAPPDATA "Android\sdk" }
$adb = Join-Path $sdkDir "platform-tools\adb.exe"
if (-not (Test-Path $adb)) { throw "adb not found at $adb. Install Android SDK Platform-Tools." }

$device = (& $adb devices) | Select-String "\tdevice$" | Select-Object -First 1
if (-not $device) {
    throw "No authorized Android device. Enable USB debugging, plug in the phone and tap 'Allow'."
}
$serial = ($device.ToString() -split "\t")[0]
Write-Host "Using device $serial"

# Phone's localhost:3000 -> this PC's localhost:3000 (the Kivora email API).
if ($ApiUrl -like "http://localhost:*") {
    $port = ([Uri]$ApiUrl).Port
    & $adb -s $serial reverse "tcp:$port" "tcp:$port" | Out-Null
    Write-Host "Forwarded phone port $port to this PC over USB"
}

flutter run -d $serial --dart-define=KIVORA_API_URL=$ApiUrl
