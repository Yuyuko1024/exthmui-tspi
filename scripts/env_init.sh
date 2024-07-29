#!/bin/bash

#------------------
# 环境初始化脚本 v1.0
# 请在刚解压完 tspi_android_sdk_repo_20240202.tar.gz 后执行本脚本
# 这将帮你一键初始化完所需的代码和环境
# 后续你可以不需要使用本脚本
#------------------

clear

echo "------------------"
echo "环境初始化脚本 v1.0"
echo "请在刚解压完 tspi_android_sdk_repo_20240202.tar.gz 后在源代码根目录执行本脚本"
echo "这将帮你一键初始化完所需的代码和环境"
echo "后续你可以不需要使用本脚本"
echo "------------------"
echo "本脚本推荐你使用Ubuntu 20.04和22.04的Linux发行版。"
echo "你可以修改脚本来跳过一些你不需要的操作"

# repo路径，默认源码自带
if [ -e "$(pwd)/.repo/repo/" ];then
    REPO_BIN=$(pwd)/.repo/repo/repo
    SRC_ROOT=$(pwd)
else
    REPO_BIN=/usr/bin/repo
fi

# 检测操作系统，本脚本需要在Ubuntu或者环境运行。
# 定义变量用于存储 ID 和 VERSION_ID
ID=""
VERSION_ID=""

# 使用 awk 读取 /etc/os-release 文件并提取 ID 和 VERSION_ID
while IFS='=' read -r key value
do
  # 移除 value 中的双引号
  value="${value%\"}"
  value="${value#\"}"

  # 检查 key 并设置对应的变量
  case $key in
    ID)
      ID="$value"
      ;;
    VERSION_ID)
      VERSION_ID="$value"
      ;;
  esac
done < /etc/os-release

# 检查 ID 是否为 debian 或 ubuntu
if [[ "$ID" != "ubuntu" ]]; then
    echo "当前系统不是Debian或者Ubuntu,退出..."
    exit 1
fi

# 检查 VERSION_ID 是否大于 20.04
if [[ "$VERSION_ID" =~ ^([0-9]+)\.([0-9]+) ]]; then
    major=${BASH_REMATCH[1]}
    minor=${BASH_REMATCH[2]}
    if (( major * 100 + minor < 2004 )); then
        echo "当前版本低于 20.04, 退出..."
        exit 1
    fi
    if (( major * 100 + minor > 2204 )); then
        echo "当前版本高于 22.04, 退出..."
        exit 1
    fi
else
    echo "无法检测版本号, 退出..."
    exit 1
fi

if [ ! -e "$(pwd)/.repo" ];then
    echo "貌似没有在源代码根目录运行脚本，退出..."
    exit 1
fi

# 安装需要的依赖
function step1()
{
    echo "------------------"
    echo "step1.安装依赖并设置"
    sudo apt update
    sudo apt -y install bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick lib32readline-dev lib32z1-dev libelf-dev liblz4-tool libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev lib32ncurses5-dev libncurses5 libncurses5-dev
    sudo apt -y install python3.10
}

# 更新repo版本
function step2()
{
    echo "------------------"
    echo "step2.更新repo版本"
    sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1
    sudo update-alternatives --set python /usr/bin/python3.10
    cd $SRC_ROOT/.repo/repo
    git remote add tuna https://mirrors.tuna.tsinghua.edu.cn/git/git-repo
    git fetch tuna main
    git merge FETCH_HEAD
}

# 检出代码
function step3()
{
    echo "------------------"
    echo "step3.检出代码"
    $REPO_BIN sync -l -j88
    cd $SRC_ROOT/kernel
    git clean -xdf
    rm -rf config test
    cd $SRC_ROOT
    $REPO_BIN forall -c "git checkout lckfb-tspi-v1.0.0"
}

step1
step2
step3