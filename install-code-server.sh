#!/data/data/com.termux/files/usr/bin/bash

# 저장소 접근 허용
termux-setup-storage

# 저장소 변경
termux-change-repo

# 패키지 업데이트 및 업그레이드
pkg update && pkg upgrade -y

# 필수 패키지 설치
pkg install git wget curl vim nano zip unzip eza termux-services which htop proot-distro -y

# 진동 -> 무음 설정
sed -i 's/# bell-character = ignore/bell-character = ignore/g' /data/data/com.termux/files/home/.termux/termux.properties

# proot ubuntu 설치 및 구성
proot-distro install ubuntu

proot-distro login ubuntu --shared-tmp -- /bin/bash -c "
apt update && apt upgrade -y

apt install sudo wget curl vim nano zip unzip git htop mc -y

curl -fsSL https://code-server.dev/install.sh | sh
"

# 환경변수 설정
echo '
export PHOME="$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu"

alias ls="eza -lF --icons"
alias ll="ls -alhF"
alias shutdown="kill -9 -1"
' >> $PREFIX/etc/bash.bashrc

# code-server 시작 스크립트
cat <<'EOF' > $PREFIX/bin/start-code
#!/data/data/com.termux/files/usr/bin/bash

proot-distro login ubuntu --user seoksee --shared-tmp --no-kill-on-exit --bind /data/data/com.termux/files/home:/mnt/termux-home -- /bin/bash -c "
termux-wake-lock

echo '' > code-log.log

while true :
do
    code-server >> code-log.log 2>&1
    echo 'code-server 다시시작 중...' >> code-log.log
done
" &
EOF
chmod +x $PREFIX/bin/start-code

# code-server 로그스크립트
cat <<'EOF' > $PREFIX/bin/code-log
#!/data/data/com.termux/files/usr/bin/bash
tail -f -n 100 $PHOME/home/seoksee/code-log.log
EOF
chmod +x $PREFIX/bin/code-log

# 완료 메시지
echo '
수동으로 해줘야하는 것들:
1. source $PREFIX/etc/bash.bashrc
2. passwd 변경및 사용자 생성
