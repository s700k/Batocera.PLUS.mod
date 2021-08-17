#!/bin/bash
##
## Batocera.PLUS
##
## Código escrito por: Sérgio de Carvalho Júnior
## Supervisão: Alexandre Freire dos Santos
##
################################################################################

### DIRECTORIES, FILES AND PARAMETERS

GAME="${1}"
P1GUID="${2}"

RPCS3_DIR=/opt/Rpcs3
HOME_DIR="${HOME}/configs/rpcs3"
SAVE_DIR=/userdata/saves

if [ "$(pidof rpcs3)" ]; then
   echo ' RPCS3 launcher ja está em execução'
   exit 1
fi

################################################################################
### FUNCTIONS

function xdg-mime() { :; }

function CreateFolders()
{
   mkdir -p "${HOME_DIR}/.config/rpcs3/GuiConfigs" \
            "${HOME_DIR}/.config/rpcs3/dev_hdd0/home/00000001" \
            "${HOME_DIR}/dev_hdd0/home/00000001/savedata" \
            "${HOME_DIR}/dev_hdd0/home/00000001/trophy" \
            "${HOME_DIR}/dev_hdd0/home/00000001/exdata" \
            "${HOME_DIR}/dev_hdd0/game" \
            "${HOME_DIR}/dev_flash" \
            "${SAVE_DIR}/rpcs3"

   ln -sf "${HOME_DIR}/dev_hdd0/home/00000001/savedata" "${HOME_DIR}/.config/rpcs3/dev_hdd0/home/00000001"
   ln -sf "${HOME_DIR}/dev_hdd0/home/00000001/trophy" "${HOME_DIR}/.config/rpcs3/dev_hdd0/home/00000001"
   ln -sf "${HOME_DIR}/dev_hdd0/home/00000001/exdata" "${HOME_DIR}/.config/rpcs3/dev_hdd0/home/00000001"
   ln -sf "/usr/share/rpcs3/GuiConfigs/"* "${HOME_DIR}/.config/rpcs3/GuiConfigs"
   ln -sf "${HOME_DIR}/dev_hdd0/game" "${HOME_DIR}/.config/rpcs3/dev_hdd0/"
   ln -sf /usr/share/rpcs3/Icons "${HOME_DIR}/.config/rpcs3"
   ln -sf "${HOME_DIR}/dev_flash" "${HOME_DIR}/.config/rpcs3"

   if [ -e "${HOME_DIR}/games.yml" ];then
      cp -f "${HOME_DIR}/games.yml" "${HOME_DIR}/.config/rpcs3"
   fi
}

function CreateConfigs()
{
   touch "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini" \
         "${HOME_DIR}/.config/rpcs3/config.yml"

   echo '[GameList]' >> "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini"
   echo 'hidden_list=@Invalid()' >> "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini"
   echo 'iconColor=@Variant(\0\0\0\x43\x1\xff\xff\xf0\xf0\xf0\xf0\xf0\xf0\0\0)' >> "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini"
   echo 'marginFactor=0.09' >> "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini"
   echo 'textFactor=2' >> "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini"
   echo '[Localization]' >> "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini"
   echo 'language=en' >> "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini"
   echo '[Meta]' >> "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini"
   echo 'currentStylesheet=Skyline' >> "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini"
   echo 'showDebugTab=true' >> "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini"
   echo 'useRichPresence=true' >> "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini"
   echo 'discordState=' >> "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini"
   echo '[Logger]' >> "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini"
   echo 'level=4' >> "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini"
   echo 'stack=true' >> "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini"
   echo '[main_window]' >> "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini"
   echo 'confirmationBoxExitGame=false' >> "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini"
   echo 'infoBoxEnabledInstallPUP=false' >> "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini"
   echo 'infoBoxEnabledWelcome=false' >> "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini"
   echo 'lastExplorePathPUP=/userdata/system/../bios' >> "${HOME_DIR}/.config/rpcs3/GuiConfigs/CurrentSettings.ini"

   echo 'Miscellaneous:' >> "${HOME_DIR}/.config/rpcs3/config.yml"
   echo '  Exit RPCS3 when process finishes: true' >> "${HOME_DIR}/.config/rpcs3/config.yml"
   echo '  Start games in fullscreen mode: true' >> "${HOME_DIR}/.config/rpcs3/config.yml"
}

function TextLocalization()
{
   LANG="$(batocera-settings -command load -key system.language)"
   case $LANG in
      pt_BR) MSG[1]='\n NENHUMA CONFIGURAÇÃO DE CONTROLE FOI FEITA, FAÇA UMA ANTES DE EXECUTAR O JOGO. \n'
             MSG[2]='\n NENHUM FIRMWARE FOI INSTALADO, INSTALE ANTES DE EXECUTAR O JOGO. \n'
             MSG[3]='\n ESCOLHA UMA OPÇÃO. \n' ;;
      es_ES) MSG[1]='\n NO SE HAN REALIZADO AJUSTES DE CONTROL, HAGA UNO ANTES DE EJECUTAR EL JUEGO. \n'
             MSG[2]='\n NO SE HA INSTALADO FIRMWARE, INSTALAR ANTES DE EJECUTAR UN JUEGO. \n'
             MSG[3]='\n ESCOGE UNA OPCIÓN. \n' ;;
      *)     MSG[1]='\n NO CONTROLLER CONFIG HAS BEEN MADE, MAKE ONE BEFORE RUN A GAME.\n'
             MSG[2]='\n NO FIRMWARE HAS BEEN INSTALLED, INSTALL BEFORE RUN A GAME. \n'
             MSG[3]='\n CHOOSE A OPTION. \n'
   esac
}

