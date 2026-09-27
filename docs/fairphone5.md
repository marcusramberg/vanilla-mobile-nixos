# Fairphone 5 (fairphone-fp5)

## Setup Instructions

These instructions require `fastboot`. You can access it with `nix-shell -p android-tools`.

### Prep Work

Your device's bootloader needs to be unlocked. Follow the instructions on the
[postmarketOS Wiki](<https://wiki.postmarketos.org/wiki/Fairphone_5_(fairphone-fp5)>).

### How It Differs From Other Devices

The Fairphone 5 doesn't have a spare partition to hold the NixOS boot partition. Instead,
a single GPT disk image containing both the boot (ESP) and root partitions is flashed
to the `userdata` partition. U-Boot and the initrd both map `userdata` as a disk
to find the partitions inside it.

Because of this, the install config uses `image-config.nix` (systemd-repart) instead
of a disko config. LUKS encryption isn't set up by it yet.

### NixOS Config

Copy `examples/installConfigs/fairphone5` from this repository into your NixOS
configuration and add it as a NixOS configuration, like the
[POCO F1 instructions](./xiaomi-beryllium.md#nixos-config) show. The `disko` module
still needs to be imported, even though it isn't used for this device.

## NixOS Image Building

See the [POCO F1 instructions](./xiaomi-beryllium.md#nixos-image-building) for
binfmt and cache setup.

Build the image. For flakes that looks like:
`nix build --option extra-substituters https://vanilla-mobile-nixos.cachix.org .#nixosConfigurations.fairphone5.config.system.build.image`

### U-Boot

- Build the U-Boot boot image. For flakes that looks like:
  - `nix build --option extra-substituters https://vanilla-mobile-nixos.cachix.org .#nixosConfigurations.fairphone5.config.vanilla-mobile.deviceInfo.uboot -o u-boot`
- Go into fastboot mode on the phone.
- Flash U-Boot to both slots: `fastboot erase dtbo_a erase dtbo_b flash boot_a u-boot/u-boot.img flash boot_b u-boot/u-boot.img`

### NixOS Image Flashing

- Flash the NixOS image to the phone's `userdata` partition:
  - `fastboot erase userdata flash userdata result/nixos-fairphone5.raw`
- Reboot the phone with `fastboot reboot`.

The root partition is grown to fill `userdata` on first boot.

### SSH Access and Starter Config

Same as the [POCO F1 instructions](./xiaomi-beryllium.md#ssh-access).

## Optional Hardware

### Fingerprint Sensor

Set `vanilla-mobile.device.fairphone5.fingerprint.enable = true;` and add
`"focal32-firmware"` to `nixpkgs.config.allowUnfreePackages`. The trusted application
it loads is extracted from the stock firmware. This sets up fprintd; enrol with
`fprintd-enroll`, and use `security.pam.services.<name>.fprintAuth` to unlock with it.

### Camera

libcamera's soft ISP tuning for the FP5 sensors is set up automatically. For correct
gain handling, apps can be built against `libcamera-fairphone5`, which adds the FP5
sensor helpers. It isn't used system-wide, since that would rebuild PipeWire.
