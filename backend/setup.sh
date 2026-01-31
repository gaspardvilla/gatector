#!/bin/bash
set -e

# Clone the repository
if [ ! -d "gaze3d" ]; then
    echo "Cloning gaze3d repository..."
    git clone https://github.com/idiap/gaze3d.git
fi

# Download model weights and checkpoints
if [ ! -d "gaze3d/checkpoints" ] || [ ! -d "gaze3d/weights" ]; then
    echo "Downloading model weights..."
    cd gaze3d
    git lfs pull
    bash setup.sh
    cd ..
fi

# Symlink so demo.py's "./weights/..." resolves when run from backend/
if [ -d "gaze3d/weights" ] && [ ! -L "weights" ]; then
    ln -sf gaze3d/weights weights
fi

# Create __init__.py if it doesn't exist
if [ ! -f "gaze3d/__init__.py" ]; then
    touch gaze3d/__init__.py
fi

# Create pyproject.toml if it doesn't exist
if [ ! -f "gaze3d/pyproject.toml" ]; then
    cat > gaze3d/pyproject.toml << 'EOF'
[project]
name = "gaze3d"
version = "0.1.0"
description = "Gaze3D - 3D Gaze Estimation"
requires-python = ">=3.10"

[build-system]
requires = ["setuptools>=61"]
build-backend = "setuptools.build_meta"

[tool.setuptools.packages.find]
where = ["."]
include = ["*"]
EOF
fi

# Setup the environment (we're in backend/)
uv sync
