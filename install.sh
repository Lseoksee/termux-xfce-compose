#!/data/data/com.termux/files/usr/bin/bash

# 저장소 접근 허용
termux-setup-storage

# 저장소 변경
termux-change-repo

# 패키지 업데이트 및 업그레이드
pkg update && pkg upgrade -y

# 필수 패키지 설치
pkg install git wget curl vim nano zip unzip termux-services which htop -y

# 추가 구성패키지 설치
pkg install eza neofetch ncurses-utils proot-distro -y

# xfce 데스크탑 환경 패키지 설치
pkg install x11-repo tur-repo root-repo pulseaudio dbus -y

# xfce4 설치  설치
pkg install xfce4 xfce4-goodies termux-x11 -y

# 필수 프로그램 설치
pkg install firefox -y

# 한글 설치
pkg install fcitx5-hangul -y
pkg install libhangul libhangul-static -y

# 환경변수 설정
echo '
alias ls="eza -lF --icons"
alias ll="ls -alhF"
alias shutdown="kill -9 -1"

export LANG=ko_KR.UTF-8
export LC_MONETARY="ko_KR.UTF-8"
export LC_PAPER="ko_KR.UTF-8"
export LC_NAME="ko_KR.UTF-8"
export LC_ADDRESS="ko_KR.UTF-8"
export LC_TELEPHONE="ko_KR.UTF-8"
export LC_MEASUREMENT="ko_KR.UTF-8"
export LC_IDENTIFICATION="ko_KR.UTF-8"
export LC_ALL=
export XDG_CONFIG_HOME=/data/data/com.termux/files/home/.config
export XMODIFIERS=@im=fcitx5
export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5' >> $PREFIX/etc/bash.bashrc

