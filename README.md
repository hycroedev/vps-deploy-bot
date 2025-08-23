VPS Deploy Bot 🚀                                                                           

Simple docker build scripts for multiple Linux-based VPS containers.

📂 Supported OS Images

Arch Linux

Fedora

Kali Linux

Alpine Linux

Debian

Ubuntu


📥 Installation / Build Steps

Clone This Repository:

git clone https://github.com/hycroedev/vps-deploy-bot.git && cd vps-deploy-bot && pip install discord.py docker psutil

𝗕𝗨𝗜𝗟𝗗 𝗔𝗟𝗟 docker 𝗜𝗠𝗔𝗚𝗘𝗦:

docker build -t arch-vps -f Dockerfile.arch .

docker build -t fedora-vps -f Dockerfile.fedora . 

docker build -t kali-vps -f Dockerfile.kali .

docker build -t alpine-vps -f Dockerfile.alpine . 

docker build -t debian-vps -f Dockerfile.debian . 

docker build -t ubuntu-vps -f Dockerfile.ubuntu .

main : bot-script.py

□■■■□■■■□■■■□■■■□■■■□■■■□■■■□■■■□

## Credits

- Thanks ,Niwely
- made by made by hycroedev
