#!/bin/bash
##
## Batocera.PLUS
##
set -e

################################################################################

# Batocera.PLUS Version
VERSION='2.26'

# Remova esta linha para diminuir o tempo de compilação.
# A imagem não será compactada e nem gerado o md5sum.
# Serão dicionados pacotes experimentais.
RELEASE='beta-mod'

# Squashfs compression level
SQUASHFS_COMPRESSION='2'

# Add all bios to image
ALL_BIOS=true

# Temporary folder on a linux partition
TEMP_DIR='./output'
#TEMP_DIR='/media/Linux/tmp'

# BatoceraZero (final image size)
BATOCERA_ZERO='BatoceraZero5GB-1.7z'

# Batocera.PLUS extra files
PLUS_DIR='plus'
UPDATE_DIR='update'
BOOT_DIR='boot'
DOWNLOAD_DIR='download'
PATCH_DIR='patch'
SCRIPT_DIR='script'

################################################################################

# Corrige erros de compilação em sistemas que não usam o busybox
# Debian, Ubuntu, etc...

if [ "$(readlink $(whereis -b cp | cut -d ' ' -f 2))" != 'busybox' ]; then
    shopt -s expand_aliases
    alias cp='cp --remove-destination'
fi

################################################################################

# DOWNLOADS LINKS

echo -e "\nBuild Batocera.PLUS-${VERSION}-${RELEASE}..."

URL_BATOCERA_PLUS_PKG=(
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/proton-valve-7.0-3-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/proton-ge-custom-7.29-1.7z'

    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/DX9Jun2010.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/msttcorefonts-2.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/dxvk-1.5.1-3.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/dxvk-proton-ge-custom-7.29-1.7z'

    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/gstreamer1-1.18.6-64bits-1.7z' # dep: wine
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/gst1-libav-1.18.6-64bits-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/gst1-plugins-bad-1.18.6-64bits-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/gst1-plugins-base-1.18.6-64bits-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/gst1-plugins-good-1.18.6-64bits-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/gst1-plugins-ugly-1.18.6-64bits-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/orc-0.4.32-64bits-1.7z' #dep: gstreamer1
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mpg123-1.7z'            #dep: gstreamer1

    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/gstreamer1-1.18.6-32bits-1.7z' # dep: wine
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/gst1-libav-1.18.6-32bits-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/gst1-plugins-bad-1.18.6-32bits-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/gst1-plugins-base-1.18.6-32bits-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/gst1-plugins-good-1.18.6-32bits-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/gst1-plugins-ugly-1.18.6-32bits-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/orc-0.4.32-32bits-1.7z' #dep: gstreamer1-32bits
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mpg123-32bits-1.7z'     #dep: gstreamer1-32bits

    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/retroarch-1.9.9-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/retroarch-assets-1.9.9-2.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/retroarch-cheats-1.9.7-2.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/retroarch-info-1.9.10-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/retroarch-retroachievements-sounds-1.9.7-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/retroarch-slang-shaders-1.9.9-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/retroarch-glsl-shaders-1.9.9-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/retroarch-common-shaders-1.9.7-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/retroarch-batocera-shaders-1.9.7-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/retroarch-batocera-plus-shaders-1.9.7-1.7z'

    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/4do_libretro-feb-3-2020-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/81_libretro-feb-4-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/atari800_libretro-feb-7-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/beetle-saturn_libretro-set-18-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/blastem_libretro-mar-09-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/bluemsx_libretro-feb-13-2022-2.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/bsnes_hd_libretro-jun-18-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/bsnes_libretro-aug-1-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/cap32_libretro-mar-3-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/catsfc_libretro-feb-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/citra_libretro-jul-30-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/crocods_libretro-jan-7-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/desmume_libretro-jan-9-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/dolphin_libretro-feb-9-2021-2.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/dosbox_libretro-jan-26-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/dosbox_pure_libretro-feb-23-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/duckstation_libretro-nov-12-2022-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/emuscv_libretro-mar-4-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/fbalpha2012_libretro-feb-21-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/fbalpha2012_cps1_libretro-jan-9-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/fbalpha2012_cps2_libretro-jan-9-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/fbalpha2012_cps3_libretro-Jan-9-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/fbalpha2012_neogeo_libretro-jan-9-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/fbneo_libretro-apr-4-2022-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/fceumm_libretro-mar-8-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/flycast2019_libretro-aug-13-2019-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/flycast_libretro-may-jul-15-2022-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/fmsx_libretro-mar-3-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/freechaf_libretro-jan-2-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/freej2me_libretro-may-22-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/freeintv_libretro-jul-30-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/fuse_libretro-feb-4-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/gambatte_libretro-feb-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/gearsystem_libretro-feb-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/genesisplusgx_libretro-set-18-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/genesisplusgx_wide_libretro-set-25-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/gpsp_libretro-mar-7-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/gw_libretro-jan-29-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/handy_libretro-feb-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/hatari_libretro-oct-27-2020-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/hbmame_libretro-apr-3-2020-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/ishiiruka_libretro-oct-3-2020-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/kronos_libretro-jul-28-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/lutro_libretro-mar-2-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mame_libretro-apr-22-2022-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mame0200_libretro-nov-8-2018-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mame0160_libretro-jan-19-2022-2.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mame0174_libretro-apr-6-2022-2.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mame0139_libretro-apr-12-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mame078plus_libretro-apr-6-2022-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mame037_libretro-apr-13-2022-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mednafen_lynx_libretro-jan-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mednafen_ngp_libretro-feb-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mednafen_psx_libretro-nov-14-2022-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mednafen_psx_sw_libretro-nov-14-2022-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mednafen_supergrafx_libretro-apr-9-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mednafen_wswan_libretro-feb-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/melonds_libretro-apr-11-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mesen_libretro-jun-30-2020-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mesen-s_libretro-jul-8-2020-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/meteor_libretro-dec-28-2020-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mgba_libretro-jul-12-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mrboom_libretro-feb-12-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mu_libretro-feb-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mupen64plus-next_libretro-Feb-26-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/nekop2_libretro-jan-10-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/neocd-libretro-set-1-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/nestopia_libretro-mar-22-2022-2.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/np2kai_libretro-feb-11-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/nxengine_libretro-feb-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/o2em_libretro-feb-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/opera_libretro-feb-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/parallel_n64_libretro-jan-27-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/pce_fast_libretro-apr-8-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/pce_libretro-apr-9-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/pcfx_libretro-feb-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/pcsx_rearmed_libretro-nov-14-2022-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/pcsx2_libretro-mar-28-2022-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/picodrive_libretro-set-25-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/pokemini_libretro-feb-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/potator_libretro-aug-5-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/ppsspp_libretro-mar-2-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/prboom_libretro-feb-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/prosystem_libretro-mar-3-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/puae_libretro-mar-4-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/px68k_libretro-mar-11-2022-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/quasi88_libretro-mar-7-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/quicknes_libretro-feb-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/race_libretro-aug-2-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/redream_libretro-jun-7-2020-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/retro8_libretro-jan-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/scummvm_libretro-mar-5-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/smsplus_libretro-jan-24-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/snes9x_libretro-may-27-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/snes9x_next_libretro-feb-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/stella_libretro-mar-2-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/tgbdual_libretro-feb-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/theodore_libretro-jan-31-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/tic80_libretro-mar-5-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/tyrquake_libretro-feb-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/uzem_libretro-jan-8-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/vba-m_libretro-feb-27-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/vb_libretro-feb-25-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/vecx_libretro-feb-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/vice_libretro-mar-9-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/virtualjaguar_libretro-feb-14-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/x1_libretro-jan-8-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/yabasanshiro_libretro-feb-4-2021-2.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/yabause_libretro-set-22-2021-1.7z'

    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/dolphin-emu-5.0-13603-feb-3-2021-2.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/flycast-aug-30-2021-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/freej2me-may-22-2021-2.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/hypseus-singe-mar-24-2022-2.7z' # remove on update.
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/ppsspp-mar-2-2021-2.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/rpcs3-0.0.15-3.7z' # remove on update.
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/xemu-mar-23-2022-1.7z' # remove on update.
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/yuzu-2022-11-21.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/yuzu-extra-libs-1.7z'

    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/cemuextras-1.7.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/cemufakefiles-1.0.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/Future_Pinball-1.3.7z' # remove on update.
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/model2-1.1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/model3-1.1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/visual_pinball-1.0.1-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/vpinball_fonts-1.0.7z' # dep: visual pinball
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/openbor-4432-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/openbor-6330-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/openbor-7142-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/rpcs3_extra_libs-1.1.7z' # dep: rpcs3
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/ryujinx_extras-1.2.7z' # dep: ryujinx
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/pcsx2-legacy-apr-10-2021-2.7z'

    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/p7zip-full-17.04-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/p7zip-gui-17.04-2.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/bzip2-1.0.8.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/unrar-5.90-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/zstd-1.4.3-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/libcap-2.27-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/squashfs-tools-4.4-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/strip-b5.27.2-2.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/popstationr-1.7z'

    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/imagemagic-7.0.8-59-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/xmlstarlet-1.6.1-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/dos2unix-7.4.1-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/util-linux-extras-2.35-1.7z' # cfdisk, swapon, whereis
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/preload-0.6.4-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/yad-0.40.0-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/axel-2.17.11-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/strace-5.13-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/ltrace-0.7.91-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/numlockx-1.2.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/libXtst-6.1.0.7z'          # dep: java, numlockx
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/msr-tools-1.3-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/pipewire-0.3.31-1.7z'             # remove on update

    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/Goverlay-0.8.1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/vkbasalt-0.3.2.5-2.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/git-2.31.1-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/parsec-2.7z'

    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/tint2-16.7-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/jgmenu-4.2.1-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/nsxiv-jun-11-2022-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/imlib2-1.5.1-1.7z'         # dep: tint2, nsxiv

    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/librsvg-2.40.20-1.7z'      # dep: tint2, jgmenu
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/libcroco-0.6-1.7z'         # dep: tint2, jgmenu
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/libfm-gtk-4.1.2-2.7z'      # dep: pcmanfm (add new folders to left menu)
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/libgtk3-3.24-1.7z'         # remove on update
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/libaio-0.3.111-1.7z'       # remove on update
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/wxwidgets-gtk2-3.1.0-1.7z' # dep: p7zip
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/wxwidgets-gtk3-3.1.0-1.7z' # dep: tint2 #remove on update
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mime-cache-2.7z'           # dep: pcmanfm (show icons in files)
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/gvfs-1.44-2.7z'            # remove on update
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/libsoundtouch-1.0-1.7z'    # dep: pcsx2 #remove on update
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/portaudio-2.0-1.7z'        # dep: pcsx2 #remove on update
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/libyaml-cpp-0.6.3-1.7z'    # dep: pcsx2 #remove on update
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/adwaita-blue-light-167841-1.7z'

    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/user-manual-2.7z'

    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/wii-u-gc-adapter-mar-6-2021-3.7z' # remove on update
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/xow-apr-8-2021-1.7z'              # remove on update

    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/nvidia-driver-510.60.02-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/nvidia-driver-470.103.01-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/nvidia-driver-390.147-2.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/nvidia-driver-340.108-2.7z'

    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mesa3d-32bits-21.3.8-2.7z'        # remove on update
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/mesa3d-64bits-21.3.8-1.7z'        # remove on update
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/xlib_libXv-1.0.11-1.7z'           # dep: nvidia-driver (nvidia-settings)
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/xdriver_xf86-video-all-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/xfont_extras-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/libLLVM-13.0.0-1.7z'              # dep: mesa3d # remove on update
)

