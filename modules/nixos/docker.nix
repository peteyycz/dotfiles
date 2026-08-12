{ ... }:
{
  flake.modules.nixos.docker = {
    virtualisation.docker.enable = true;

    # Lets `docker buildx build --platform linux/arm64` (and Nix arm64 builds) work by
    # registering qemu-user for aarch64 via binfmt_misc with the fix-binary flag.
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    boot.binfmt.registrations.aarch64-linux.fixBinary = true;

    # Park every container under one slice so we can cap their *aggregate*
    # CPU use. Docker uses the systemd cgroup driver, so containers are
    # `docker-<id>.scope` units; with this default parent they nest under
    # `dockercap.slice` and inherit its CPUQuota.
    virtualisation.docker.daemon.settings.cgroup-parent = "dockercap.slice";

    # Aggregate ceiling for ALL containers combined. CPUQuota is relative to
    # a single core (100% = 1 core). This box has 12 CPUs; 600% caps the whole
    # container stack at ~6 cores, leaving ~6 cores of thermal headroom for
    # the desktop (Chrome/Slack/Plasma). Tune lower if it still runs hot.
    systemd.slices.dockercap = {
      description = "Aggregate CPU cap for all Docker containers";
      sliceConfig.CPUQuota = "600%";
    };
  };
}
