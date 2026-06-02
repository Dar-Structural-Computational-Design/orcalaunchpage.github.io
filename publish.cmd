@echo off
REM Double-click to publish a Dar AppHub business-logic release to K:.
REM Reads the version from DarAppHub.csproj (bump <Version> there first).
REM Runs the .ps1 bypassing execution policy for THIS invocation only (no system change, no admin).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish-release.ps1" %*
echo.
pause
