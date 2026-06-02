# encode-orca.ps1 - encode a recording into web assets for the Orca page
# Usage: open PowerShell in this folder, then:  .\encode-orca.ps1

$IN = Read-Host "Enter the video file name (e.g. JointReactionsPlot.mp4)"

if (-not (Test-Path $IN)) {
    Write-Host "ERROR: '$IN' not found in this folder. Check the name and try again." -ForegroundColor Red
    exit 1
}

if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: ffmpeg is not on your PATH. Open a new terminal or reinstall." -ForegroundColor Red
    exit 1
}

$BASE = [System.IO.Path]::GetFileNameWithoutExtension($IN)
Write-Host "Output files will be named: $BASE.*" -ForegroundColor Cyan

New-Item -ItemType Directory -Path "media" -Force | Out-Null

Write-Host "`n[1/4] Encoding $BASE.mp4 (H.264)..." -ForegroundColor Yellow
ffmpeg -y -i $IN -vf "scale='min(1920,iw)':-2" -c:v libx264 -crf 23 -preset slow -pix_fmt yuv420p -movflags +faststart -an "media/$BASE.mp4"

Write-Host "`n[2/4] Encoding $BASE.webm (VP9 - this one is slow)..." -ForegroundColor Yellow
ffmpeg -y -i $IN -vf "scale='min(1920,iw)':-2" -c:v libvpx-vp9 -crf 33 -b:v 0 -an "media/$BASE.webm"

Write-Host "`n[3/4] Extracting $BASE.jpg (poster)..." -ForegroundColor Yellow
ffmpeg -y -ss 2 -i $IN -frames:v 1 -q:v 3 "media/$BASE.jpg"

Write-Host "`n[4/4] Encoding $BASE-preview.mp4 (5s loop)..." -ForegroundColor Yellow
ffmpeg -y -ss 2 -t 5 -i $IN -vf "scale='min(960,iw)':-2" -c:v libx264 -crf 30 -pix_fmt yuv420p -an "media/$BASE-preview.mp4"

Write-Host "`nDone. Files created in media\:" -ForegroundColor Green
Get-ChildItem "media/$BASE*" | Select-Object Name, @{Name="Size";Expression={"{0:N1} MB" -f ($_.Length/1MB)}} | Format-Table -AutoSize