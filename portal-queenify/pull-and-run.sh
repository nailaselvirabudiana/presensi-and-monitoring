#!/bin/bash

# Pull & Run portal-queenify (Vite React)
# Jalankan di server via SSH

echo "================================================"
echo "🚀 PULL & RUN PORTAL QUEENIFY"
echo "================================================"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${YELLOW}ℹ️  $1${NC}"; }

# Config
IMAGE_NAME="noivira124/portal-queenify:latest"
CONTAINER_NAME="portal-queenify"

# 1. Cek Docker
echo "1️⃣  Cek Docker..."
if ! command -v docker &> /dev/null; then
    print_info "Docker belum terinstall. Installing..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
fi
print_success "Docker ready"

# 2. Setup environment
echo ""
echo "2️⃣  Setup environment..."
cd /www/wwwroot/portal-queenify-tst

if [ ! -f ".env" ]; then
    if [ -f ".env.production" ]; then
        cp .env.production .env
        print_success "Environment file created"
    else
        print_error ".env.production tidak ditemukan!"
        print_info "Buat file .env sesuai kebutuhan Vite. Contoh:"
        echo "VITE_API_URL=your-api-url"
        exit 1
    fi
fi
print_success "Environment ready"

# 3. Stop & remove container lama
echo ""
echo "3️⃣  Stop container lama..."
docker stop $CONTAINER_NAME 2>/dev/null
docker rm $CONTAINER_NAME 2>/dev/null
print_success "Old container removed"

# 4. Pull image
echo ""
echo "4️⃣  Pull image dari Docker Hub..."
docker pull $IMAGE_NAME
if [ $? -ne 0 ]; then
    print_error "Pull image gagal!"
    exit 1
fi
print_success "Image berhasil di-pull!"

# 5. Run container
echo ""
echo "5️⃣  Run container..."
docker run -d \
  --name $CONTAINER_NAME \
  --restart unless-stopped \
  --env-file .env \
  -e NODE_ENV=production \
  -p 3080:80 \
  $IMAGE_NAME

if [ $? -eq 0 ]; then
    print_success "Container running!"
else
    print_error "Container failed to start!"
    docker logs $CONTAINER_NAME
    exit 1
fi

# 6. Tunggu & Test
echo ""
echo "6️⃣  Testing..."
sleep 5

status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3080)
if [ "$status" == "200" ]; then
    print_success "App running (HTTP $status)"
else
    print_error "App not responding (HTTP $status)"
    docker logs $CONTAINER_NAME
fi

# Summary
echo ""
echo "================================================"
echo "🎉 DEPLOY SELESAI!"
echo "================================================"
echo ""
print_success "App: http://localhost:3080"
echo ""
print_info "Setup Reverse Proxy di aaPanel:"
echo "   /  →  http://127.0.0.1:3080"
echo ""
print_info "Perintah berguna:"
echo "   docker logs $CONTAINER_NAME"
echo "   docker restart $CONTAINER_NAME"
echo "   docker stop $CONTAINER_NAME"
echo ""
echo "================================================"
