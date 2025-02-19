#!/bin/bash

echo "若需要获取命令帮助，请输入 vendor_usage 命令。"
echo "For extra command help, please use vendor_usage to show help."

# ---------------------------
# local variable
SRC_TOP=$(gettop)
BUILD_JOBS=$(grep processor /proc/cpuinfo | awk '{field=$NF};END{print field+1}')

# uboot config
UBOOT_DIR=$SRC_TOP/u-boot
UBOOT_TARGET="rk3566"

# kernel config
KERNEL_DIR=$SRC_TOP/kernel
if [ $SHELL = "/usr/bin/zsh" ];then
    KERNEL_CFG=(tspi_defconfig rk356x_evb.config android-11.config)
else
    KERNEL_CFG="tspi_defconfig rk356x_evb.config android-11.config"
fi
KERNEL_ARCH="arm64"
KERNEL_DTS="tspi-rk3566-user-v10"

# android config
ANDROID_PRODUCT="rk3566_tspi"
ANDROID_VARIANT="userdebug"


# --------------------
# 脚本私有方法
function cmd_msg()
{
    local ncolors=$(tput colors 2>/dev/null)
    if [ -n "$ncolors" ] && [ $ncolors -ge 8 ]; then
        color_failed=$'\E'"[0;31m"
        color_success=$'\E'"[0;32m"
        color_reset=$'\E'"[00m"
    else
        color_failed=""
        color_success=""
        color_reset=""
    fi
    local caller_function=${FUNCNAME[1]}
    if [ $1 = 0 ];then
        echo
        echo -n "${color_success}#### ok: 步骤 $caller_function 完成！"
        echo
    else
        echo
        echo -n "${color_failed}#### error: 步骤 $caller_function 出错！"
        echo
    fi
    echo "${color_reset}"
}

# --------------------
# 脚本公用方法
function vendor_usage()
{
    echo "----------------------------------"
    echo "额外 vendor 命令帮助"
    echo "notice: [arg]表示该命令只能接受0或者1个参数。"
    echo "[arg1] [arg2]表示该命令可接受0到2个参数, 且参数前同样为该标志表示该命令可以无视排序。"
    echo "             但是当参数前有 1- 或者 2- 时, 代表该列参数只能选择其中一个作为命令其中的一个参数。"
    echo
    echo "go_top: 回到 SDK 根目录"
    echo
    echo "cout: 进入构建输出目录"
    echo
    echo "build_uboot [arg]: 编译 SDK 中的 u-boot 镜像"
    echo "    [arg] 参数： clean: 等效于 make clean, 编译前步骤。"
    echo "          mrproper: 等效于 make mrproper"
    echo "          distclean: 等效于 make distclean"
    echo "          allclean: 同时运行上述三个参数"
    echo
    echo "build_kernel [arg1] [arg2]: 编译 SDK 中的 kernel 镜像"
    echo "    参数： 1- [arg1] [arg2] clean: 等效于 make clean, 编译前步骤。"
    echo "          1- [arg1] [arg2] mrproper: 等效于 make mrproper"
    echo "          1- [arg1] [arg2] allclean: 同时运行上述三个参数"
    echo "          [arg1] [arg2] clang: 编译时使用 SDK 自带 clang"
    echo
    echo "build_android [arg]: 编译 SDK 中的 Android 操作系统"
    echo "    [arg] 参数： allclean: 等效于 make clean, 编译前全清理步骤。"
    echo "          insclean: 等效于 make installclean, 编译前只清理构建输出步骤。"
    echo
    echo "build_all [arg1] [arg2]: 编译上面所有三个步骤的构建输出"
    echo "    参数： 1- [arg1] [arg2] clean: 等效于 make clean, 编译前步骤。"
    echo "          1- [arg1] [arg2] allclean: 等效于 make clean, 编译前全清理步骤。"
    echo "          [arg1] [arg2] clang: 编译时使用 SDK 自带 clang"
    echo
    echo "make_rkimg: 打包rockchip镜像和parameter"
    echo
    echo "make_update_img: 打包 update.img 刷机固件（需要先lunch指定的config）"
    echo
    echo "clean_build [arg1] [arg2]: 清理目标构建输出"
    echo "    参数： 1- [arg1] 要清理的目标，有 uboot, kernel, android"
    echo "          2- [arg2] 要清理的等级，清理等级参照上面命令参数"
    echo "----------------------------------"
}

function go_top()
{
    [ -d "$SRC_TOP" ] || { echo "无法找到 SRC_TOP 目录。"; }
    cd "$SRC_TOP"
}

function cout()
{
    if [ -z "$OUT" ]; then
        echo "无法定位 out 目录，请尝试构建或设定 OUT 路径."
        return 1
    elif [ ! -d "$OUT" ]; then
        echo "OUT 目录不存在。"
        return 1
    else
        cd "$OUT"
    fi
}

function build_uboot()
{
    cd $UBOOT_DIR

    # 直接使用 $1 作为 clean_build 的第二个参数
    if [ "$1" != "" ]; then
        clean_build "uboot" "$1"
        cd $UBOOT_DIR
    fi

    ./make.sh $UBOOT_TARGET
    if [ $? -eq 0 ]; then
        echo "U-Boot构建完成!"
        cmd_msg 0
    else
        echo "U-Boot构建出错!"
        cmd_msg 1
    fi
    cd $SRC_TOP
}

