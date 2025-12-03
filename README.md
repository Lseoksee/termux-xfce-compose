# termux-xfce-compose

Termux xfce 환경 구성 스크립트

- 시작
    ```bash
    wget -O https://raw.githubusercontent.com/Lseoksee/termux-xfce-compose/refs/heads/master/install.sh | bash
    ```

- proot-ubuntu 하드웨어 가속 설치

    > proot-ubuntu 내부에서 실행

    ```bash
    wget -O https://raw.githubusercontent.com/Lseoksee/termux-xfce-compose/refs/heads/master/install-mesa-freedreno.sh | bash
    ```

## 구성

Termux 네이티브 Xfce 환경 + proot-ubuntu

### 하드웨어 가속 정보

- 네이티브: virpipe
- proot-ubuntu: zink (turnip)

freedreno kgsl 설치를 연구중에 있으나 잘 안되는중