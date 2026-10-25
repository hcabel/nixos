pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// CPU and memory pressure, sampled straight out of /proc. Kept out of the bar
// widget so a panel can show the same numbers without a second sampler.
Singleton {
    id: root

    readonly property int interval: 2000

    // Both 0..1.
    property real cpu: 0
    property real ram: 0

    // { total, idle } from the previous /proc/stat sample. The kernel reports
    // counters since boot, so a single read says nothing about load right now.
    property var previous: null

    // "cpu  user nice system idle iowait irq softirq steal guest guest_nice"
    // — idle time is fields 4 and 5, everything else counts as work.
    function readCpu(text) {
        const line = text.split("\n").find(l => l.startsWith("cpu "));

        if (!line)
            return;

        const fields = line.trim().split(/\s+/).slice(1).map(Number);

        let total = 0;
        for (const f of fields)
            total += f;

        const idle = fields[3] + fields[4];
        const last = root.previous;

        root.previous = {
            total,
            idle
        };

        if (!last)
            return;

        const dTotal = total - last.total;
        const dIdle = idle - last.idle;

        if (dTotal > 0)
            root.cpu = Math.max(0, Math.min(1, 1 - dIdle / dTotal));
    }

    // MemAvailable rather than MemFree: the kernel's own estimate of what a new
    // allocation could actually take, so cache does not read as pressure.
    function readRam(text) {
        function field(name) {
            const line = text.split("\n").find(l => l.startsWith(name + ":"));

            return line ? Number(line.trim().split(/\s+/)[1]) : 0;
        }

        const total = field("MemTotal");
        const available = field("MemAvailable");

        if (total > 0)
            root.ram = Math.max(0, Math.min(1, 1 - available / total));
    }

    FileView {
        id: stat

        path: "/proc/stat"

        onLoaded: root.readCpu(stat.text())
    }

    FileView {
        id: meminfo

        path: "/proc/meminfo"

        onLoaded: root.readRam(meminfo.text())
    }

    Timer {
        interval: root.interval
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            stat.reload();
            meminfo.reload();
        }
    }
}
