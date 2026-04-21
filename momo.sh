#!/bin/bash
# Momo CLI - Build & Run Manager

PROJECT_ROOT=$(pwd)
BUILD_DIR="$PROJECT_ROOT/build"
EXE="$BUILD_DIR/MomoEditor"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

generate_resources() {
    echo -e "${BLUE}🎨 Generating QRC resources...${NC}"
    python3 gen_qrc.py
}

build_project() {
    generate_resources
    echo -e "${BLUE}🏗️  Building project...${NC}"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR" || exit
    cmake ..
    make -j$(nproc)
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Build passed!${NC}"
    else
        echo -e "${RED}❌ Build failed.${NC}"
        exit 1
    fi
}

run_project() {
    if [ -f "$EXE" ]; then
        echo -e "${GREEN}🚀 Launching Momo Editor...${NC}"
        "$EXE"
    else
        echo -e "${RED}❌ Executable not found. Please run './momo.sh build' first.${NC}"
        exit 1
    fi
}

case "$1" in
    "build")
        build_project
        ;;
    "run")
        run_project
        ;;
    "gen")
        generate_resources
        ;;
    "")
        build_project
        run_project
        ;;
    *)
        echo "Usage: ./momo.sh [build|run|gen]"
        echo "  build - Generate resources and compile"
        echo "  run   - Launch the editor"
        echo "  gen   - Only generate QRC resource file"
        echo "  (none) - Build and run"
        ;;
esac
