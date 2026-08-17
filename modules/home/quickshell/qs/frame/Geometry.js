.pragma library

// Pure geometry for the shell frame. Everything that has to know where a corner
// goes lives here, so the QML above it only ever deals with rectangles.
//
// Two ideas carry the whole file:
//
//   * The frame is the space between the screen rectangle and an *inner
//     boundary*. A drawer is nothing but a change to that boundary — a panel
//     moves one edge of it inward along its whole length, an overlay pushes a
//     local bump into it. Both end up in one path with one fill, which is what
//     keeps the translucent chrome free of the seams and double-darkened
//     overlaps you get from stacking separate translucent rectangles.
//
//   * A drawer that spans its whole edge is expressed as an inset; anything
//     narrower is expressed as a detour. `reserves` is independent of that, and
//     only decides whether the compositor hears about it.
//
// Sizes come in as effectiveDepth/effectiveBreadth, which are either the
// drawer's declared numbers or what its content measured out to. Nothing here
// needs to know which.
//
// Edges are the strings "top", "right", "bottom", "left" — the same keys the
// inset objects use, so `insets[edge]` just works.

// ── insets ───────────────────────────────────────────────────────────────────

// What the compositor is told. Snaps, because a layer-shell exclusive zone is a
// per-edge scalar: a drawer that reserves does so across the whole edge no
// matter how wide it actually is on screen.
function reservedInsets(base, drawers) {
    const out = {
        top: base.top,
        right: base.right,
        bottom: base.bottom,
        left: base.left
    };

    for (let i = 0; i < drawers.length; i++) {
        const d = drawers[i];
        if (d.reserves && d.open)
            out[d.edge] += d.effectiveDepth;
    }

    return out;
}

// What gets painted. Slides, and only full-edge drawers move the boundary as a
// whole — partial ones come back as detours.
function visualInsets(base, drawers) {
    const out = {
        top: base.top,
        right: base.right,
        bottom: base.bottom,
        left: base.left
    };

    for (let i = 0; i < drawers.length; i++) {
        const d = drawers[i];
        if (d.fullEdge)
            out[d.edge] += d.effectiveDepth * d.progress;
    }

    return out;
}

function edgeLength(w, h, insets, edge) {
    return edge === "top" || edge === "bottom" ? w - insets.left - insets.right : h - insets.top - insets.bottom;
}

// `align` reads left-to-right and top-to-bottom, but the boundary is walked
// clockwise, so it runs backwards along the bottom and left edges.
function alongEdge(len, size, edge, align) {
    const natural = (len - size) * align;
    return edge === "bottom" || edge === "left" ? len - size - natural : natural;
}

// ── detours ──────────────────────────────────────────────────────────────────

// The local bumps to push into the inner boundary, one per open partial drawer.
// Offsets are in walk coordinates (from the corner the edge starts at).
function detours(w, h, insets, drawers) {
    const out = [];

    for (let i = 0; i < drawers.length; i++) {
        const d = drawers[i];
        if (d.fullEdge)
            continue;

        const depth = d.effectiveDepth * d.progress;
        if (depth < 0.5)
            continue;

        const len = edgeLength(w, h, insets, d.edge);

        out.push({
            edge: d.edge,
            start: alongEdge(len, d.effectiveBreadth, d.edge, d.align),
            size: d.effectiveBreadth,
            depth: depth,
            radius: d.rounding,
            // The join into the rail is fully formed by the time the drawer is
            // halfway out, so it reads as being pushed out of the rail rather
            // than unfolding from nothing.
            fillet: d.fillet * Math.min(1, d.progress * 2)
        });
    }

    return out;
}

function rect(x, y, width, height) {
    return {
        x: x,
        y: y,
        width: width,
        height: height
    };
}

// Where a drawer's content goes, in screen coordinates. The input mask needs the
// same rectangle, so there is exactly one definition of it.
function bodyRect(w, h, insets, d) {
    const depth = d.effectiveDepth * d.progress;

    const l = insets.left;
    const t = insets.top;
    const r = w - insets.right;
    const b = h - insets.bottom;

    if (d.fullEdge) {
        // Full edge. `insets` has already grown by `depth`, so the band the
        // drawer added sits immediately outside the inner boundary.
        switch (d.edge) {
            case "top":
                return rect(l, t - depth, r - l, depth);
            case "bottom":
                return rect(l, b, r - l, depth);
            case "left":
                return rect(l - depth, t, depth, b - t);
            default:
                return rect(r, t, depth, b - t);
        }
    }

    // Partial. The body protrudes inward from the boundary.
    const len = edgeLength(w, h, insets, d.edge);
    const size = d.effectiveBreadth;
    const offset = (len - size) * d.align;

    switch (d.edge) {
        case "top":
            return rect(l + offset, t, size, depth);
        case "bottom":
            return rect(l + offset, b - depth, size, depth);
        case "left":
            return rect(l, t + offset, depth, size);
        default:
            return rect(r - depth, t + offset, depth, size);
    }
}

// ── path ─────────────────────────────────────────────────────────────────────

function n(v) {
    return v.toFixed(2);
}

function lineTo(out, p) {
    out.push(`L${n(p[0])},${n(p[1])}`);
}

function arcTo(out, radius, sweep, p) {
    out.push(`A${n(radius)},${n(radius)} 0 0 ${sweep} ${n(p[0])},${n(p[1])}`);
}

// A point `s` along an edge from its starting corner and `d` inward from it.
function at(corner, axis, normal, s, d) {
    return [corner[0] + axis[0] * s + normal[0] * d, corner[1] + axis[1] * s + normal[1] * d];
}

