# isolyth's NixOS config

Flake-based, modular. Targets a single host (`isolyth`) with:
- AMD Ryzen 7 7800X3D + NVIDIA RTX 4070 SUPER (proprietary driver)
- LUKS-encrypted btrfs root with subvolumes (`@`, `@home`, `@nix`, `@log`)
- Hyprland on Wayland, no greeter (tty login → autoexec)
- pipewire, NetworkManager, openssh, steam

## Layout

| Path | What |
|---|---|
| `flake.nix` | Inputs (nixpkgs 25.11, unstable, disko, home-manager); host outputs |
| `disko-config.nix` | Declarative disk layout |
| `hosts/isolyth/default.nix` | Per-host imports + hostname/stateVersion |
| `hosts/isolyth/hardware-configuration.nix` | Hardware detection (regenerate per machine) |
| `modules/*.nix` | One concern per file: boot, networking, audio, graphics, hyprland, etc |

## Installing on fresh hardware

```sh
# from NixOS live USB:
nix-shell -p git
git clone https://github.com/Isolyth/nixos-config /tmp/nixos-config
cd /tmp/nixos-config

# Generate hardware config for this machine
sudo nixos-generate-config --root /mnt --no-filesystems --dir /tmp/hwgen
cp /tmp/hwgen/hardware-configuration.nix hosts/isolyth/hardware-configuration.nix

# Format disks (DESTRUCTIVE — wipes target disk in disko-config.nix)
sudo nix --experimental-features 'nix-command flakes' \
  run github:nix-community/disko -- \
  --mode disko ./disko-config.nix

# Install
sudo nixos-install --flake .#isolyth

# Reboot
sudo reboot
```

After first boot, set your password (`passwd`) and add the Hyprland autostart:

```sh
# in ~/.zprofile
if [ -z "$DISPLAY" ] && [ "$(tty)" = /dev/tty1 ]; then exec Hyprland; fi
```
