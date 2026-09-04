{ pkgs, ... }:
{
  # ── KVM/QEMU + libvirt ─────────────────────────────────────────────────────
  # libvirtd pulls in qemu_kvm as its hypervisor backend. OVMF gives UEFI
  # firmware for guests; swtpm provides emulated TPM 2.0 (Win11 needs it);
  # virtiofsd enables shared-folder passthrough via virtio-fs.
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [ pkgs.OVMFFull.fd ];
      };
    };
  };

  # virt-manager GUI + spice client for clipboard/USB redirection.
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # ── Docker ─────────────────────────────────────────────────────────────────
  # rootful daemon; flip to `rootless.enable` if you'd rather not need group
  # membership. autoPrune trims dangling images weekly.
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # ── User access ────────────────────────────────────────────────────────────
  # List-merging means these append to extraGroups set in users.nix rather
  # than overwriting it.
  users.users.eriskii.extraGroups = [ "libvirtd" "docker" "kvm" ];

  # ── Tooling ────────────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    qemu                  # qemu-img, qemu-system-* for non-libvirt use
    virtiofsd             # shared-folder daemon for virtio-fs mounts
    docker-compose        # compose v2 plugin alternative; standalone binary
    dive                  # poke around docker image layers
    virt-viewer           # standalone SPICE/VNC viewer (separate from virt-manager)
  ];
}