// Shrink a detour until it can be drawn without self-intersecting: its corners
// have to fit in its own depth, and the whole bump plus both joins has to stay
// clear of the frame's own corners. Returns null if there is no room at all.
function fit(d, len, corner) {
    const span = len - corner * 2;
    if (span <= 0 || d.depth < 0.5)
        return null;

    const size = Math.max(0, Math.min(d.size, span - d.fillet * 2));
    // max(0, …) because offsetBoundary can push a radius negative before this.
    const radius = Math.max(0, Math.min(d.radius, d.depth / 2, size / 2));
    const fillet = Math.min(d.fillet, d.depth - radius, (span - size) / 2);
    if (fillet < 0)
        return null;

    const lo = corner + fillet;
    const hi = len - corner - fillet - size;

    return {
        start: Math.max(lo, Math.min(d.start, hi)),
        size: size,
        depth: d.depth,
        radius: radius,
        fillet: fillet
    };
}

// The same boundary pushed `k` px outward — i.e. the hole grows by `k` on every
// side. Used to lay concentric rings into the chrome for the inset's shadow, so
// the shadow follows the drawers instead of assuming a plain rounded rect.
//
// Offsetting a region outward grows its convex corners and shrinks its reflex
// ones. From inside the hole the frame's own corners are convex and a detour's
// tip corners are reflex, which is exactly the sweep flags framePath already
// uses — so the rule is: whatever is drawn sweep 1 gains `k`, sweep 0 loses it.
function offsetBoundary(insets, detourList, corner, k) {
    const out = [];

    for (let i = 0; i < detourList.length; i++) {
        const d = detourList[i];
        out.push({
            edge: d.edge,
            // The bump keeps its centre; the boundary eats into it from three
            // sides at once.
            start: d.start + k,
            size: d.size - k * 2,
            depth: d.depth - k,
            radius: d.radius - k,
            fillet: d.fillet + k
        });
    }

    return {
        insets: {
            top: insets.top - k,
            right: insets.right - k,
            bottom: insets.bottom - k,
            left: insets.left - k
        },
        detours: out,
        corner: corner + k
    };
}

// The inner boundary walked clockwise, on its own, as one closed subpath.
//
// Walking clockwise, every right turn is a corner the chrome wraps around
// (sweep 1: the frame's own corners, and a drawer's joins into the rail) and
// every left turn is a corner sticking into the screen (sweep 0: a drawer's own
// corners). Those opposite sweeps are the whole extruded look.
//
// Detours on one edge must not overlap each other; with one overlay open at a
// time they cannot.
//
// Returns "" when the boundary has collapsed, which is what the callers check.
function boundaryPath(w, h, insets, detourList, corner) {
    const l = insets.left;
    const t = insets.top;
    const r = w - insets.right;
    const b = h - insets.bottom;

    if (r - l < 2 || b - t < 2)
        return "";

    const R = Math.max(0, Math.min(corner, (r - l) / 2, (b - t) / 2));

    const edges = ["top", "right", "bottom", "left"];
    const corners = [[l, t], [r, t], [r, b], [l, b]];
    const axes = [[1, 0], [0, 1], [-1, 0], [0, -1]];
    // Always the edge axis rotated a quarter turn clockwise, which is why the
    // sweep flags below are the same on all four edges.
    const normals = [[0, 1], [-1, 0], [0, -1], [1, 0]];
    const lengths = [r - l, b - t, r - l, b - t];

    const out = [];

    const first = at(corners[0], axes[0], normals[0], R, 0);
    out.push(`M${n(first[0])},${n(first[1])}`);

    for (let i = 0; i < 4; i++) {
        const c = corners[i];
        const a = axes[i];
        const nm = normals[i];
        const len = lengths[i];

        const here = detourList.filter(d => d.edge === edges[i]).map(d => fit(d, len, R)).filter(d => d !== null).sort((x, y) => x.start - y.start);

        for (let j = 0; j < here.length; j++) {
            const d = here[j];
            const s0 = d.start;
            const s1 = d.start + d.size;

            lineTo(out, at(c, a, nm, s0 - d.fillet, 0));
            arcTo(out, d.fillet, 1, at(c, a, nm, s0, d.fillet));
            lineTo(out, at(c, a, nm, s0, d.depth - d.radius));
            arcTo(out, d.radius, 0, at(c, a, nm, s0 + d.radius, d.depth));
            lineTo(out, at(c, a, nm, s1 - d.radius, d.depth));
            arcTo(out, d.radius, 0, at(c, a, nm, s1, d.depth - d.radius));
            lineTo(out, at(c, a, nm, s1, d.fillet));
            arcTo(out, d.fillet, 1, at(c, a, nm, s1 + d.fillet, 0));
        }

        const next = (i + 1) % 4;
        lineTo(out, at(c, a, nm, len - R, 0));
        arcTo(out, R, 1, at(corners[next], axes[next], normals[next], R, 0));
    }

    out.push("Z");
    return out.join(" ");
}

// The frame as an SVG path: the screen rectangle, then the inner boundary. Both
// subpaths come out of one string so they land in one OddEvenFill ShapePath —
// the outer encloses, the inner cuts the hole, and the detours push material
// back into it.
function framePath(w, h, insets, detourList, corner) {
    const outer = `M0,0 H${n(w)} V${n(h)} H0 Z`;
    const inner = boundaryPath(w, h, insets, detourList, corner);

    return inner ? `${outer} ${inner}` : outer;
}
