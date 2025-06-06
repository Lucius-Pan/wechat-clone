#!/bin/bash

# 配置颜色
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# 提示函数
log_success() {
    echo -e "${GREEN}[success]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[warn]${NC} $1"
}

log_error() {
    echo -e "${RED}[error]${NC} $1"
}

# 设置路径
ORIGINAL_APP="/Applications/WeChat.app"
CLONE_APP="/Applications/WeXin.app"

# Step 0: 检查原始 WeChat 是否存在
if [ ! -d "$ORIGINAL_APP" ]; then
    log_error "未找到原始 WeChat 应用，请确认是否已安装。"
    exit 1
fi
log_success "检测到原始 WeChat 应用，开始进行微信双开操作..."

# Step 1: 复制 WeChat 应用为 WeXin
if [ -d "$CLONE_APP" ]; then
    log_warn "发现已有 WeXin.app，将覆盖原有副本..."
    sudo rm -rf "$CLONE_APP"
fi

log_warn "正在复制 WeChat.app 到 WeXin.app..."
if sudo cp -R "$ORIGINAL_APP" "$CLONE_APP"; then
    log_success "复制成功：WeChat → WeXin"
else
    log_error "复制失败，请检查权限或磁盘空间。"
    exit 1
fi

# Step 2: 修改 Info.plist 的 Bundle Identifier
log_warn "正在修改 Info.plist Bundle Identifier..."
if sudo /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.tencent.WeXin" "$CLONE_APP/Contents/Info.plist"; then
    log_success "Bundle Identifier 修改成功。"
else
    log_error "修改 Bundle Identifier 失败。"
    exit 1
fi

# Step 3: 对分身 WeXin.app 进行签名
log_warn "正在对 WeXin.app 进行签名..."
if sudo codesign --force --deep --sign - "$CLONE_APP"; then
    log_success "签名成功，WeXin.app 可正常运行。"
else
    log_error "签名失败，可能导致无法打开应用。"
    exit 1
fi

log_success "全部完成！你现在可以在 Launchpad 中看到 WeChat 和 WeXin，支持微信双开。"

