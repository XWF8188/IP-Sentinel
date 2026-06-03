#!/bin/bash

# ==========================================================
# 脚本名称: install.sh (v4.3.0 Bootstrapper)
# 核心功能: 极简引导入口。负责权限校验、创建沙盒、拉取模块并启动编排器
# ==========================================================

# 1. 严格防范低权限执行
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[31m❌ 权限被拒绝: 部署 IP-Sentinel 需要最高系统权限。\033[0m"
  echo -e "💡 请切换到 root 用户 (执行 su root 或 sudo -i) 后重新运行指令。"
  exit 1
fi

# 2. 创建含高强度熵值的安全挂载点
SECURE_TMP=$(mktemp -d /tmp/ips_install.XXXXXX)
trap 'rm -rf "$SECURE_TMP"' EXIT HUP INT QUIT TERM

# 3. 定义云端仓库源 (测试期指向开发分支)
REPO_RAW_URL="https://raw.githubusercontent.com/hotyue/IP-Sentinel/feature/v4.3.0-modular"

echo -e "\n⏳ 正在拉取 IP-Sentinel v4.3.0 安装模块引擎..."

# 4. 拉取核心安装编排器 (Orchestrator)
curl -fsSL --connect-timeout 10 --retry 3 "${REPO_RAW_URL}/install/build_agent.sh" -o "${SECURE_TMP}/build_agent.sh"

if [ ! -s "${SECURE_TMP}/build_agent.sh" ]; then
    echo -e "\033[31m❌ 致命错误：核心安装引擎拉取失败！请检查网络或 GitHub 仓库地址。\033[0m"
    exit 1
fi

# 5. 转移控制权，启动安装编排流程
# 导出关键环境变量供子模块使用
export SECURE_TMP
export REPO_RAW_URL

# 赋予执行权限并以 Source 方式运行，保持在同一 Shell 进程上下文
chmod +x "${SECURE_TMP}/build_agent.sh"
source "${SECURE_TMP}/build_agent.sh"

# 安装流结束，清理沙盒将由 trap 自动处理
exit 0