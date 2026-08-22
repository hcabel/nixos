{ ... }:

# 16 GB and no swap device meant every memory spike went straight to an
# OOM kill — the kernel killed the whole terminal cgroup twice while editing
# 4K DNxHR footage in Resolve. systemd-oomd even warns about it at boot:
#   systemd-oomd[845]: No swap; memory pressure usage will be degraded
#
# zram is the right shape for this machine: a compressed block device in RAM,
# so there is no partition to carve out and no SSD write amplification. At the
# usual ~3:1 ratio, 50% of 15.7 GB of physical memory buys roughly 8 GB of
# effective headroom.
{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # zram is far cheaper to reach than a disk swap would be, so let the kernel
  # use it readily instead of evicting page cache first. 180 is the usual
  # recommendation for zram-only setups; the default of 60 is tuned for disks.
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };
}
