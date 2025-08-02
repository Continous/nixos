# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
{
  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

 # enable Nix Flakes and the new nix-command command line tool
 nix.settings.experimental-features = [ "nix-command" "flakes" ];
 nixpkgs.config.allowUnfree = true;
#  system.autoUpgrade = {
#	enable = true;
#	flake = "/etc/nixos/flake.nix";
#	flags = [
#	"--update-input"
#	"nixpkgs"
#	"--print-build-logs"
#	"--cores 4"
#	];
#	dates = "daily";
#	randomizedDelaySec = "45min";
#	persistent = true;
#	
#};

 # AMD Ryzen config

   hardware.cpu.amd = {
	ryzen-smu.enable = true;
	updateMicrocode = true;
   };
   hardware.enableAllFirmware = true;
   hardware.i2c.enable = true;

 # enable sensible optimizations and garbage collection.

# systemd.extraConfig = "DefaultLimitNOFILE=524288";

 nix.settings.auto-optimise-store = true;
 nix.settings.max-jobs = "auto"; #Allows more than one job to run at a time.
 nix.gc = {
	automatic = true;
	dates = "weekly";
	options = "--delete-older-than 14d";
 };

 nixpkgs.config.cudaSupport = true;

 nix.settings = { #This enables cachix
    substituters = ["https://nix-gaming.cachix.org"];
    trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
  };



  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  #Enable Logitech crap
#  hardware.logitech = {
#  wireless.enable = true;
#  wireless.enableGraphical = true;
#  lcd.enable = true;
#  lcd.startWhenNeeded = true;
#  };

  #Shell Aliases

  # Enable tmux for terminal multiplexing.
  programs.tmux = {
  enable = true;
#  newSession = true;
  };


  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Enable the Desktop Environments.
  #
  # SDDM for Loginserver
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.enableHidpi = true;
  services.xserver.windowManager.openbox.enable = true;
  services.displayManager.sddm.wayland.enable = true; #This just breaks shit really.
#  services.displayManager.sddm.wayland.compositor = "kwin";
#  services.xserver.displayManager.lightdm.enable = true;
  # Enable the Hyprland Desktop Environment
#  services.xserver.desktopManager.gnome.enable = true;
#  programs.hyprland.enable = true;
  #Kodi and it's associated packages.
  services.xserver.desktopManager.kodi.enable = true;
  services.xserver.desktopManager.kodi.package =
  pkgs.kodi.withPackages (pkgs: with pkgs; [
  jellyfin
  libretro steam-library
  inputstreamhelper
  inputstream-adaptive
  visualization-goom
  visualization-matrix
  visualization-projectm
  visualization-starburst
  #inputstream-ffmpegdirect broken for some reason?
  ]);


  #Plasma 5, it's packages are defined elsewhere because they're also useful outside of KDE/Plasma.
  #services.xserver.desktopManager.plasma5.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.desktopManager.plasma6.enableQt5Integration = true;
#  programs.wayfire.enable = true;
#  programs.wayfire.plugins = with pkgs.wayfirePlugins; [ wcm wf-shell wayfire-plugins-extra ];
  programs.kdeconnect.enable = true;
#  services.displayManager.defaultSession = "plasma";
  services.xserver.videoDrivers = [ "nvidia" ];
  security.polkit.enable = true;
  programs.xwayland.enable = true;

  services.power-profiles-daemon.enable = true; #This enables governor tweaking.

  #Confingue NVidia's mess.

    #Enabling hardware.graphics doesn't not enable graphics hardware, but instead enables CPU software graphics. Likely a bug resulting from this supposing to be enabled automatically by enabling Nvidia...No I don't get it.

/*  hardware.graphics = {

	enable = true;
	enable32Bit = true;
	extraPackages = with pkgs; [
		nvidia-vaapi-driver
		libvdpau-va-gl
		vaapiVdpau
		cudaPackages.cudatoolkit
		];
	extraPackages32 = with pkgs; [
		nvidia-vaapi-driver
		libvdpau-va-gl
		vaapiVdpau
		cudaPackages.cudatoolkit
		];
	};
*/
  hardware.nvidia = {

    # Modesetting is needed most of the time
    modesetting.enable = true;

	# Enable power management (do not disable this unless you have a reason to).
	# Likely to cause problems on laptops and with screen tearing if disabled.
	powerManagement.enable = true;

    # Use the NVidia open source kernel module (which isn't “nouveau”).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    open = true;   #As of 5/31/24 open kernel modules actually break powerManagement.enable = true

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;
    # prevent sleep in headless
    nvidiaPersistenced = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    #Beta
#    package = pkgs.nvidia-patch.patch-nvenc (pkgs.nvidia-patch.patch-fbc config.boot.kernelPackages.nvidiaPackages.stable);
    package = config.boot.kernelPackages.nvidiaPackages.beta;

    };
  qt.platformTheme = "kde";

  #Configure pipewire for bluetooth and upmixing, only works when outputting stereo from pulseaudio/pipewire, which is then upmixed to 5.1. Yes this is stupid.
  environment.etc = {
#  "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
#		bluez_monitor.properties = {
#			["bluez5.enable-sbc-xq"] = true,
#			["bluez5.enable-msbc"] = true,
#			["bluez5.enable-hw-volume"] = true,
#			["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
#		}
#		'';
#  "X11/xorg.conf".text = ''
#    Section "ScreeSection "Screen"
#      Identifier     "Screen0"SectioSection "Screen"
#      Identifier     "Screen0"
#      Device         "Device0"
#      Monitor        "Monitor0"
#      DefaultDepth    24
#      Option         "Coolbits" "28"
#      Option         "RegistryDwords" "PowerMizerEnable=0x1; PerfLevelSrc=0x2222; PowerMizerDefaultAC=0x1"
#      SubSection     "Display"
#          Depth       24
#      EndSubSection
#  EndSection
#  '';
  };


  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

      # Various controller udev rules stolen from https://gitlab.com/fabiscafe/game-devices-udev
    # TODO: Move this the hell out of this file somehow
    services.udev.extraRules = ''
      # 8Bitdo F30 P1
      SUBSYSTEM=="input", ATTRS{name}=="8Bitdo FC30 GamePad", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
      # 8Bitdo F30 P2
      SUBSYSTEM=="input", ATTRS{name}=="8Bitdo FC30 II", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
      # 8Bitdo N30
      SUBSYSTEM=="input", ATTRS{name}=="8Bitdo NES30 GamePad", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
      # 8Bitdo SF30
      SUBSYSTEM=="input", ATTRS{name}=="8Bitdo SFC30 GamePad", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
      # 8Bitdo SN30
      SUBSYSTEM=="input", ATTRS{name}=="8Bitdo SNES30 GamePad", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
      # 8Bitdo F30 Pro
      SUBSYSTEM=="input", ATTRS{name}=="8Bitdo FC30 Pro", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
      # 8Bitdo N30 Pro
      SUBSYSTEM=="input", ATTRS{name}=="8Bitdo NES30 Pro", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
      # 8Bitdo SF30 Pro
      SUBSYSTEM=="input", ATTRS{name}=="8Bitdo SF30 Pro", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
      # 8Bitdo SN30 Pro
      SUBSYSTEM=="input", ATTRS{name}=="8Bitdo SN30 Pro", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
      # 8BitDo SN30 Pro+; Bluetooth; USB
      SUBSYSTEM=="input", ATTRS{name}=="8BitDo SN30 Pro+", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
      SUBSYSTEM=="input", ATTRS{name}=="8Bitdo SF30 Pro   8BitDo SN30 Pro+", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
      # 8Bitdo F30 Arcade
      SUBSYSTEM=="input", ATTRS{name}=="8Bitdo Joy", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
      # 8Bitdo N30 Arcade
      SUBSYSTEM=="input", ATTRS{name}=="8Bitdo NES30 Arcade", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
      # 8Bitdo ZERO
      SUBSYSTEM=="input", ATTRS{name}=="8Bitdo Zero GamePad", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
      # 8Bitdo Retro-Bit xRB8-64
      SUBSYSTEM=="input", ATTRS{name}=="8Bitdo N64 GamePad", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
      # 8BitDo Pro 2; Bluetooth; USB
      SUBSYSTEM=="input", ATTRS{name}=="8BitDo Pro 2", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
      SUBSYSTEM=="input", ATTR{id/vendor}=="2dc8", ATTR{id/product}=="6003", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
      # Alpha Imaging Technology Corp.
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="114d", ATTRS{idProduct}=="8a12", TAG+="uaccess"
      # ASTRO Gaming C40 Controller; USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="9886", ATTRS{idProduct}=="0025", MODE="0660", TAG+="uaccess"
      # Betop PS4 Fun Controller
      KERNEL=="hidraw*", ATTRS{idVendor}=="11c0", ATTRS{idProduct}=="4001", MODE="0660", TAG+="uaccess"
      # Hori RAP4
      KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="008a", MODE="0660", TAG+="uaccess"
      # Hori HORIPAD 4 FPS
      KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="0055", MODE="0660", TAG+="uaccess"
      # Hori HORIPAD 4 FPS Plus
      KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="0066", MODE="0660", TAG+="uaccess"
      # Hori HORIPAD S; USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="00c1", MODE="0660", TAG+="uaccess"
      # Hori Nintendo Switch HORIPAD Wired Controller; USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="0f0d", ATTRS{idProduct}=="00c1", MODE="0660", TAG+="uaccess"
      # HTC
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0bb4", ATTRS{idProduct}=="2c87", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0bb4", ATTRS{idProduct}=="0306", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0bb4", ATTRS{idProduct}=="0309", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0bb4", ATTRS{idProduct}=="030a", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0bb4", ATTRS{idProduct}=="030b", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0bb4", ATTRS{idProduct}=="030c", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0bb4", ATTRS{idProduct}=="030e", TAG+="uaccess"
      # HTC VIVE Cosmos; USB; https://gitlab.com/fabis_cafe/game-devices-udev/-/issues/1/ #EXPERIMENTAL
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0bb4", ATTRS{idProduct}=="0313", TAG+="uaccess"
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0315", MODE="0660", TAG+="uaccess"
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0323", MODE="0660", TAG+="uaccess"
      # Logitech F310 Gamepad; USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c216", MODE="0660", TAG+="uaccess"
      # Logitech F710 Wireless Gamepad; USB #EXPERIMENTAL
      KERNEL=="hidraw*", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c21f", MODE="0660", TAG+="uaccess"
      # Mad Catz Street Fighter V Arcade FightPad PRO
      KERNEL=="hidraw*", ATTRS{idVendor}=="0738", ATTRS{idProduct}=="8250", MODE="0660", TAG+="uaccess"
      # Mad Catz Street Fighter V Arcade FightStick TE S+
      KERNEL=="hidraw*", ATTRS{idVendor}=="0738", ATTRS{idProduct}=="8384", MODE="0660", TAG+="uaccess"
      # Microsoft Xbox360 Controller; USB #EXPERIMENTAL
      SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="028e", MODE="0660", TAG+="uaccess"
      SUBSYSTEMS=="input", ATTRS{name}=="Microsoft X-Box 360 pad", MODE="0660", TAG+="uaccess"
      # Microsoft Xbox 360 Wireless Receiver for Windows; USB
      SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0719", MODE="0660", TAG+="uaccess"
      SUBSYSTEMS=="input", ATTRS{name}=="Xbox 360 Wireless Receiver", MODE="0660", TAG+="uaccess"
      # Microsoft Xbox One S Controller; bluetooth; USB #EXPERIMENTAL
      KERNEL=="hidraw*", KERNELS=="*045e:02ea*", MODE="0660", TAG+="uaccess"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02ea", MODE="0660", TAG+="uaccess"
      # Nacon PS4 Revolution Pro Controller
      KERNEL=="hidraw*", ATTRS{idVendor}=="146b", ATTRS{idProduct}=="0d01", MODE="0660", TAG+="uaccess"
      # Nintendo Switch Pro Controller; bluetooth; USB
      KERNEL=="hidraw*", KERNELS=="*057E:2009*", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2009", MODE="0660", TAG+="uaccess"
      # Nintendo GameCube Controller / Adapter; USB
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", MODE="0660", TAG+="uaccess"
      # NVIDIA Shield Portable (2013 - NVIDIA_Controller_v01.01 - In-Home Streaming only)
      KERNEL=="hidraw*", ATTRS{idVendor}=="0955", ATTRS{idProduct}=="7203", ENV{ID_INPUT_JOYSTICK}="1", ENV{ID_INPUT_MOUSE}="", MODE="0660", TAG+="uaccess"
      # NVIDIA Shield Controller (2017 - NVIDIA_Controller_v01.04); bluetooth
      KERNEL=="hidraw*", KERNELS=="*0955:7214*", MODE="0660", TAG+="uaccess"
      # NVIDIA Shield Controller (2015 - NVIDIA_Controller_v01.03); USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="0955", ATTRS{idProduct}=="7210", ENV{ID_INPUT_JOYSTICK}="1", ENV{ID_INPUT_MOUSE}="", MODE="0660", TAG+="uaccess"
      # PDP Afterglow Deluxe+ Wired Controller; USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="0e6f", ATTRS{idProduct}=="0188", MODE="0660", TAG+="uaccess"
      # PDP Nintendo Switch Faceoff Wired Pro Controller; USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="0e6f", ATTRS{idProduct}=="0180", MODE="0660", TAG+="uaccess"
      # PDP Wired Fight Pad Pro for Nintendo Switch; USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="0e6f", ATTRS{idProduct}=="0185", MODE="0666", TAG+="uaccess"
      # Personal Communication Systems, Inc. Twin USB Gamepad; USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="0810", ATTRS{idProduct}=="e301", MODE="0660", TAG+="uaccess"
      SUBSYSTEM=="input", ATTRS{name}=="Twin USB Gamepad*", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"
      # PowerA Wired Controller for Nintendo Switch; USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="20d6", ATTRS{idProduct}=="a711", MODE="0660", TAG+="uaccess"
      # PowerA Zelda Wired Controller for Nintendo Switch; USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="20d6", ATTRS{idProduct}=="a713", MODE="0660", TAG+="uaccess"
      # PowerA Wireless Controller for Nintendo Switch; bluetooth
      # We have to use ATTRS{name} since VID/PID are reported as zeros.
      # We use sh instead of udevadm directly becuase we need to
      # use '*' glob at the end of "hidraw" name since we don't know the index it'd have.
      # Thanks @https://github.com/ValveSoftware
      # KERNEL=="input*", ATTRS{name}=="Lic Pro Controller", RUN{program}+="sh -c 'udevadm test-builtin uaccess /sys/%p/../../hidraw/hidraw*'"
      # Razer Raiju PS4 Controller
      KERNEL=="hidraw*", ATTRS{idVendor}=="1532", ATTRS{idProduct}=="1000", MODE="0660", TAG+="uaccess"
      # Razer Panthera Arcade Stick
      KERNEL=="hidraw*", ATTRS{idVendor}=="1532", ATTRS{idProduct}=="0401", MODE="0660", TAG+="uaccess"
      # Sony PlayStation Strikepack; USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c5", MODE="0660", TAG+="uaccess"
      # Sony PlayStation DualShock 3; bluetooth; USB
      KERNEL=="hidraw*", KERNELS=="*054C:0268*", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0268", MODE="0660", TAG+="uaccess"
      ## Motion Sensors
      SUBSYSTEM=="input", KERNEL=="event*|input*", KERNELS=="*054C:0268*", TAG+="uaccess"
      # Sony PlayStation DualShock 4; bluetooth; USB
      KERNEL=="hidraw*", KERNELS=="*054C:05C4*", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", MODE="0660", TAG+="uaccess"
      # Sony PlayStation DualShock 4 Slim; bluetooth; USB
      KERNEL=="hidraw*", KERNELS=="*054C:09CC*", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", MODE="0660", TAG+="uaccess"
      # Sony PlayStation DualShock 4 Wireless Adapter; USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ba0", MODE="0660", TAG+="uaccess"
      # Sony DualSense Wireless-Controller; bluetooth; USB
      KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0660", TAG+="uaccess"
      # PlayStation VR; USB
      SUBSYSTEM=="usb", ATTR{idVendor}=="054c", ATTR{idProduct}=="09af", MODE="0660", TAG+="uaccess"
      # Valve generic(all) USB devices
      SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0660", TAG+="uaccess"
      # Valve Steam Controller write access
      KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"
      # Valve HID devices; bluetooth; USB
      KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0660", TAG+="uaccess"
      # Valve
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="1043", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="1142", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2000", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2010", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2011", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2012", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2021", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2022", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2050", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2101", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2102", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2150", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2300", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", ATTRS{idProduct}=="2301", MODE="0660", TAG+="uaccess"
      # Zeroplus(ZP) appears to be a tech-provider for variouse other companies.
      # They all use the ZP ID. Because of this, they are grouped in this rule.
      # Armor PS4 Armor 3 Pad; USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="0c12", ATTRS{idProduct}=="0e10", MODE="0660", TAG+="uaccess"
      # EMiO PS4 Elite Controller; USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="0c12", ATTRS{idProduct}=="1cf6", MODE="0660", TAG+="uaccess"
      # Hit Box Arcade HIT BOX PS4/PC version; USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="0c12", ATTRS{idProduct}=="0ef6", MODE="0660", TAG+="uaccess"
      # Nyko Xbox Controller; USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="0c12", ATTRS{idProduct}=="8801", MODE="0660", TAG+="uaccess"
      # Unknown-Brand Xbox Controller; USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="0c12", ATTRS{idProduct}=="8802", MODE="0660", TAG+="uaccess"
      # Unknown-Brand Xbox Controller; USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="0c12", ATTRS{idProduct}=="8810", MODE="0660", TAG+="uaccess"
      # Gotta make sure that the video group actually has video acces apparently.
      KERNEL=="video*", SUBSYSTEM=="video4linux", MODE="0660", GROUP="video"
      # probe filesystem metadata of optical drives which have a media inserted
    '';

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  #sound.enable = true;
  services.pulseaudio.enable = false;
  services.pulseaudio.configFile = pkgs.writeText "default.pa" ''
  load-module module-bluetooth-policy
  load-module module-bluetooth-discover
  ## module fails to load with
  ##   module-bluez5-device.c: Failed to get device path from module arguments
  ##   module.c: Failed to load module "module-bluez5-device" (argument: ""): initialization failed.
  # load-module module-bluez5-device
  # load-module module-bluez5-discover
  '';
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
      extraConfig.pipewire = {
      "stream.properties" = {
        channelmix.upmix = true;
        channelmix.mix-lfe = true;
        channelmix.upmix-method = "psd";
        channelmix.lfe-cutoff = 80;
        channelmix.fc-cutoff = 12000;
        channelmix.rear-delay = 12.0;
	default.clock.rate = 192000;
	default.clock.quantum = 128;
      };
    };
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  programs.dconf.enable = true;

  # Firefox configuration.
  programs.firefox = {
  enable = true;
  preferences = {
      "widget.use-xdg-desktop-portal.file-picker" = 1; #Enable utilizing native filepicker instead of letting firefox cuck the desktop.
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dusty = {
    isNormalUser = true;
    description = "Dusty Lee Carrier";
    extraGroups = [ "networkmanager" "wheel" "cdrom" "syncthing" ];
    packages = with pkgs; [
    ];
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true; #Enable to disable login on startup. Will still lock automatically after an interval of non-use.
  services.displayManager.autoLogin.user = "dusty";
  #Declare fonts
  fonts.packages = with pkgs; [
 # nerdfonts
  noto-fonts
  noto-fonts-cjk-sans
  noto-fonts-emoji
  ];
  system.stateVersion = "22.11"; # Don't change this. Like, ever.

  # fcitx5 setup
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.waylandFrontend = true;
      fcitx5.plasma6Support = true;
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
    ];
  };

  #Gamescope
  programs.gamescope = {
  enable = true;
#  package = pkgs.gamescope;
  };

  #Steam Setup
  programs.steam = {
	enable = true;
	remotePlay.openFirewall = true;
	gamescopeSession.enable = true;
	dedicatedServer.openFirewall = true;
	};
  # Define environment variables.
  environment.variables = {
  WLR_NO_HARDWARE_CURSORS = "1";
  MOZ_USE_XINPUT2 = "1";
  MOZ_ENABLE_WAYLAND = "1";
#  SUDO_EDITOR = "/run/current-system/sw/bin/kate";
  GBM_BACKEND = "nvidia-drm"; 
  MOZ_DISABLE_RDD_SANDBOX = "1"; 
  NVD_BACKEND = "direct";
  EGL_PLATFORM = "wayland";
  KWIN_DRM_ALLOW_NVIDIA_COLORSPACE=1;
  };

  #enable flatpak
  services.flatpak.enable = true;
  #enable bluetooth
  hardware.bluetooth.enable = true;
#  hardware.bluetooth.hsphfpd.enable = true;
  #enable xpadneo
  hardware.xpadneo.enable = true;

  #enable OpenRGB
  services.hardware.openrgb = {
  enable = true;
  motherboard = "amd";
  };

}

