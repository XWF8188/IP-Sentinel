#!/bin/bash

# ==========================================================
# 模块名称: build_agent.sh (v4.3.0 Orchestrator)
# 核心功能: Agent 安装业务的总指挥，负责拉取子模块并按序调用逻辑函数
# ==========================================================

# 1. 定义需要按需加载的子模块清单
MODULES=(
    "env_setup.sh"
    "ui_menu.sh"
    "net_engine.sh"
    "sys_daemon.sh"
)

echo "⏳ 正在装载底层设施依赖..."

# 2. 从云端拉取所有子模块到沙盒中
for mod in "${MODULES[@]}"; do
    curl -fsSL --connect-timeout 10 --retry 3 "${REPO_RAW_URL}/install/${mod}" -o "${SECURE_TMP}/${mod}"
    if [ ! -s "${SECURE_TMP}/${mod}" ]; then
        echo -e "\033[31m❌ 致命错误：依赖模块 [${mod}] 装载失败！\033[0m"
        exit 1
    fi
    source "${SECURE_TMP}/${mod}"
done

echo -e "\033[32m✅ 模块装载完毕，正在进入部署流程...\033[0m"

# ==========================================================
# 3. 核心业务编排流 (按原版 install.sh 的时序严格执行)
# (注：这些 do_* 函数将在对应的子模块中定义，原汁原味地保留原有逻辑)
# ==========================================================

# [模块: env_setup.sh]
do_env_precheck      # 靶机架构预检与调度器降级决策
do_fetch_version     # 解析运行态版本约束
do_install_deps      # 多分支包管理器嗅探与极简系统补全

# [模块: ui_menu.sh]
do_fetch_map         # 拉取全球节点地图
do_handle_menu       # 拦截交互菜单 / 决定是否平滑升级 / 卸载

# 如果用户选择了卸载，子模块会直接 exit，不会执行后续流程

# [模块: sys_daemon.sh]
do_clean_env         # 安装前的环境纯净度构建与幽灵进程抹除

# [模块: ui_menu.sh]
do_interactive_setup # 摘取节点信息并构建关联 / 接入 Master 司令部 (仅限全新安装)

# [模块: net_engine.sh]
do_network_probe     # 冗余网络栈探测与多出口智能嗅探
do_assemble_fallback # 智能主副容灾弹药装填 (Multi-IP Fallback)
do_write_config      # 远程拉取冷数据并解析固化配置 (仅限全新安装)
do_smooth_migrate    # 老节点数据格式迁移兼容机制 (仅限平滑升级)

# [模块: sys_daemon.sh]
do_deploy_core       # 防变砖双缓冲下载执行域 (覆写引擎)
do_inject_daemon     # Systemd 原生注入与微内核定时降级兜底

# [模块: ui_menu.sh]
do_final_report      # 部署后首播，打入中枢通信网关及指令态势传递
do_show_summary      # 打印结束横幅与开源推广