URL_BATOCERA_PLUS_DEV_PKG=(
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/obs-studio-27.0.1-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/obs-studio-extra-libs-1.7z' #dep: obs-studio
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/shared-mime-info-1.44-1.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/xdotool-aug-4-2021.7z'
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/nvidia-driver-cuda-510.60.02-1.7z'   # dep: nvidia-driver
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/nvidia-driver-opencl-510.60.02-1.7z' # dep: nvidia-driver
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/ruffle-apr-11-2022-1.7z'   # remove on update
    'https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/lightspark-apr-11-2022.7z' # remove on update
)

URL_BATOCERA_LINUX='https://batocera.org/upgrades/x86_64/stable/last/archives/20201001/batocera-5.27.2-x86_64-20201001.img.gz'
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_BATOCERA_LINUX}")

URL_BATOCERA_ZERO="https://github.com/AlexxandreFS/Batocera.PLUS-pkg/raw/main/${BATOCERA_ZERO}"
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_BATOCERA_ZERO}")

URL_PCI_IDS='2.2'
URL_PCI_IDS="http://pci-ids.ucw.cz/v${URL_PCI_IDS}/pci.ids.gz#/pci.ids-${URL_PCI_IDS}.gz"
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_PCI_IDS}")

URL_NVIDIA_DRIVER='http://download.nvidia.com/XFree86/Linux-x86_64/510.60.02/NVIDIA-Linux-x86_64-510.60.02.run'
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_NVIDIA_DRIVER}")

URL_LINUX_FIRMWARE='https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/snapshot/linux-firmware-20221109.tar.gz'
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_LINUX_FIRMWARE}")

URL_ES_THEME_A='4614712f610f8083df9e5289f256f0662b7b1ca0'
URL_ES_THEME_A="https://github.com/AlexxandreFS/Batocera.PLUS-es-theme/archive/${URL_ES_THEME_A}.zip#/Batocera.PLUS-es-theme-${URL_ES_THEME_A}.zip"
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_ES_THEME_A}")

URL_ES_THEME_B='5ff5eb45d692a39f05b7ca6980a9150e446e65fd'
URL_ES_THEME_B="https://github.com/LordOgro/Carbon-2.0_PLUS/archive/${URL_ES_THEME_B}.zip#/Carbon-2.0_PLUS-${URL_ES_THEME_B}.zip"
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_ES_THEME_B}")

URL_BEZELS='ac821e502dfd2ef7237ff1698503eb75909e1b42'
URL_BEZELS="https://github.com/AlexxandreFS/Batocera.PLUS-bezels/archive/${URL_BEZELS}.zip#/Batocera.PLUS-bezels-${URL_BEZELS}.zip"
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_BEZELS}")

