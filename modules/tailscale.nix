{ ... }:
{
  services.tailscale.enable = true;

  networking.firewall = {
    # WireGuard port: peers reach us here to negotiate direct (non-DERP)
    # tunnels. Must be on every interface, not just tailscale0.
    allowedUDPPorts = [ 41641 ];

    # Explicit allowlist on the tailscale interface — only these ports are
    # reachable from peers, instead of trusting the whole interface.
    # Caveat: this also blocks the PeerAPI (Taildrop, `tailscale file`,
    # `tailscale serve`/`funnel`), which binds to a dynamic port chosen at
    # daemon startup. Re-add `trustedInterfaces = [ "tailscale0" ];` if you
    # want those features back.
    interfaces.tailscale0 = {
      allowedTCPPorts = [ 22 ];
    };
  };
}
