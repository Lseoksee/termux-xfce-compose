#!/bin/bash

# proot-ubuntu 하드웨어 가속용 mesa(freedreno, turnip)빌드 및 설치 스크립트

cd ~/

git clone https://github.com/xMeM/termux-packages.git -b dev/mesa --single-branch
wget https://archive.mesa3d.org/mesa-25.0.1.tar.xz
tar xf mesa-25.0.1.tar.xz
cd mesa-25.0.1

patch -p1 < ~/termux-packages/packages/mesa/0000-disable-android-detection.patch
patch -p1 < ~/termux-packages/packages/mesa/0001-disable-multithreading-for-llvmpipe.patch
patch -p1 < ~/termux-packages/packages/mesa/0002-fix-for-getprogname.patch
patch -p1 < ~/termux-packages/packages/mesa/0003-fix-for-anon-file.patch
patch -p1 < ~/termux-packages/packages/mesa/0004-do-not-check-xlocale.patch
patch -p1 < ~/termux-packages/packages/mesa/0005-virgl-socket-path.patch
patch -p1 < ~/termux-packages/packages/mesa/0006-wsi-no-pthread_cancel.patch
patch -p1 < ~/termux-packages/packages/mesa/0007-use-mtx_t-operations-in-turnip.patch
patch -p1 < ~/termux-packages/packages/mesa/0008-workaround-fortify-check.patch
patch -p1 < ~/termux-packages/packages/mesa/0009-disable-resource_create_front-for-vtest.patch
patch -p1 < ~/termux-packages/packages/mesa/0010-fix-zink-on-egl.patch
patch -p1 < ~/termux-packages/packages/mesa/0011-lld-undefined-version.patch
patch -p1 < ~/termux-packages/packages/mesa/0012-zink-import-fd.patch
patch -p1 < ~/termux-packages/packages/mesa/0013-fix-zink-on-wayland.patch

apt install \
build-essential \
meson \
python3-mako \
python3-yaml \
byacc \
flex \
pkg-config \
libglvnd-dev \
libdrm-dev \
libwayland-dev \
libwayland-egl-backend-dev \
libxcb-shm0-dev \
libxcb-randr0-dev \
libxext-dev \
libxfixes-dev \
libxcb-glx0-dev \
libx11-xcb-dev \
libxcb-dri3-dev \
libxcb-present-dev \
libxshmfence-dev \
libxxf86vm-dev \
libxrandr-dev \
glslang-tools \
llvm-dev \
-y

meson build -Dgbm=enabled -Dopengl=true -Degl=enabled -Degl-native-platform=x11 -Dgles1=disabled -Dgles2=enabled -Dglx=dri -Dllvm=enabled -Dshared-llvm=enabled -Dplatforms=x11,wayland -Dgallium-drivers=swrast,virgl,zink,freedreno -Dosmesa=true -Dglvnd=enabled -Dxmlconfig=disabled -Dvulkan-drivers=swrast,freedreno -Dfreedreno-kmds=msm,kgsl --reconfigure --prefix=/usr --libdir=/usr/lib/aarch64-linux-gnu

ninja -C build install

rm -rf ~/mesa-25.0.1 ~/mesa-25.0.1.tar.xz ~/termux-packages 