URL_MUSIC='133b040ce3c04b6c462102a57ea1134ab73a80c7'
URL_MUSIC="https://github.com/BatoceraPLUS/Batocera.PLUS-music/archive/${URL_MUSIC}.zip#/Batocera.PLUS-music-${URL_MUSIC}.zip"
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_MUSIC}")

URL_ALL_BIOS='f40e0ee4bf06d4d9f12b262e0e2b48d34d3b2631'
URL_ALL_BIOS="https://github.com/BatoceraPLUS/Batocera.PLUS-bios/archive/${URL_ALL_BIOS}.zip#/Batocera.PLUS-bios-${URL_ALL_BIOS}.zip"
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_ALL_BIOS}")

#URL_WINDOWS_TOOLS='9b20ae5ca70260ef0a6f6ec46682880c38abb938'
#URL_WINDOWS_TOOLS="https://github.com/AlexxandreFS/Batocera.PLUS-tools/archive/${URL_WINDOWS_TOOLS}.zip#/Batocera.PLUS-tools-${URL_WINDOWS_TOOLS}.zip"
#URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_WINDOWS_TOOLS}")

URL_JAVA='https://download.oracle.com/java/18/latest/jdk-19_linux-x64_bin.tar.gz'
#https://www.oracle.com/java/technologies/downloads/
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_JAVA}")

URL_SOUNDFONT_GS='GeneralUser_GS_1.471.zip'
# http://www.schristiancollins.com/generaluser.php
URL_SOUNDFONT_GS="https://www.dropbox.com/s/4x27l49kxcwamp5/${URL_SOUNDFONT_GS}?dl=1#/${URL_SOUNDFONT_GS}"
#URL_SOUNDFONT_GS="https://ftp.kaist.ac.kr/macports/distfiles/generaluser-soundfont/${URL_SOUNDFONT_GS}"
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_SOUNDFONT_GS}")

URL_CEMU='https://cemu.info/releases/cemu_1.26.2.zip'
#URL_CEMU="$(curl -s http://cemu.info | grep -i 'cemu_.*' | tail -n 1 | cut -d '"' -f 2 | cut -d ' ' -f 1)"
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_CEMU}")

URL_CEMUHOOK='https://files.sshnuke.net/cemuhook_1262d_0577.zip'
#URL_CEMUHOOK="$(curl -s https://cemuhook.sshnuke.net/ | grep -A 2 -F '<h2>Current versions</h2>' | grep '.zip' | cut -d '"' -f 2)"
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_CEMUHOOK}")

URL_RYUJINX='https://github.com/Ryujinx/release-channel-master/releases/download/1.1.299/ryujinx-1.1.299-linux_x64.tar.gz' #Link provisório
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_RYUJINX}")

URL_PCSX2='https://github.com/PCSX2/pcsx2/releases/download/v1.7.3411/pcsx2-v1.7.3411-linux-AppImage-64bit-wxWidgets.AppImage'
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_PCSX2}")

URL_RPCS3='https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-0737c788fc8b8b33d79c620065c5fc4990dbed80/rpcs3-v0.0.24-14263-0737c788_linux64.AppImage'
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_RPCS3}")

URL_MANGOHUD='https://github.com/flightlessmango/MangoHud/releases/download/v0.6.8/MangoHud-0.6.8.r0.gefdcc6d.tar.gz'
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_MANGOHUD}")

URL_GAMECONTROLLERDB='adf7ec1edfc0371ebf5fb469b61f301b8e26ec81'
URL_GAMECONTROLLERDB="https://raw.githubusercontent.com/gabomdq/SDL_GameControllerDB/${URL_GAMECONTROLLERDB}/gamecontrollerdb.txt#/gamecontrollerdb-${URL_GAMECONTROLLERDB}.txt"
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_GAMECONTROLLERDB}")

URL_GAMEPADTOOLS='https://generalarcade.com/gamepadtool/linux/gamepad-tool-amd64_1.1.3.zip'
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_GAMEPADTOOLS}")

URL_ANTIMICRO='3.1.7'
URL_ANTIMICRO="https://github.com/AntiMicroX/antimicrox/releases/download/${URL_ANTIMICRO}/AntiMicroX-x86_64.AppImage#/AntiMicroX-${URL_ANTIMICRO}.AppImage"
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_ANTIMICRO}")

URL_PEAZIP='https://github.com/peazip/PeaZip/releases/download/8.2.0/peazip_portable-8.2.0.LINUX.GTK2.x86_64.tar.gz'
URL_EXTERNAL_PKG=("${URL_EXTERNAL_PKG[@]}" "${URL_PEAZIP}")

################################################################################

# CLEAR

echo -e '\nLimpando a pasta temporária...'

umount  -fl /dev/loop6               2> /dev/null || :
umount  -fl /dev/loop7               2> /dev/null || :

losetup -d  /dev/loop6               2> /dev/null || :
losetup -d  /dev/loop7               2> /dev/null || :

umount  -fl "${TEMP_DIR}/pkg-xtract" 2> /dev/null || :

rm -rf "${TEMP_DIR}/"*               2> /dev/null || :

echo -e '\nLimpando a pasta de download...\n'

if [ "${RELEASE}" ]; then
    for FILE in "${DOWNLOAD_DIR}/"*; do
        FOUND=FALSE

        for URL in "${URL_BATOCERA_PLUS_PKG[@]}" \
                   "${URL_BATOCERA_PLUS_DEV_PKG[@]}" \
                   "${URL_EXTERNAL_PKG[@]}"
        do
            if [ "${DOWNLOAD_DIR}/$(basename ${URL})" == "${FILE}" ]; then
                echo "[Found] : ${FILE}"
                FOUND=TRUE
                break
            fi
        done

        if [ "${FOUND}" == 'FALSE' ]; then
            echo "[Delete]: ${FILE}"
            rm -rf "${FILE}"
        fi
    done

    unset URL_BATOCERA_PLUS_DEV_PKG
fi

################################################################################

# DOWNLOAD

mkdir -p "${DOWNLOAD_DIR}"

for URL in "${URL_BATOCERA_PLUS_PKG[@]}" \
           "${URL_BATOCERA_PLUS_DEV_PKG[@]}" \
           "${URL_EXTERNAL_PKG[@]}"
do
    PKG_NAME="$(basename "${URL}")"

    # Delete incomplete download
    if [ -e "${DOWNLOAD_DIR}/${PKG_NAME}.lock" ]; then
        rm -f "${DOWNLOAD_DIR}/${PKG_NAME}"
    fi

    # Skip previously downloaded file
    if [ -e "${DOWNLOAD_DIR}/${PKG_NAME}" ]; then
        continue
    fi

    echo -e "\nDownload ${PKG_NAME}...\n"

    touch "${DOWNLOAD_DIR}/${PKG_NAME}.lock"

    # Try download accelerator
    if [ -e '/usr/bin/axel' ]; then
        if axel --insecure --num-connections=4 --alternate  "${URL}" --output "${DOWNLOAD_DIR}/${PKG_NAME}"; then
            rm "${DOWNLOAD_DIR}/${PKG_NAME}.lock"
            continue
        fi
        rm -f "${DOWNLOAD_DIR}/${PKG_NAME}.st"
    fi

    # Nornal Download
    if curl -L -k --proxy-insecure "${URL}" -o "${DOWNLOAD_DIR}/${PKG_NAME}"; then
        rm "${DOWNLOAD_DIR}/${PKG_NAME}.lock"
        continue
    fi

    echo -e "\nERROR DOWNLOAD: \"${PKG_NAME}\""
    echo -e "URL = ${URL}\n"

    exit 1
