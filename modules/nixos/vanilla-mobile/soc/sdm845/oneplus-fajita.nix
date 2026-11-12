self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vanilla-mobile.device.oneplus-fajita;
in
{
  options.vanilla-mobile.device.oneplus-fajita = {
    enable = lib.mkEnableOption "OnePlus 6T (oneplus-fajita)";
  };

  config = lib.mkIf cfg.enable {
    vanilla-mobile = {
      # The 6T shares everything with the 6 except the device tree; its
      # firmware paths point at the enchilada ones too.
      device.oneplus-enchilada.enable = true;
      deviceInfo = {
        name = "OnePlus 6T";
        codename = "oneplus-fajita";
        dtb = "qcom/sdm845-oneplus-fajita.dtb";
        uboot = self.packages.ubootPackages.oneplus-fajita-boot-image;
      };
    };

    boot.initrd = {
      availableKernelModules = [ "loop" ];

      # The NixOS image is a GPT disk image flashed inside the `userdata`
      # partition, the same way U-Boot maps it. Linux doesn't scan nested
      # partition tables, so expose it as a partitioned loop device.
      systemd.initrdBin = [ pkgs.util-linux ];
      services.udev.rules = ''
        SUBSYSTEM=="block", ACTION=="add", ENV{ID_PART_ENTRY_NAME}=="userdata", RUN+="${pkgs.util-linux}/bin/losetup --partscan --find --nooverlap --sector-size ${toString config.vanilla-mobile.deviceInfo.imageSectorSize} --loop-ref userdata /dev/%k"
      '';
    };
  };

  meta.maintainers = [ lib.maintainers.marcusramberg ];
}
