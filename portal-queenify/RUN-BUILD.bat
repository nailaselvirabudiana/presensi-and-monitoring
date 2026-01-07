@echo off
REM Build & Push Docker Image for portal-queenify (Vite React)

SET DOCKER_USERNAME=noivira124
SET IMAGE_NAME=%DOCKER_USERNAME%/portal-queenify:latest

echo ================================================
echo BUILD ^& PUSH DOCKER IMAGE (FRONTEND)
echo ================================================
echo.
echo Image: %IMAGE_NAME%
echo.

REM 1. Cek Docker
echo 1. Cek Docker berjalan...
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker tidak berjalan! Pastikan Docker Desktop sudah running.
    pause
    exit /b 1
)
echo [OK] Docker berjalan
echo.

REM 2. Login Docker Hub
echo 2. Login ke Docker Hub...
docker login
if errorlevel 1 (
    echo [ERROR] Login gagal!
    pause
    exit /b 1
)
echo [OK] Login berhasil!
echo.

REM 3. Setup buildx untuk multi-platform
echo 3. Setup Docker Buildx untuk multi-platform...
docker buildx create --name multibuilder --use 2>nul
docker buildx inspect --bootstrap
echo [OK] Buildx ready!
echo.

REM 4. Build & Push (Multi-platform: AMD64 + ARM64)
echo 4. Build dan Push image untuk AMD64 ^& ARM64...
docker buildx build --platform linux/amd64,linux/arm64 -t %IMAGE_NAME% --push .
if errorlevel 1 (
    echo [ERROR] Build gagal!
    pause
    exit /b 1
)
echo [OK] Image built ^& pushed!
echo.

REM Summary
echo ================================================
echo BUILD ^& PUSH SELESAI!
echo ================================================
echo.
echo Image: %IMAGE_NAME%
echo.
echo NEXT STEP di server:
echo    bash pull-and-run.sh
echo.
echo ================================================
pause
