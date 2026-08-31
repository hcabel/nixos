pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    readonly property int toastLimit: 4
    readonly property int defaultLifetime: 5000

    property var arrivals: ({})
    property var collapsed: ({})
    property var toastIds: []

    readonly property var list: {
        const all = server.trackedNotifications.values.slice();
        return all.sort((a, b) => (root.arrivals[b.id] ?? 0) - (root.arrivals[a.id] ?? 0));
    }

    readonly property int count: root.list.length

    readonly property var toasts: root.list.filter(n => root.toastIds.indexOf(n.id) !== -1).slice(0, root.toastLimit)

    readonly property var groups: {
        const out = [];
        const byApp = {};

        for (const n of root.list) {
            const app = n.appName || "unknown";

            if (!byApp[app]) {
                byApp[app] = {
                    app,
                    icon: n.appIcon,
                    items: [],
                    at: root.arrivals[n.id] ?? 0
                };
                out.push(byApp[app]);
            }

            byApp[app].items.push(n);
        }

        return out.map(g => ({
                    app: g.app,
                    icon: g.icon,
                    items: g.items,
                    count: g.items.length,
                    at: g.at,
                    collapsed: root.collapsed[g.app] === true
                }));
    }

    function isCritical(n) {
        return n?.urgency === NotificationUrgency.Critical;
    }

    function tintOf(n) {
        if (root.isCritical(n))
            return Style.danger;

        return n?.urgency === NotificationUrgency.Low ? Style.neutral : Style.accent;
    }

    // The default action is the one the body click invokes, so it is never
    // drawn as a button.
    function defaultActionOf(n) {
        return (n?.actions ?? []).find(a => a.identifier === "default") ?? null;
    }

    function actionsOf(n) {
        return (n?.actions ?? []).filter(a => a.identifier !== "default");
    }

    function invoke(n, action) {
        if (!action)
            return;

        action.invoke();

        if (!n?.resident)
            root.dismiss(n);
    }

    function activate(n) {
        const fallback = root.defaultActionOf(n);

        if (fallback)
            root.invoke(n, fallback);
        else
            root.dismiss(n);
    }

    // 0 means it never expires on its own.
    function lifetimeOf(n) {
        if (root.isCritical(n) || root.actionsOf(n).length > 0)
            return 0;

        return n && n.expireTimeout > 0 ? n.expireTimeout * 1000 : root.defaultLifetime;
    }

    function isPersistent(n) {
        return root.lifetimeOf(n) === 0;
    }

    function since(at) {
        if (!at)
            return "";

        // Reading the clock here is what re-runs this on every tick.
        const mins = Math.floor((clock.date.getTime() - at) / 60000);

        if (mins < 1)
            return "now";
        if (mins < 60)
            return mins + "m";
        if (mins < 1440)
            return Math.floor(mins / 60) + "h";

        return Math.floor(mins / 1440) + "d";
    }

    function timeOf(n) {
        return root.since(root.arrivals[n?.id]);
    }

    function hideToast(n) {
        if (!n)
            return;

        root.toastIds = root.toastIds.filter(id => id !== n.id);
    }

    function dismiss(n) {
        if (!n)
            return;

        root.hideToast(n);
        n.dismiss();
    }

    function clearAll() {
        for (const n of root.list.slice())
            n.dismiss();

        root.toastIds = [];
    }

    function toggleGroup(app) {
        const next = Object.assign({}, root.collapsed);

        next[app] = next[app] !== true;
        root.collapsed = next;
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    NotificationServer {
        id: server

        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: true

        onNotification: n => {
            // Without this the server drops the notification the moment this
            // handler returns.
            n.tracked = true;

            const stamps = Object.assign({}, root.arrivals);
            stamps[n.id] = Date.now();
            root.arrivals = stamps;

            root.toastIds = [n.id].concat(root.toastIds);

            n.closed.connect(() => {
                root.hideToast(n);

                const left = Object.assign({}, root.arrivals);
                delete left[n.id];
                root.arrivals = left;
            });
        }
    }
}
