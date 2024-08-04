## [exTHmUI-11.0](https://github.com/exTHmUI-legacy/) for tspi phone

请克隆该仓库至 [SDK_ROOT]/vendor/exthmui-tspi 目录下。
```shell
git clone --recursive https://github.com/Yuyuko1024/exthmui-tspi vendor/exthmui-tspi 
```

### 初始化环境脚本
在包含有repo的Android SDK源代码压缩包解压到指定目录后，克隆本仓库到上面提到的路径下，随后执行下面脚本以进行环境的初始化。推荐你使用Ubuntu 20.04这个版本。
```shell
./vendor/exthmui-tspi/scripts/env_init.sh
```
它将帮助你安装所需的环境依赖软件包，以及更新本地的repo版本，并初始化你所下载的Android SDK代码。

### 编译环境脚本
本仓库包含一个```vendorsetup.sh```脚本，它可以将其中包含的快捷命令或者环境初始化命令应用到当前工作区。
只需要在已检出的SDK根目录执行 ``` . build/envsetup.sh ``` 即可自动初始化该脚本。
```shell
maribel@Lenovo-Legion-Y7000:work/tspi_android_sdk_repo_20240202 $ . build/envsetup.sh 
including vendor/exthmui-tspi/build/vendorsetup.sh
若需要获取命令帮助，请输入 vendor_usage 命令。
For extra command help, please use vendor_usage to show help.
maribel@Lenovo-Legion-Y7000:work/tspi_android_sdk_repo_20240202 $ vendor_usage
----------------------------------
额外 vendor 命令帮助
notice: [arg]表示该命令只能接受0或者1个参数。
[arg1] [arg2]表示该命令可接受0到2个参数, 且参数前同样为该标志表示该命令可以无视排序。
             但是当参数前有 1- 或者 2- 时, 代表该列参数只能选择其中一个作为命令其中的一个参数。

go_top: 回到 SDK 根目录

cout: 进入构建输出目录

build_uboot [arg]: 编译 SDK 中的 u-boot 镜像
    [arg] 参数： clean: 等效于 make clean, 编译前步骤。
          mrproper: 等效于 make mrproper
          distclean: 等效于 make distclean
          allclean: 同时运行上述三个参数

build_kernel [arg1] [arg2]: 编译 SDK 中的 kernel 镜像
    参数： 1- [arg1] [arg2] clean: 等效于 make clean, 编译前步骤。
          1- [arg1] [arg2] mrproper: 等效于 make mrproper
          1- [arg1] [arg2] allclean: 同时运行上述三个参数
          [arg1] [arg2] clang: 编译时使用 SDK 自带 clang

build_android [arg]: 编译 SDK 中的 Android 操作系统
    [arg] 参数： allclean: 等效于 make clean, 编译前全清理步骤。
          insclean: 等效于 make installclean, 编译前只清理构建输出步骤。

build_all [arg1] [arg2]: 编译上面所有三个步骤的构建输出
    参数： 1- [arg1] [arg2] clean: 等效于 make clean, 编译前步骤。
          1- [arg1] [arg2] allclean: 等效于 make clean, 编译前全清理步骤。
          [arg1] [arg2] clang: 编译时使用 SDK 自带 clang

make_rkimg: 打包rockchip镜像和parameter

make_update_img: 打包 update.img 刷机固件（需要先lunch指定的config）

clean_build [arg1] [arg2]: 清理目标构建输出
    参数： 1- [arg1] 要清理的目标，有 uboot, kernel, android
          2- [arg2] 要清理的等级，清理等级参照上面命令参数
----------------------------------
```

更多命令后续更新...

### 代码补丁
您在上述 clone 操作后，应该可以在本项目下看到一个 patchs 目录。这里面存放了需要对 SDK 进行修补的补丁。
其中的 `rk356x-已修改仓库列表.md` 中已标注需要修补的仓库路径。您需要进入指定的路径，并使用 ` git am /path/to/patchs/*.patch ` 来修补代码。
对于泰山派小海豚手机项目，您需要事先从 [千古长夜丶/TSPiPhoneEXT - Gitee.com](https://gitee.com/faltering_and_small_white/tspi-phone-ext/tree/master) 获取 kernel 补丁并修补 kernel。
自动更新补丁和修补脚本将会在未来推出。

对于补丁更新，您可以在本仓库路径下执行 `git submodule update --remote patchs` 来更新补丁仓库。