function ControllerWarning()
{
   yad --form \
   --title='WARNING' \
   --window-icon='/usr/share/icons/batocera/rpcs3.png' \
   --text=''"${MSG[1]}"'' \
   --undecorated \
   --text-align=center \
   --on-top \
   --fixed \
   --center \
   --no-escape \
   --timeout=3 \
   --no-buttons &
   exit 0
}

function FimwareWarning()
{
   yad --form \
   --title='WARNING' \
   --window-icon='/usr/share/icons/batocera/rpcs3.png' \
   --text=''"${MSG[2]}"'' \
   --undecorated \
   --text-align=center \
   --on-top \
   --fixed \
   --center \
   --no-escape \
   --timeout=3 \
   --no-buttons &
   exit 0
}

function choseEmu()
{
    yad --form \
    --title='RPCS3 CONFIGURATOR' \
    --window-icon='/usr/share/icons/batocera/rpcs3.png' \
    --text=''"${MSG[3]}"'' \
    --text-align=center \
    --button='RPCS3:0' \
    --button='RPCS3-MAINLINE:1' \
    --fixed \
    --center \
    --close-on-unfocus

    case ${?} in
        0) exec /usr/bin/batocera-config-rpcs3 ;;
        1) GUI='1' ;;
        *) exit 0
    esac
}

function help()
{
   echo ' Linha de comando:'
   echo ' rpcs3.sh [ROM] [P1GUID]'
   echo
   echo ' ROM          = Caminho do jogo até a pasta do jogo'
   echo ' PIGUID       = parâmetro do emulatorlauncher.sh (OPICIONAL)'
   echo
}

################################################################################
### LAUNCHER INFO

echo
echo ' RPCS3 launcher for Batocera.PLUS'
echo
echo ' Codigo escrito por: Sérgio de Carvalho Júnior'
echo ' Supervisão: Alexandre Freire dos Santos'
echo

################################################################################
### CALL HELP

if [ "${GAME}" == '--help' ]; then
   help
   exit 0
fi

################################################################################
### MENU

if [ ! -e "${GAME}" ] && [ ! -e "${P1GUID}" ]; then
   TextLocalization
   choseEmu
fi

################################################################################
### BUILD FOLDERS AND FILES

if [ ! "$(ls -A "${HOME_DIR}/.config/rpcs3" 2> /dev/null)" ] || [ ! "$(ls -A "${SAVE_DIR}/rpcs3"  2> /dev/null)" ]; then
   CreateFolders
   CreateConfigs
fi

if [ ! -f "${HOME_DIR}/.config/rpcs3/config_input.yml" ] && [ "${GAME}" != '' ]; then
   TextLocalization
   ControllerWarning
fi

if [ ! -d "${SAVE_DIR}/rpcs3/cache/ppu-ogZ9XMwLZb70cCsiaswxN1kKG5ts-libpngenc.sprx" ] && [ "${GAME}" != '' ]; then
   TextLocalization
   FimwareWarning
fi

################################################################################
### HOTKEY

if [ "${P1GUID}" ]; then

   BOTOES="$(${RPCS3_DIR}/getHotkeyStart ${P1GUID})"
   BOTAO_HOTKEY=$(echo "${BOTOES}" | cut -d ' ' -f 1)
   BOTAO_START=$(echo  "${BOTOES}" | cut -d ' ' -f 2)

   if [ "${BOTAO_HOTKEY}" ] && [ "${BOTAO_START}" ]; then
      # Impede que o xjoykill seja encerrado enquanto o jogo está em execução.
      while : ; do
         nice -n 20 xjoykill -hotkey ${BOTAO_HOTKEY} -start ${BOTAO_START} -kill "${RPCS3_DIR}/killrpcs3"
         if ! [ "$(pidof rpcs3)" ]; then
            break
         fi
         sleep 5
      done &
   fi
fi

################################################################################
### EXPORTS

export HOME="${HOME_DIR}"
export LD_LIBRARY_PATH="${RPCS3_DIR}/lib:${LD_LIBRARY_PATH}"
export QT_QPA_PLATFORM=xcb
export QT_PLUGIN_PATH="${RPCS3_DIR}/plugins"
export XDG_RUNTIME_DIR=/run/root
export XDG_CACHE_HOME="${SAVE_DIR}"
export -f xdg-mime

################################################################################
### RUN

if [ -e "${GAME}" ]; then
   ${MANGOHUD_CMD} "${RPCS3_DIR}/bin/rpcs3" "${GAME}/PS3_GAME/USRDIR/EBOOT.BIN"
elif [ "${GUI}" ]; then
   "${RPCS3_DIR}/bin/rpcs3"
fi


################################################################################
### CLOSE XJOYKILL

if [ "$(pidof -s xjoykill)" ]; then
   killall -9 xjoykill
fi

################################################################################
### WAIT RPCS3 TO FINISH

if [ "$(pidof rpcs3)" ]; then
   sleep 1
fi

exit 0
