{ ... }:
{
  services.tailscale.enable = true;

  # Open the WireGuard port so the daemon can establish direct connections
  # instead of relaying through DERP.
  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ 41641 ];
  };
}