function build_kernel()
{
    cd $KERNEL_DIR

    # Initialize ADDON_ARGS
    ADDON_ARGS=""

    # Check for two arguments and ensure they are not the same
    if [ ! -z "$2" ] && [ "$1" = "$2" ]; then
        echo "错误：两个参数不能相同！"
        exit 1
    fi

    # Process arguments
    for arg in "$@"; do
        case "$arg" in
            "clean"|"mrproper"|"allclean")
                clean_build "kernel" "$arg"
                cd $KERNEL_DIR
                ;;
            "clang")
                if [ $SHELL = "/usr/bin/zsh" ];then
                    ADDON_ARGS=(CC=../prebuilts/clang/host/linux-x86/clang-r383902b/bin/clang LD=../prebuilts/clang/host/linux-x86/clang-r383902b/bin/ld.lld)
                else
                    ADDON_ARGS="CC=../prebuilts/clang/host/linux-x86/clang-r383902b/bin/clang LD=../prebuilts/clang/host/linux-x86/clang-r383902b/bin/ld.lld"
                fi
                ;;
            *)
                echo "警告：未识别的参数 '$arg' 将被忽略。"
                ;;
        esac
    done

    make $ADDON_ARGS ARCH=$KERNEL_ARCH $KERNEL_CFG 
    cmd_msg $?
    make $ADDON_ARGS ARCH=$KERNEL_ARCH $KERNEL_DTS.img -j$BUILD_JOBS
    cmd_msg $?
    cd $SRC_TOP

}

function build_android()
{
    cd $SRC_TOP
    . build/envsetup.sh
    lunch $ANDROID_PRODUCT-$ANDROID_VARIANT

    # Check for specific cleaning commands and execute them
    case "$1" in
        "insclean"|"allclean")
            clean_build "android" "$1"
            ;;
        *)
            # No argument or unrecognized argument, proceed directly to building
            ;;
    esac

    make -j$BUILD_JOBS
    cmd_msg $?
}

function make_rkimg()
{
    local AB_IMG=$(get_build_var BOARD_USES_AB_IMAGE)
    if [ $AB_IMG = "true" ];then
        bash $SRC_TOP/mkimage_ab.sh
        cmd_msg $?
    else
        bash $SRC_TOP/mkimage.sh
        cmd_msg $?
    fi
}

function make_update_img()
{
    cd $SRC_TOP
    ./build.sh -u
    cmd_msg $?
}

function build_all()
{
    cd $SRC_TOP
    UBOOT_CLEAN_ARG=""
    KERNEL_CLEAN_ARG=""
    ANDROID_BUILD_ARG=""
    KERNEL_BUILD_CLANG_FLAG=""

    # Check for two arguments and ensure they are not the same
    if [ ! -z "$2" ] && [ "$1" = "$2" ]; then
        echo "错误：两个参数不能相同！"
        exit 1
    fi

    # Process arguments
    for arg in "$@"; do
        case "$arg" in
            "clean")
                UBOOT_CLEAN_ARG="clean"
                KERNEL_CLEAN_ARG=$UBOOT_CLEAN_ARG
                ANDROID_BUILD_ARG="insclean"
                ;;
            "allclean")
                UBOOT_CLEAN_ARG="allclean"
                KERNEL_CLEAN_ARG="clean"
                ANDROID_BUILD_ARG=$UBOOT_CLEAN_ARG
                ;;
            "clang")
                KERNEL_BUILD_CLANG_FLAG="clang"
                ;;    
            *)
                echo "警告：未识别的参数 '$arg' 将被忽略。"
                ;;
        esac
    done

    build_uboot $UBOOT_CLEAN_ARG
    build_kernel $KERNEL_CLEAN_ARG $KERNEL_BUILD_CLANG_FLAG
    build_android $ANDROID_BUILD_ARG

    make_rkimg
    make_update_img
}

function clean_build() {
    local target=$1
    local clean_level=$2

    # 检查是否提供了正确的参数数量
    if [ -z "$target" ] || [ -z "$clean_level" ]; then
        echo "错误：必须提供两个参数：构建目标和清理级别。"
        return 1
    fi

    # 检查目标是否有效
    case "$target" in
        "uboot")
            ;;
        "kernel")
            ;;
        "android")
            ;;
        *)
            echo "未知的目标: $target"
            return 1
            ;;
    esac

    # 检查清理级别是否有效
    case "$clean_level" in
        "clean" | "mrproper" | "distclean" | "allclean")
            ;;
        "insclean" | "allclean")
            ;;
        *)
            echo "未知的清理级别: $clean_level"
            return 1
            ;;
    esac

    case "$target" in
        "uboot")
            cd $UBOOT_DIR
            case "$clean_level" in
                "clean")
                    make clean
                    ;;
                "mrproper")
                    make mrproper
                    ;;
                "distclean")
                    make distclean
                    ;;
                "allclean")
                    make clean && make mrproper && make distclean
                    ;;
                *)
                    echo "未知的清理级别: $clean_level"
                    ;;
            esac
            ;;
        "kernel")
            cd $KERNEL_DIR
            case "$clean_level" in
                "clean")
                    make clean
                    ;;
                "mrproper")
                    make mrproper
                    ;;
                "allclean")
                    make clean && make mrproper
                    ;;
                *)
                    echo "未知的清理级别: $clean_level"
                    ;;
            esac
            ;;
        "android")
            cd $SRC_TOP
            . build/envsetup.sh
            lunch $ANDROID_PRODUCT-$ANDROID_VARIANT
            case "$clean_level" in
                "insclean")
                    make installclean
                    ;;
                "allclean")
                    make clean
                    ;;
                *)
                    echo "未知的清理级别: $clean_level"
                    ;;
            esac
            ;;
        *)
            echo "未知的目标: $target"
            ;;
    esac
    cmd_msg $?

    cd $SRC_TOP
}