# 폰트설치
wget https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip
mkdir .fonts 
unzip CascadiaCode-2111.01.zip
mv otf/static/* .fonts/ && rm -rf otf
mv ttf/* .fonts/ && rm -rf ttf/
rm -rf woff2/ && rm -rf CascadiaCode-2111.01.zip

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Meslo.zip
unzip Meslo.zip
mv *.ttf .fonts/
rm Meslo.zip
rm LICENSE.txt
rm readme.md

wget https://github.com/KIMSEONGHA2223/Termux_edit/raw/main/NotoColorEmoji-Regular.ttf
mv NotoColorEmoji-Regular.ttf .fonts

wget https://github.com/KIMSEONGHA2223/Termux_edit/raw/main/font.ttf
mv font.ttf .termux/font.ttf

# 하드웨어 가속
pkg install mesa-vulkan-icd-freedreno-dri3 -y

# 그래픽 정보 및 벤치마크 도구 설치
pkg install mesa-demos glmark2 -y

# 진동 -> 무음 설정
sed -i 's/# bell-character = ignore/bell-character = ignore/g' /data/data/com.termux/files/home/.termux/termux.properties

# xfce 환경 설정 다운로드 및 적용
wget -P ~/ https://github.com/Lseoksee/termux-xfce-compose/raw/refs/heads/master/xfce-config.tar.gz
tar -zxvf ~/xfce-config.tar.gz
rm -rf ~/xfce-config.tar.gz


# 스크립트 생성

# xfce 시작 스크립트
cat <<'EOF' > $PREFIX/bin/start-xfce
#!/data/data/com.termux/files/usr/bin/bash

killall -9 termux-x11 Xwayland pulseaudio
termux-wake-lock

# Enable PulseAudio over Network
env LD_PRELOAD=/system/lib64/libskcodec.so pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 > /dev/null 2>&1

XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :1.0  & > /dev/null 2>&1
sleep 1

am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
sleep 1

env DISPLAY=:1.0 MESA_LOADER_DRIVER_OVERRIDE=zink dbus-launch --exit-with-session xfce4-session & > /dev/null 2>&1

# Set audio server
export PULSE_SERVER=127.0.0.1 > /dev/null 2>&1

EOF
chmod +x $PREFIX/bin/start-xfce

# xfce 종료 스크립트
cat <<'EOF' > $PREFIX/bin/shutdown-xfce
#!/data/data/com.termux/files/usr/bin/bash

# Check if Apt, dpkg, or Nala is running in Termux or Proot
if pgrep -f 'apt|apt-get|dpkg|nala'; then
  zenity --info --text="Software is currently installing in Termux or Proot. Please wait for these processes to finish before continuing."
  exit 1
fi

# Get the process IDs of Termux-X11 and XFCE sessions
termux_x11_pid=$(pgrep -f /system/bin/app_process.*com.termux.x11.Loader)
xfce_pid=$(pgrep -f "xfce4-session")

# Add debug output
echo "Termux-X11 PID: $termux_x11_pid"
echo "XFCE PID: $xfce_pid"

# Check if the process IDs exist
if [ -n "$termux_x11_pid" ] && [ -n "$xfce_pid" ]; then
  # Kill the processes
  kill -9 "$termux_x11_pid" "$xfce_pid"
  zenity --info --text="Termux-X11 and XFCE sessions closed."
else
  zenity --info --text="Termux-X11 or XFCE session not found."
fi

info_output=$(termux-info)
pid=$(echo "$info_output" | grep -o 'TERMUX_APP_PID=[0-9]\+' | awk -F= '{print $2}')
kill "$pid"

exit 0

EOF
chmod +x $PREFIX/bin/shutdown-xfce

# proot-ubuntu 시작 스크립트
cat <<'EOF' > $PREFIX/bin/ubuntu
#!/data/data/com.termux/files/usr/bin/bash

proot-distro login ubuntu $@ --shared-tmp --bind /data/data/com.termux/files/home:/mnt/termux-home -- /bin/bash -c "
export DISPLAY=$DISPLAY
export PULSE_RUNTIME_PATH=/data/data/com.termux/files/usr/tmp
bash
"

EOF
chmod +x $PREFIX/bin/ubuntu

# 앱 추가

# 종료 앱 추가
cat <<'EOF' > $PREFIX/share/applications/kill_termux_x11.desktop

[Desktop Entry]
Version=1.0
Type=Application
Name=Kill Termux X11
Comment=
Exec=shutdown-xfce
Icon=system-shutdown
Categories=System;
Path=
StartupNotify=false

EOF
chmod +x $PREFIX/share/applications/kill_termux_x11.desktop

# proot ubuntu 설치 및 구성
proot-distro install ubuntu

proot-distro login ubuntu --shared-tmp -- /bin/bash -c "
apt update && apt upgrade -y

apt install sudo wget curl vim nano zip unzip git htop mc firefox mesa-utils glmark2-x11 -y

apt install language-pack-ko -y

echo 'LANG="ko_KR.UTF-8"
LANG="ko_KR.EUC-KR"
LANGUAGE="ko_KR:ko:en_GB:en"' >> /etc/environment

echo '
export LANG=ko_KR.UTF-8' >> /etc/profile
source /etc/profile

apt install fonts-nanum* -y 
"

echo "proot-ubuntu root 비밀번호 지정"
proot-distro login ubuntu --shared-tmp -- /bin/bash -c "
passwd
"

echo "proot-ubuntu 'seoksee' 유저 생성"
proot-distro login ubuntu --shared-tmp -- /bin/bash -c "
adduser seoksee
usermod -aG sudo seoksee
"

# 사용자 앱 등록
git clone https://github.com/Lseoksee/termux-xfce-compose.git
chmod +x ./termux-xfce-compose/application/desktop/*
chmod +x ./termux-xfce-compose/application/scripts/*
cp ./termux-xfce-compose/application/desktop/* $PREFIX/share/applications/
cp -r ./termux-xfce-compose/application/scripts $PREFIX/share/applications 
rm -rf ./termux-xfce-compose

# 완료 메시지
echo '
수동으로 해줘야하는 것들:
1. source $PREFIX/etc/bash.bashrc
2. proot-ubuntu seoksee 계정 visudo 설정