done

################################################################################

echo -e '\nDescompactando Batocera.Linux...'
PKG_NAME="$(basename "${URL_BATOCERA_LINUX}")"
mkdir -p "${TEMP_DIR}"
gunzip -k "${DOWNLOAD_DIR}/${PKG_NAME}" -c > "${TEMP_DIR}/Batocera.Linux.img"

echo 'Adicionando imagem do Batocera.Linux ao disposivo loop...'
losetup -f
losetup /dev/loop7 -o $((512 * 2048)) "${TEMP_DIR}/Batocera.Linux.img"

echo 'Montando imagem do batocera.linux...'
mkdir "${TEMP_DIR}/Batocera.Linux"
mount -o rw /dev/loop7 "${TEMP_DIR}/Batocera.Linux"

echo 'Descompactando arquivo squashfs...'
unsquashfs -d "${TEMP_DIR}/Batocera.PLUS" "${TEMP_DIR}/Batocera.Linux/boot/batocera"

################################################################################

echo 'Removendo arquivos desnecessários...'

# Remova apenas se atualizar o pacote completo dos shaders para o retroarch.
rm -r "${TEMP_DIR}/Batocera.PLUS/usr/share/batocera/shaders"

# Remove a pasta de bios que vem por padrão com o batocera.linux
# Remova apenas quando todos os emuladores que adionam os respectivos arquivos estiverem atualizados
rm -rf "${TEMP_DIR}/Batocera.PLUS/usr/share/batocera/datainit/bios/"*

# Remove o tema padrão do emulationstation
rm -rf "${TEMP_DIR}/Batocera.PLUS/usr/share/emulationstation/themes/es-theme-carbon"

# Remove icones duplicados e fora do padrão para um próximo update.
rm -f "${TEMP_DIR}/Batocera.PLUS/usr/share/applications/scummvm.desktop"
rm -f "${TEMP_DIR}/Batocera.PLUS/usr/share/applications/dolphin-emu.desktop"
rm -f "${TEMP_DIR}/Batocera.PLUS/usr/share/applications/retroarch.desktop"
rm -f "${TEMP_DIR}/Batocera.PLUS/usr/share/applications/pcmanfm-desktop-pref.desktop"

# Remove roms que por padrão já vem com o sistema
for x in c64 gba megadrive nes pcengine prboom snes; do
    for y in "${TEMP_DIR}/Batocera.PLUS/usr/share/batocera/datainit/roms/${x}/"*; do
        if [ "${y}" != "${TEMP_DIR}/Batocera.PLUS/usr/share/batocera/datainit/roms/${x}/_info.txt" ]; then
            rm -r "${y}" || exit $?
        fi
    done
done

# Desativa por padrão o jogo MrBoom
mv ${TEMP_DIR}/Batocera.PLUS/usr/share/batocera/datainit/roms/mrboom/MrBoom.libretro \
   ${TEMP_DIR}/Batocera.PLUS/usr/share/batocera/datainit/roms/mrboom/MrBoom.libretro.disable

# Remove o driver antigo da Nvidia
KERNEL_VERSION="$(ls ${TEMP_DIR}/Batocera.PLUS/lib/modules)"
NVIDIA_VERSION="$(modinfo "${TEMP_DIR}/Batocera.PLUS/lib/modules/${KERNEL_VERSION}/extra/nvidia.ko" | grep -E '^version: ' | awk '{print $2}')"

NVIDIA_FILES=(
    /lib/modules/${KERNEL_VERSION}/extra/nvidia.ko
    /lib/modules/${KERNEL_VERSION}/extra/nvidia-drm.ko
    /lib/modules/${KERNEL_VERSION}/extra/nvidia-modeset.ko
    /lib/modules/${KERNEL_VERSION}/extra/nvidia-uvm.ko

    /lib32/libGLX_nvidia.so.${NVIDIA_VERSION}         /lib32/libGLX_nvidia.so.0          /lib32/libGLX_nvidia.so
    /lib32/libEGL_nvidia.so.${NVIDIA_VERSION}         /lib32/libEGL_nvidia.so.0          /lib32/libEGL_nvidia.so
    /lib32/libGLESv1_CM_nvidia.so.${NVIDIA_VERSION}   /lib32/libGLESv1_CM_nvidia.so.1    /lib32/libGLESv1_CM_nvidia.so
    /lib32/libGLESv2_nvidia.so.${NVIDIA_VERSION}      /lib32/libGLESv2_nvidia.so.2       /lib32/libGLESv2_nvidia.so
    /lib32/libnvidia-eglcore.so.${NVIDIA_VERSION}                                        /lib32/libnvidia-eglcore.so
    /lib32/libnvidia-glcore.so.${NVIDIA_VERSION}                                         /lib32/libnvidia-glcore.so
    /lib32/libnvidia-glsi.so.${NVIDIA_VERSION}                                           /lib32/libnvidia-glsi.so
    /lib32/libnvidia-ml.so.${NVIDIA_VERSION}          /lib32/libnvidia-ml.so.1           /lib32/libnvidia-ml.so
    /lib32/libnvidia-tls.so.${NVIDIA_VERSION}                                            /lib32/libnvidia-tls.so
    /lib32/libvdpau_nvidia.so.${NVIDIA_VERSION}       /lib32/libvdpau_nvidia.so.1        /lib32/libvdpau_nvidia.so
   #/lib32/libnvidia-glvkspirv.so.${NVIDIA_VERSION}                                      /lib32/libnvidia-glvkspirv.so

    /usr/lib/libGLX_nvidia.so.${NVIDIA_VERSION}       /usr/lib/libGLX_nvidia.so.0        /usr/lib/libGLX_nvidia.so
    /usr/lib/libEGL_nvidia.so.${NVIDIA_VERSION}       /usr/lib/libEGL_nvidia.so.0        /usr/lib/libEGL_nvidia.so
    /usr/lib/libGLESv1_CM_nvidia.so.${NVIDIA_VERSION} /usr/lib/libGLESv1_CM_nvidia.so.1  /usr/lib/libGLESv1_CM_nvidia.so
    /usr/lib/libGLESv2_nvidia.so.${NVIDIA_VERSION}    /usr/lib/libGLESv2_nvidia.so.2     /usr/lib/libGLESv2_nvidia.so
    /usr/lib/libnvidia-eglcore.so.${NVIDIA_VERSION}                                      /usr/lib/libnvidia-eglcore.so
    /usr/lib/libnvidia-glcore.so.${NVIDIA_VERSION}                                       /usr/lib/libnvidia-glcore.so
    /usr/lib/libnvidia-glsi.so.${NVIDIA_VERSION}                                         /usr/lib/libnvidia-glsi.so
    /usr/lib/libnvidia-ml.so.${NVIDIA_VERSION}        /usr/lib/libnvidia-ml.so.1         /usr/lib/libnvidia-ml.so
    /usr/lib/libnvidia-tls.so.${NVIDIA_VERSION}                                          /usr/lib/libnvidia-tls.so
    /usr/lib/libvdpau_nvidia.so.${NVIDIA_VERSION}     /usr/lib/libvdpau_nvidia.so.1      /usr/lib/libvdpau_nvidia.so
    /usr/lib/libnvidia-egl-wayland.so.1.1.4           /usr/lib/libnvidia-egl-wayland.so.1 /usr/lib/libnvidia-egl-wayland.so
   #/usr/lib/libnvidia-glvkspirv.so.${NVIDIA_VERSION}                                    /usr/lib/libnvidia-glvkspirv.so

    /usr/lib/xorg/modules/extensions/libglxserver_nvidia.so
    /usr/lib/xorg/modules/extensions/libglxserver_nvidia.so.1
    /usr/lib/xorg/modules/extensions/libglxserver_nvidia.so.${NVIDIA_VERSION}

    /usr/lib/xorg/modules/drivers/nvidia_drv.so

    /usr/share/glvnd/egl_vendor.d/10_nvidia.json
    /usr/share/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf
   #/usr/share/vulkan/implicit_layer.d/nvidia_layers.json
   #/usr/share/vulkan/icd.d/nvidia_icd.i686.json
   #/usr/share/vulkan/icd.d/nvidia_icd.x86_64.json
)

