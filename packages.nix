{ pkgs, inputs, ... }:
let
nix-citizen = inputs.nix-citizen.packages.${pkgs.system};
in

{
  #programs.ladybird.enable = true;
  #programs.corectrl.enable = true;
  programs.git.enable = true;
  programs.ryzen-monitor-ng.enable = true;
  programs.gamemode.enable = true;
  programs.gamemode.enableRenice = true;

  programs.fish = 
	{
	enable = true;
	shellAliases = { nixupgrade = "sudo nice -n 4 nix flake update --flake /etc/nixos/ && sudo nice -n 4 nixos-rebuild switch --show-trace"; };
	};
  programs.thunderbird.enable = true;

#Temp allow youtube-dl for tartube. Should be fixed soon

              nixpkgs.config.permittedInsecurePackages = [
                "python3.12-youtube-dl-2021.12.17"
              ];

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [

# inputs.nix-citizen.packages.${pkgs.system}.star-citizen
  nix-citizen.lug-helper
  #vulkanHdrLayer #this is the expiremental vulkan hdr layer to enable HDR on many applications until proper support is otherwise implemented.
  #pkgs.sunshine
  #pkgs.steamcmd
  pkgs.cudaPackages.cudatoolkit
  pkgs.jq #Used to generate tree files for website.
#  pkgs.libaom
  pkgs.xterm
  pkgs.fbvnc
  pkgs.git-ps-rs
  pkgs.git-revise
  pkgs.rimsort
  pkgs.libvmaf
  pkgs.lf
  pkgs.nvitop
  pkgs.kitty
  pkgs.nsz
  pkgs.obconf
  pkgs.stable.fooyin #Foobar2k clone
  pkgs.glava
  pkgs.catnip
  pkgs.svt-av1-psy
  pkgs.av1an
  pkgs.handbrake
# pkgs.nexusmods-app-unfree

  pkgs.openssl
  pkgs.partimage
  pkgs.glfw3-minecraft #This provides proper wayland support for GLFW for Minecraft.
  pkgs.socat

  pkgs.nvidia-vaapi-driver #Third party NVidia VAAPI driver. Also defined in graphics packages? Hopefully it works more? Iunno

  #nix-software-center
  #inputs.nix-software-center.packages.${system}.nix-software-center
  #nixos-conf-editor
  #KDE stuff
# pkgs.styx
  pkgs.zola
  pkgs.neofetch
  pkgs.kdePackages.kate
  pkgs.kdePackages.krfb
# pkgs.gamescope-wsi #Maybe if I define it here it will work? Who knows.

  pkgs.kdePackages.partitionmanager
  pkgs.kdePackages.kpmcore
  pkgs.wineWowPackages.waylandFull
  pkgs.winetricks
  pkgs.kdePackages.plasma-workspace
  pkgs.kdePackages.kdesu
  pkgs.kdePackages.purpose
  pkgs.kdePackages.sddm-kcm
  pkgs.polkit
  pkgs.cheese
  pkgs.kdePackages.kdenlive
  pkgs.kdePackages.polkit-kde-agent-1
  pkgs.kdePackages.kauth
  pkgs.kdePackages.kio
#  pkgs.kdePackages.k3b
  pkgs.kdePackages.kio-extras
  pkgs.kdePackages.discover
  pkgs.brasero
#  pkgs.gimp Broken as of 10/14
  pkgs.dvdplusrwtools
  pkgs.cdrtools
  pkgs.pwvucontrol
  pkgs.coppwr
# pkgs.ventoy-full
  pkgs.rbdoom-3-bfg
  pkgs.kdePackages.ktexteditor
#  nix-citizen.star-citizen


  nix-citizen.star-citizen-umu
#  (nix-citizen.star-citizen.override {
#	protonPath = "Ge-Proton";
#	})
 
  #OpenRGB Plugins
  pkgs.openrgb-plugin-effects
  pkgs.openrgb-plugin-hardwaresync

  #Fix for some applications presuming the presence of the Thai language...
  pkgs.libthai


  #lutris
 # pkgs.lutris #Flatpak is bork

  (lutris.override {
      extraLibraries =  pkgs: [
        pkgs.dxvk
        pkgs.vkd3d
        pkgs.vkd3d-proton
        pkgs.stable.gamescope
      ];
    })

  pkgs.sqlite #required for vortex mm
  pkgs.openal #required by BAR
  #nix-gaming.packages.${pkgs.system}.faf-client

  #for appimages
  pkgs.appimage-run

  #Java VMs
  pkgs.jdk
  pkgs.jdk8
  pkgs.jdk17
  pkgs.temurin-jre-bin-17

  #top alternative(s)
  pkgs.bottom
  pkgs.btop

  #gameconqueror stuff.
  pkgs.stable.scanmem

  pkgs.pv

  #MPV applications
  pkgs.mpv
  pkgs.mpvScripts.thumbnail
  pkgs.asunder
  pkgs.rubyripper
  pkgs.deadbeef-with-plugins

  #Jellyfin dependencies and tools
  pkgs.makemkv
  pkgs.libdvdcss
  pkgs.libbdplus
  pkgs.libaacs

  #Libreoffice
  pkgs.libreoffice-qt
  pkgs.hunspell
  pkgs.hunspellDicts.en_US-large
  #pkgs.hunspellDicts.jp_JP no JP dictionary :(

  #Miscellaneous
# pkgs.git
  pkgs.prismlauncher
  pkgs.qdirstat
  pkgs.yt-dlp
  pkgs.tartube-yt-dlp
  pkgs.protonup-qt
  pkgs.steamtinkerlaunch
  pkgs.unrar
  pkgs.stable.mkvtoolnix
  pkgs.udftools
  pkgs.ffmpeg-full
#  pkgs.handbrake Using Flatpak for stability, AV1 encoding seems to be fucked for some reason.
  pkgs.mediainfo-gui
  pkgs.protontricks
  pkgs.cabextract
  pkgs.jq
  pkgs.vim
  pkgs.patch
  pkgs.xorg.libXcomposite
  pkgs.freetype
  pkgs.gh
  pkgs.mono
  pkgs.openal
  pkgs.libsForQt5.kcalc
  pkgs.vlc
  pkgs.ryubing
# pkgs.torzu
  pkgs.python3
  pkgs.solaar
  pkgs.logitech-udev-rules
  pkgs.transmission_4-qt
  pkgs.deluged
  pkgs.media-downloader
  pkgs.floorp

  #Steamtinkerlaunch
  pkgs.unzip
  pkgs.wget
  pkgs.xdotool
  pkgs.unixtools.xxd
  pkgs.yad
  pkgs.xorg.xwininfo

  #Minecraft Server
  #pkgs.minecraft-server #it's not really useful to have this anymore.

  #Wireguard tools.
  wireguard-tools

  #Kodi Packages ||NOW DEFINED PROPERLY IN configuration.nix||
  /*
  pkgs.kodi-gbm
  pkgs.kodiPackages.libretro
  pkgs.kodiPackages.jellyfin
  pkgs.kodiPackages.steam-library
  pkgs.kodiPackages.inputstreamhelper
  pkgs.kodiPackages.inputstream-adaptive
  pkgs.kodiPackages.visualization-goom
  pkgs.kodiPackages.visualization-matrix
  pkgs.kodiPackages.visualization-projectm
  pkgs.kodiPackages.visualization-starburst
  pkgs.kodiPackages.inputstream-ffmpegdirect
  */
  #NVIDIA VA-API
  #pkgs.nvidia-vaapi-driver

  #OBS
  pkgs.obs-studio
  pkgs.obs-studio-plugins.obs-vaapi
  #pkgs.obs-studio-plugins.obs-nvfbc
  #pkgs.obs-studio-plugins.obs-vkcapture


  ];
  
}
