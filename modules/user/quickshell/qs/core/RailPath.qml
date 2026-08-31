pragma Singleton

import Quickshell

// The outline of the viewport hole, and the plate that is everything but it.
//
// Tabs are folded into this one outline rather than drawn as their own Shape,
// because the plate is translucent: a second shape laid over it would composite
// to a darker patch, and one merely abutting it would leave an antialiasing
// seam. Carved in here a tab is literally the same fill as the rail it grows
// out of, and Hyprland's layer blur covers it for free.
Singleton {
    id: root

    // A point on an edge, in window coordinates: `a` runs along the edge, `k`
    // measures inward, into the viewport. Every edge is written in these terms
    // so one arc table serves all four.
    function pt(edge, box, a, k) {
        if (edge === "top")
            return `${a},${box.t + k}`;
        if (edge === "bottom")
            return `${a},${box.b - k}`;
        if (edge === "left")
            return `${box.l + k},${a}`;

        return `${box.r - k},${a}`;
    }

    // A radius clamped to nothing has to degrade to a line; Qt will not draw a
    // zero-radius arc, and the opening animation walks every radius through 0.
    function arc(r, sweep, to) {
        return r < 0.5 ? `L${to}` : `A${r},${r} 0 0 ${sweep} ${to}`;
    }

    // One tab, as a detour in the edge it sits on. Walking the hole clockwise,
    // the two joins are `sweep 1` arcs centred out in the plate, which is what
    // makes them concave and the tab look extruded rather than stuck on; the
    // tab's own two outer corners are ordinary `sweep 0` ones. Rotating a shape
    // does not change an SVG sweep flag, so these hold for all four edges.
    //
    // `off` pushes the outline outward from the hole, which grows the joins and
    // shrinks the tab. The depth is untouched: the edge line and the tab's tip
    // both move outward by `off` together.
    function detour(edge, box, dir, lo, hi, tab, corner, off) {
        const d = tab.liveDepth;

        const half = tab.span / 2 - off;

        if (half <= 0 || d < 0.5)
            return "";

        let c = Math.max(0, Math.min(corner, tab.span / 2, d / 2) - off);
        c = Math.min(c, half, d / 2);

        const a = tab.axis;

        // The joins have to land on the straight run, clear of the viewport's
        // own rounded corners.
        const room = Math.min(a - half - lo, hi - a - half);
        const f = Math.max(0, Math.min(Math.min(corner, d - c) + off, d - c, room));

        const n = a - dir * half;
        const p = a + dir * half;

        return `L${root.pt(edge, box, a - dir * (half + f), 0)}` + root.arc(f, 1, root.pt(edge, box, n, f)) + `L${root.pt(edge, box, n, d - c)}` + root.arc(c, 0, root.pt(edge, box, n + dir * c, d)) + `L${root.pt(edge, box, p - dir * c, d)}` + root.arc(c, 0, root.pt(edge, box, p, d - c)) + `L${root.pt(edge, box, p, f)}` + root.arc(f, 1, root.pt(edge, box, a + dir * (half + f), 0));
    }

    // The viewport walked clockwise, detouring around every open tab. Returns
    // the subpath alone so RailShadow can stroke it; `plate` wraps it.
    function hole(w, h, ins, corner, tabs, off) {
        const box = {
            l: ins.left - off,
            t: ins.top - off,
            r: w - ins.right + off,
            b: h - ins.bottom + off
        };

        if (box.r - box.l < 2 || box.b - box.t < 2)
            return "";

        const c = Math.max(0, Math.min(corner + off, (box.r - box.l) / 2, (box.b - box.t) / 2));

        // Each run ends where the next one starts, so `turn` is both this
        // corner's arc target and the following run's origin.
        const runs = [
            {
                edge: "top",
                a0: box.l + c,
                a1: box.r - c,
                turn: root.pt("right", box, box.t + c, 0)
            },
            {
                edge: "right",
                a0: box.t + c,
                a1: box.b - c,
                turn: root.pt("bottom", box, box.r - c, 0)
            },
            {
                edge: "bottom",
                a0: box.r - c,
                a1: box.l + c,
                turn: root.pt("left", box, box.b - c, 0)
            },
            {
                edge: "left",
                a0: box.b - c,
                a1: box.t + c,
                turn: root.pt("top", box, box.l + c, 0)
            }
        ];

        let out = `M${root.pt("top", box, box.l + c, 0)}`;
        const all = tabs || [];

        for (let i = 0; i < runs.length; i++) {
            const run = runs[i];

            const dir = run.a1 >= run.a0 ? 1 : -1;
            const lo = Math.min(run.a0, run.a1);
            const hi = Math.max(run.a0, run.a1);

            const on = [];

            for (let j = 0; j < all.length; j++) {
                if (all[j] && all[j].edge === run.edge && all[j].liveDepth >= 0.5)
                    on.push(all[j]);
            }

            // In walk order, so the detours come out in the order the pen meets
            // them. Overlapping tabs are the caller's problem.
            on.sort((x, y) => (x.axis - y.axis) * dir);

            for (let j = 0; j < on.length; j++)
                out += root.detour(run.edge, box, dir, lo, hi, on[j], corner, off);

            out += `L${root.pt(run.edge, box, run.a1, 0)}` + root.arc(c, 1, run.turn);
        }

        return out + "Z";
    }

    // The screen rectangle, then the viewport. Both subpaths come out of one
    // string so they land in one OddEvenFill ShapePath: the outer encloses, the
    // inner cuts the hole.
    function plate(w, h, ins, corner, tabs) {
        const screen = `M0,0 H${w} V${h} H0 Z`;
        const inner = root.hole(w, h, ins, corner, tabs, 0);

        return inner === "" ? screen : `${screen} ${inner}`;
    }
}