for FILE in ${NVIDIA_FILES[@]}
do
    rm "${TEMP_DIR}/Batocera.PLUS${FILE}"
done

################################################################################

echo 'Desativando servicos...'
mv "${TEMP_DIR}/Batocera.PLUS/etc/init.d/S50triggerhappy" "${TEMP_DIR}/Batocera.PLUS/etc/init.d/K50triggerhappy"

################################################################################

echo 'Copiando arquivos do batocera.plus...'
cp -a "$PLUS_DIR/"*   "${TEMP_DIR}/Batocera.PLUS"
cp -a "$UPDATE_DIR/"* "${TEMP_DIR}/Batocera.PLUS"

################################################################################

### CREATE RAM DISK

echo 'Criando disco ram...'

mkdir -p "${TEMP_DIR}/pkg-xtract"
mount -t tmpfs -o size=2048M tmpfs "${TEMP_DIR}/pkg-xtract"

################################################################################

### INSTALL PKGs

echo 'Install PKGs...'

for PKG in "${URL_BATOCERA_PLUS_PKG[@]}" \
           "${URL_BATOCERA_PLUS_DEV_PKG[@]}"
do
    echo -e "\nInstall ${PKG_NAME%.*}..."
    PKG_NAME="$(basename "${PKG}")"

    7zr x  "${DOWNLOAD_DIR}/${PKG_NAME}" -o"${TEMP_DIR}/pkg-xtract" || exit $?

    # Executa o script batocera.plus que fica dentro do pacote.
    # O script contém instruções expecíficas de instação para o pacote.
    if [ -f "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.*}/batocera.plus" ]; then
        source "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.*}/batocera.plus" || exit $?
        rm -f  "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.*}/batocera.plus" || exit $?
    fi

    cp -a "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.*}/"* "${TEMP_DIR}/Batocera.PLUS" || exit $?
    rm -r "${TEMP_DIR}/pkg-xtract/"*
done

################################################################################

echo 'Install batocera.plus theme...'
PKG_NAME="$(basename "${URL_ES_THEME_A}")"
unzip "${DOWNLOAD_DIR}/${PKG_NAME}" -d "${TEMP_DIR}/pkg-xtract"
cp -a "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.*}" \
      "${TEMP_DIR}/Batocera.PLUS/usr/share/emulationstation/themes/batocera-plus"
rm -r "${TEMP_DIR}/pkg-xtract/"*

echo 'Install Carbon-2.0_PLUS theme...'
PKG_NAME="$(basename "${URL_ES_THEME_B}")"
unzip "${DOWNLOAD_DIR}/${PKG_NAME}" -d "${TEMP_DIR}/pkg-xtract"
cp -a "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.*}" \
      "${TEMP_DIR}/Batocera.PLUS/usr/share/emulationstation/themes/Carbon-2.0_PLUS"
rm -r "${TEMP_DIR}/pkg-xtract/"*

echo 'Install Bezels...'
PKG_NAME="$(basename "${URL_BEZELS}")"
unzip  "${DOWNLOAD_DIR}/${PKG_NAME}" -d "${TEMP_DIR}/pkg-xtract" 2> /dev/null
rm -rf "${TEMP_DIR}/Batocera.PLUS/usr/share/batocera/datainit/decorations/"*
cp -a  "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.*}/"* \
       "${TEMP_DIR}/Batocera.PLUS/usr/share/batocera/datainit/decorations"
rm -r  "${TEMP_DIR}/pkg-xtract/"*

if [ "${ALL_BIOS}" == 'true' ]; then
    echo 'Install All Bios...'
    PKG_NAME="$(basename "${URL_ALL_BIOS}")"
    unzip "${DOWNLOAD_DIR}/${PKG_NAME}" -d "${TEMP_DIR}/pkg-xtract" || exit $?
    cp -a "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.*}/"* \
          "${TEMP_DIR}/Batocera.PLUS/usr/share/batocera/datainit/bios" || exit $?
    rm -r "${TEMP_DIR}/pkg-xtract/"*
fi

echo 'Install GameControllerDB...'
PKG_NAME="$(basename "${URL_GAMECONTROLLERDB}")"
cp -a "${DOWNLOAD_DIR}/${PKG_NAME}" \
      "${TEMP_DIR}/Batocera.PLUS/opt/ControllerDetect/gamecontrollerdb.txt"

echo 'Install SDL2 Gamepad Tool...'
PKG_NAME="$(basename "${URL_GAMEPADTOOLS}")"
mkdir -p "${TEMP_DIR}/Batocera.PLUS/opt/Gamepadtool/bin"
unzip  "${DOWNLOAD_DIR}/${PKG_NAME}" -d "${TEMP_DIR}/pkg-xtract" 2> /dev/null
cp -a "${TEMP_DIR}/pkg-xtract/bin/gamepad-tool" \
      "${TEMP_DIR}/Batocera.PLUS/opt/Gamepadtool/bin"
rm -r "${TEMP_DIR}/pkg-xtract/"*

echo 'Install Music...'
PKG_NAME="$(basename "${URL_MUSIC}")"
unzip "${DOWNLOAD_DIR}/${PKG_NAME}" -d "${TEMP_DIR}/pkg-xtract" || exit $?
rm -rf "${TEMP_DIR}/Batocera.PLUS/usr/share/batocera/music/"*
cp -a  "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.*}/"* \
       "${TEMP_DIR}/Batocera.PLUS/usr/share/batocera/music" || exit $?
rm -r "${TEMP_DIR}/pkg-xtract/"*

echo 'Install SoundFont GeneralUser GS for fluidsynth...'
PKG_NAME="$(basename "${URL_SOUNDFONT_GS}")" 
unzip "${DOWNLOAD_DIR}/${PKG_NAME}" -d "${TEMP_DIR}/pkg-xtract"
mkdir -p "${TEMP_DIR}/Batocera.PLUS/usr/share/soundfonts"
mv "${TEMP_DIR}"/pkg-xtract/GeneralUser*/GeneralUser*.sf2 \
   "${TEMP_DIR}/Batocera.PLUS/usr/share/soundfonts/GeneralUser_GS.sf2"
