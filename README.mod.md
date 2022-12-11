## Batocera.PLUS.mod

update: jdk 19

del: firefox qBittorrent Wine WINDOWS_TOOLS

    apt-get install coreutils p7zip unzip gzip zstd xz-utils bzip2 tar patch squashfs-tools kmod jq wget curl axel
    
    git clone https://github.com/s700k/Batocera.PLUS.mod.git
    
    cd Batocera.PLUS.mod
    
    ./build-batocera.plus.mod
