{ ... }:
{
  # cliphist captures wayland clipboard history into a sqlite-backed store.
  # DMS's clipboard manager talks to this via `cliphist` CLI; without the
  # watcher service running, DMS reports "clipboard manager not initialized".
  services.cliphist = {
    enable = true;
    allowImages = true;
  };
}