ln -s GeneralUser_GS.sf2 "${TEMP_DIR}/Batocera.PLUS/usr/share/soundfonts/default.sf2"
rm -r "${TEMP_DIR}/pkg-xtract/"*

echo 'Install MangoHud...'
PKG_NAME="$(basename "${URL_MANGOHUD}")"
gunzip -k "${DOWNLOAD_DIR}/${PKG_NAME}" -c | tar x -v -C "${TEMP_DIR}/pkg-xtract"
tar -xvf "${TEMP_DIR}/pkg-xtract/MangoHud/MangoHud-package.tar" -C "${TEMP_DIR}/pkg-xtract/MangoHud"
mv "${TEMP_DIR}/pkg-xtract/MangoHud/usr/lib/mangohud/lib64" "${TEMP_DIR}/Batocera.PLUS/opt/MangoHud/lib64"
mv "${TEMP_DIR}/pkg-xtract/MangoHud/usr/lib/mangohud/lib32" "${TEMP_DIR}/Batocera.PLUS/opt/MangoHud/lib"
rm -r "${TEMP_DIR}/pkg-xtract/"*

echo 'Install AntiMicroX...'
PKG_NAME="$(basename "${URL_ANTIMICRO}")"
chmod +x "${DOWNLOAD_DIR}/${PKG_NAME}"
mkdir -p "${TEMP_DIR}/pkg-xtract/${PKG_NAME}"
CURRENT_DIR="$(pwd)"
cd "${TEMP_DIR}/pkg-xtract/${PKG_NAME}"
"${CURRENT_DIR}/${DOWNLOAD_DIR}/${PKG_NAME}" --appimage-extract
cd "${CURRENT_DIR}"
unset CURRENT_DIR
mkdir -p "${TEMP_DIR}/Batocera.PLUS/opt/AntiMicroX"
cp -a "${TEMP_DIR}/pkg-xtract/${PKG_NAME}/squashfs-root/usr/bin/antimicrox" "${TEMP_DIR}/Batocera.PLUS/opt/AntiMicroX"
rm -r "${TEMP_DIR}/pkg-xtract/"*

echo 'Install Peazip...'
PKG_NAME="$(basename "${URL_PEAZIP}")"
gunzip -k "${DOWNLOAD_DIR}/${PKG_NAME}" -c | tar x -v -C "${TEMP_DIR}/pkg-xtract"
mkdir -p "${TEMP_DIR}/Batocera.PLUS/opt/Peazip"
cp -a "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.tar.gz}/"* "${TEMP_DIR}/Batocera.PLUS/opt/Peazip"
rm -r "${TEMP_DIR}/pkg-xtract/"*

echo 'Install Java...'
PKG_NAME="$(basename "${URL_JAVA}")"
gunzip -k "${DOWNLOAD_DIR}/${PKG_NAME}" -c | tar x -v -C "${TEMP_DIR}/pkg-xtract"
mv "${TEMP_DIR}/pkg-xtract/jdk"* "${TEMP_DIR}/pkg-xtract/Java"
mv "${TEMP_DIR}/pkg-xtract/Java" "${TEMP_DIR}/Batocera.PLUS/opt"

echo 'Install Cemu...'
PKG_NAME="$(basename "${URL_CEMU%.*}")"
unzip "${DOWNLOAD_DIR}/${PKG_NAME}" -d "${TEMP_DIR}/Batocera.PLUS/opt"
mkdir -p "${TEMP_DIR}/Batocera.PLUS/opt/Cemu/emulator"
rm -r "${TEMP_DIR}/Batocera.PLUS/opt/${PKG_NAME}/graphicPacks"
mv    "${TEMP_DIR}/Batocera.PLUS/opt/${PKG_NAME}/"* "${TEMP_DIR}/Batocera.PLUS/opt/Cemu/emulator"
rm -r "${TEMP_DIR}/Batocera.PLUS/opt/${PKG_NAME}"

echo 'Install CemuHook...'
PKG_NAME="$(basename "${URL_CEMUHOOK%.*}")"
unzip "${DOWNLOAD_DIR}/${PKG_NAME}" -d "${TEMP_DIR}/Batocera.PLUS/opt/${PKG_NAME}"
mkdir -p  "${TEMP_DIR}/Batocera.PLUS/opt/Cemu/cemuhook"
rm -r "${TEMP_DIR}/Batocera.PLUS/opt/${PKG_NAME}/Go to project website for updates.url"
mv "${TEMP_DIR}/Batocera.PLUS/opt/${PKG_NAME}/"* "${TEMP_DIR}/Batocera.PLUS/opt/Cemu/cemuhook"
rmdir "${TEMP_DIR}/Batocera.PLUS/opt/${PKG_NAME}"

echo 'Install pcsx2-mainline...'
PKG_NAME="$(basename "${URL_PCSX2}")"
chmod +x "${DOWNLOAD_DIR}/${PKG_NAME}"
mkdir -p "${TEMP_DIR}/pkg-xtract/${PKG_NAME}" \
         "${TEMP_DIR}/Batocera.PLUS/opt/Pcsx2/pcsx2-mainline/lib"
CURRENT_DIR="$(pwd)"
cd "${TEMP_DIR}/pkg-xtract/${PKG_NAME}"
"${CURRENT_DIR}/${DOWNLOAD_DIR}/${PKG_NAME}" --appimage-extract
cd "${CURRENT_DIR}"
unset CURRENT_DIR
mv "${TEMP_DIR}/pkg-xtract/${PKG_NAME}/squashfs-root/usr/bin/pcsx2" "${TEMP_DIR}/Batocera.PLUS/opt/Pcsx2/pcsx2-mainline/PCSX2"
sed -i 's|../share|pcsx2_rc|'                                       "${TEMP_DIR}/Batocera.PLUS/opt/Pcsx2/pcsx2-mainline/PCSX2"
mv "${TEMP_DIR}/pkg-xtract/${PKG_NAME}/squashfs-root/usr/share"     "${TEMP_DIR}/Batocera.PLUS/opt/Pcsx2/pcsx2-mainline/pcsx2_rc"
PCSX2_FILES=(
    libjbig       libnotify         libtiff            libgdk-3
    libgtk-3      libatk-bridge-2   libatspi           libpcap
    libwx_baseu-3 libwx_gtk3u_adv-3 libwx_gtk3u_core-3 libwebp
)
for FILE in ${PCSX2_FILES[@]}; do
    cp -a "${TEMP_DIR}/pkg-xtract/${PKG_NAME}/squashfs-root/usr/lib/${FILE}."* "${TEMP_DIR}/Batocera.PLUS/opt/Pcsx2/pcsx2-mainline/lib"
done
rm -r "${TEMP_DIR}/pkg-xtract/"*

echo 'Install RPCS3...'
PKG_NAME="$(basename "${URL_RPCS3}")"
chmod +x "${DOWNLOAD_DIR}/${PKG_NAME}"
mkdir -p "${TEMP_DIR}/pkg-xtract/${PKG_NAME}"
CURRENT_DIR="$(pwd)"
cd "${TEMP_DIR}/pkg-xtract/${PKG_NAME}"
"${CURRENT_DIR}/${DOWNLOAD_DIR}/${PKG_NAME}" --appimage-extract
cd "${CURRENT_DIR}"
unset CURRENT_DIR
mkdir -p "${TEMP_DIR}/Batocera.PLUS/opt/Rpcs3/bin"
cp -a "${TEMP_DIR}/pkg-xtract/${PKG_NAME}/squashfs-root/usr/bin/"*  "${TEMP_DIR}/Batocera.PLUS/opt/Rpcs3/bin"
mkdir -p "${TEMP_DIR}/Batocera.PLUS/opt/Rpcs3/lib"
cp -a "${TEMP_DIR}/pkg-xtract/${PKG_NAME}/squashfs-root/usr/optional/libstdc++/libstdc++."* "${TEMP_DIR}/Batocera.PLUS/opt/Rpcs3/lib"
RPCS3_FILES=(
    libGLEW          libcurl           liblber-2     libxcb-icccm
    libQt5Concurrent libgssapi         libldap_r-2   libxcb-image
    libQt5Core       libgssapi_krb5    libnghttp2    libxcb-keysyms
    libQt5DBus       libhcrypto        libnsl        libxcb-randr
    libQt5Gui        libheimbase       libpsl        libxcb-render-util
    libQt5Multimedia libheimntlm       libxcb-render libQt5MultimediaGstTools
    libhx509         libpulsecommon-11 libxcb-shape  libQt5MultimediaWidgets
    libicudata       libroken          libxcb-shm    libQt5Network
    libicui18n       libsasl2          libxcb-sync   libQt5Svg
    libicuuc         libxcb-util       libQt5Widgets libidn2
    libsystemd       libxcb-xfixes     libQt5XcbQpa  libk5crypto
    libtinfo         libxcb-xinerama   libapparmor   libkeyutils
    libunistring     libxcb-xinput     libasn1       libkrb5
    libwind          libxcb-xkb        libkrb5       libwrap
    libasyncns       libkrb5support    libxcb-glx    libSDL2-2
)
for FILE in ${RPCS3_FILES[@]}
do
    cp -a "${TEMP_DIR}/pkg-xtract/${PKG_NAME}/squashfs-root/usr/lib/${FILE}."* "${TEMP_DIR}/Batocera.PLUS/opt/Rpcs3/lib"
done
cp -a "${TEMP_DIR}/pkg-xtract/${PKG_NAME}/squashfs-root/usr/plugins"        "${TEMP_DIR}/Batocera.PLUS/opt/Rpcs3"
rm -r "${TEMP_DIR}/pkg-xtract/"*

echo 'Install Ryujinx...'
PKG_NAME="$(basename "${URL_RYUJINX}")"
gunzip -k "${DOWNLOAD_DIR}/${PKG_NAME}" -c | tar x -v -C "${TEMP_DIR}/pkg-xtract"
rm "${TEMP_DIR}/pkg-xtract/publish/THIRDPARTY.md"
cp -a "${TEMP_DIR}/pkg-xtract/publish" "${TEMP_DIR}/Batocera.PLUS/opt/Ryujinx"
chmod +x "${TEMP_DIR}/Batocera.PLUS/opt/Ryujinx/publish/Ryujinx"

echo 'Install Nvidia Driver...'
PKG_NAME="$(basename "${URL_NVIDIA_DRIVER}")"
chmod +x "${DOWNLOAD_DIR}/${PKG_NAME}"
"${DOWNLOAD_DIR}/${PKG_NAME}" -x --target "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.run}"
mkdir -p "${TEMP_DIR}/Batocera.PLUS/usr/share/nvidia"
cp -a "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.run}/nvidia-settings"               "${TEMP_DIR}/Batocera.PLUS/usr/bin"
cp -a "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.run}/nvidia-application-profiles-"* "${TEMP_DIR}/Batocera.PLUS/usr/share/nvidia"
cp -a "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.run}/libnvidia-gtk2.so."*           "${TEMP_DIR}/Batocera.PLUS/usr/lib"
cp -a "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.run}/libnvidia-gtk3.so."*           "${TEMP_DIR}/Batocera.PLUS/usr/lib"
cp -a "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.run}/libnvidia-encode.so."*         "${TEMP_DIR}/Batocera.PLUS/usr/lib/"
cp -a "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.run}/libnvcuvid.so."*               "${TEMP_DIR}/Batocera.PLUS/usr/lib/libnvcuvid.so.1"
echo 'Create udev rules to Nvidia Driver ...'
"${SCRIPT_DIR}/nvidia-driver-udev-rules.sh" \
    "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.run}/supported-gpus/supported-gpus.json" \
    "${TEMP_DIR}/Batocera.PLUS/etc/udev/rules.d/01-nvidia-driver.rules"
rm -r "${TEMP_DIR}/pkg-xtract/"*

echo 'Update Linux firmware...'
# https://github.com/batocera-linux/batocera.linux/blob/master/package/batocera/firmwares/alllinuxfirmwares/alllinuxfirmwares.mk
PKG_NAME="$(basename "${URL_LINUX_FIRMWARE}")"
gunzip -k "${DOWNLOAD_DIR}/${PKG_NAME}" -c | tar x -v -C "${TEMP_DIR}/pkg-xtract"
rm -rf             "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.tar.gz}/liquidio"
rm -rf             "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.tar.gz}/netronome"
rm -rf             "${TEMP_DIR}/Batocera.PLUS/lib/firmware/"*
cd                 "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.tar.gz}"
./copy-firmware.sh "../../Batocera.PLUS/lib/firmware"
cd -
rm -rf             "${TEMP_DIR}/pkg-xtract/"*

echo 'Install pci ids database...'
PKG_NAME="$(basename "${URL_PCI_IDS}")"
mkdir -p  "${TEMP_DIR}/Batocera.PLUS/usr/share/hwdata"
cp -a     "${DOWNLOAD_DIR}/${PKG_NAME}"      "${TEMP_DIR}/Batocera.PLUS/usr/share/pci.ids.gz"
gunzip -k "${DOWNLOAD_DIR}/${PKG_NAME}" -c > "${TEMP_DIR}/Batocera.PLUS/usr/share/hwdata/pci.ids"
ln -sf    '/usr/share/hwdata/pci.ids'        "${TEMP_DIR}/Batocera.PLUS/usr/share/pci.ids"

################################################################################

### DROP RAM DISK

sync
umount "${TEMP_DIR}/pkg-xtract/"

################################################################################

### PATCH

echo 'Aplicando Patch...'
cp -a "${TEMP_DIR}/Batocera.PLUS/etc/samba/smb.conf" "${TEMP_DIR}/Batocera.PLUS/etc/samba/smb-ps2smb.conf"
for i in $(du -a "${PATCH_DIR}" | grep -F '.patch' | awk '{print $2}' | sed "s#${PATCH_DIR}/##"); do
    patch -p1 "${TEMP_DIR}/Batocera.PLUS/${i%.patch}" "${PATCH_DIR}/${i}" || exit $?
done

################################################################################

### VERSION FILE

echo 'Criando arquivo de versão do Batocera.PLUS...'
mv   "${TEMP_DIR}/Batocera.PLUS/usr/share/batocera/batocera.version" "${TEMP_DIR}/Batocera.PLUS/usr/share/batocera/recalbox.version"
echo "${VERSION} $(date +'%Y/%m/%d %H:%M')" >                        "${TEMP_DIR}/Batocera.PLUS/usr/share/batocera/batocera.version"

echo 'Adicionando versão BATOCERA.PLUS no ES'
sed -i 's/BATOCERA.LINUX/BATOCERA.PLUS /' "${TEMP_DIR}/Batocera.PLUS/usr/bin/emulationstation"

################################################################################

### COMPRESS SQUASHFS

echo 'Compactando arquivo squashfs...'

case ${SQUASHFS_COMPRESSION} in
    1)
        mksquashfs "${TEMP_DIR}/Batocera.PLUS" "${TEMP_DIR}/batocera" || exit $?
        ;;
    2)
        mksquashfs "${TEMP_DIR}/Batocera.PLUS" "${TEMP_DIR}/batocera" -b 512k -comp zstd -Xcompression-level 15 || exit $?
        ;;
    3)
        mksquashfs "${TEMP_DIR}/Batocera.PLUS" "${TEMP_DIR}/batocera" -b 1M -comp xz -Xdict-size 100% || exit $?
        ;;
esac

################################################################################

echo 'Descompactando imagem do BatoceraZero...'
7zr x "${DOWNLOAD_DIR}/${BATOCERA_ZERO}" -o"${TEMP_DIR}"

echo 'Adicionando imagem BatoceraZero ao dispositivo loop...'
losetup -o $((512 * 2048)) /dev/loop6 "${TEMP_DIR}/BatoceraZero.img"

echo 'Montando imagem do BatoceraZero...'
mkdir "${TEMP_DIR}/BatoceraZero"
mount /dev/loop6 "${TEMP_DIR}/BatoceraZero"

echo 'Movendo arquivo compactado squashfs para BatoceraZero...'
rm "${TEMP_DIR}/Batocera.Linux/boot/batocera"
mv "${TEMP_DIR}/batocera" "${TEMP_DIR}/BatoceraZero/boot/batocera"

echo 'Copiando arquivos da pasta boot para o BatoceraZero...'
rm    "${TEMP_DIR}/Batocera.Linux/boot/syslinux/ldlinux.sys"
cp -a "${TEMP_DIR}/Batocera.Linux/"* "${TEMP_DIR}/BatoceraZero"

echo 'Copiando arquivos extras para o BatoceraZero...'
cp -a "$BOOT_DIR/"* "${TEMP_DIR}/BatoceraZero"

#echo 'Copiando programas de windows (tools) para o BatoceraZero...'
#PKG_NAME="$(basename "${URL_WINDOWS_TOOLS}")"
#unzip  "${DOWNLOAD_DIR}/${PKG_NAME}" -d "${TEMP_DIR}/pkg-xtract" || exit $?
#cp -a  "${TEMP_DIR}/pkg-xtract/${PKG_NAME%.*}/"* \
#       "${TEMP_DIR}/BatoceraZero/tools" || exit $?
#rm -r  "${TEMP_DIR}/pkg-xtract/"*

# Remova a linha à baixo (mv) em uma futura atualização.
mv -f "${TEMP_DIR}/linux" "${TEMP_DIR}/BatoceraZero/boot"

################################################################################

### EDIT batocera-boot.conf

echo 'Editando arquivo batocera-boot.conf...'
echo "$(
    while read FILE; do
        echo "${FILE}"
        if [ "$(echo "${FILE}" | grep 'autoresize=')" ]; then
            echo
            echo '# zram size in percent 0=disable (remove the # to enable it)'
            echo 'zram=50'
            echo
            echo '# use swap partition, example: swap.partition=/dev/sda3 (remove the # to enable it)'
            echo 'swap.partition=auto'
            echo
            echo '# create swapfile, 1024=1GB, example: swap.file.size=1024 (remove the # to enable it)'
            echo '#swap.file.size=auto'
            echo
            echo '# enable the splash video on startup /userdata/splashvideo (remove the # to enable video)'
            echo '#splash.video=true'
            echo
            echo '# video resolution, open a terminal (Win + F4) type xrandr to see all supported resolutions'
            echo '#global.videomode=1280x720'
            echo
            echo '# playstation dualshock 4 led colors, red green blue values accept [0 - 255], example: 20 40 255'
            echo '#dualshock4-led-colors=0 0 0'
            echo
            echo "# radeon-prime enables the amd-radeon gpu over the intel gpu in case you've an amd-radeon hybrid gpu"
            echo '#radeon-prime=true'
        fi
    done < "${TEMP_DIR}/BatoceraZero/batocera-boot.conf"
)" > "${TEMP_DIR}/BatoceraZero/batocera-boot.conf"

sed -i 's/^# enable the nvidia driver.*/# enable the nvidia driver (auto, last, 470, 390, 340, false)/' "${TEMP_DIR}/BatoceraZero/batocera-boot.conf"
sed -i 's/^#nvidia-driver=true$/nvidia-driver=auto/'                                                    "${TEMP_DIR}/BatoceraZero/batocera-boot.conf"

################################################################################

### UMOUNT ALL IMAGES

sync

echo 'Desmontando imagens...'
umount /dev/loop7
umount /dev/loop6

echo 'Removendo imagens dos disposivos loop...'
losetup -d /dev/loop7
losetup -d /dev/loop6

sync

################################################################################

mv "${TEMP_DIR}/BatoceraZero.img" "${TEMP_DIR}/Batocera.PLUS.img"

if [ "${RELEASE}" ]; then
    echo 'Copiando arquivos extra para a release...'
    cp -a  "${BOOT_DIR}/batocera-hd-edition/grub.cfg"                "${TEMP_DIR}"                       || exit $?
    cp -a  "${BOOT_DIR}/batocera-hd-edition/leia-me.txt"             "${TEMP_DIR}/dualboot-leia-me.txt"  || exit $?
   #cp -a  "whatsnew.txt"                                            "${TEMP_DIR}"                       || exit $?
   #sed -i "1s/^/#### Batocera.PLUS-${VERSION}-${RELEASE} ####\n\n/" "${TEMP_DIR}/whatsnew.txt"          || exit $?

    echo 'Compactando imagem final...'
    7zr a -m0=lzma2 -mx=9 -myx=9 -md=256M -mfb=256 -ms=on -mmt=on "${TEMP_DIR}/Batocera.PLUS-${VERSION}-${RELEASE}.7z" "${TEMP_DIR}/Batocera.PLUS.img" || exit $?

    echo 'Gerando Md5sum...'
    md5sum "${TEMP_DIR}/Batocera.PLUS-${VERSION}-${RELEASE}.7z" | cut -d ' ' -f 1 >> "${TEMP_DIR}/md5sum.txt" || exit $?
fi

################################################################################

### CLEAR

echo 'Removendo arquivos temporários...'
rmdir "${TEMP_DIR}/Batocera.Linux"
rmdir "${TEMP_DIR}/BatoceraZero"
rm -r "${TEMP_DIR}/Batocera.PLUS"
rm    "${TEMP_DIR}/Batocera.Linux.img"
rmdir "${TEMP_DIR}/pkg-xtract"
if [ "${RELEASE}" ]; then
    rm -r "${TEMP_DIR}/Batocera.PLUS.img"  || exit $?
fi

sync

echo 'IMAGEM CRIADA COM SUCESSO!'

exit 0
