import Quickshell
import Quickshell.Io
import qs.core
import qs.modules
import qs.overlays
import qs.panels
import qs.tabs

ShellRoot {
    // qs -c hcabel ipc call panels toggle left demo
    IpcHandler {
        target: "panels"

        function toggle(edge: string, name: string): void {
            PanelState.toggle(edge, name);
        }

        function close(edge: string): void {
            PanelState.close(edge);
        }

        function state(): string {
            return JSON.stringify(PanelState.state);
        }
    }

    // qs -c hcabel ipc call tabs toggle demo
    IpcHandler {
        target: "tabs"

        function toggle(name: string): void {
            TabState.toggle(name);
        }

        function close(name: string): void {
            TabState.close(name);
        }

        function state(): string {
            return JSON.stringify(TabState.opened);
        }
    }

    // qs -c hcabel ipc call osd volume up
    IpcHandler {
        target: "osd"

        function volume(dir: string): void {
            if (dir === "mute")
                Audio.toggleMute();
            else
                Audio.nudge(dir === "up" ? 1 : -1);
        }

        function brightness(dir: string): void {
            Backlight.nudge(dir === "up" ? 1 : -1);
        }
    }

    Variants {
        model: Quickshell.screens

        Scope {
            id: instance

            required property var modelData

            ExclusionZone {
                screen: instance.modelData

                insets: frame.reserved
            }

            Background {
                screen: instance.modelData

                insets: frame.insets
            }

            Toasts {
                screen: instance.modelData

                insets: frame.insets
            }

            Frame {
                id: frame

                screen: instance.modelData

                barRight: [
                    Performance {},
                    Battery {},
                    Volume {},
                    Clock {},
                    PowerButton {}
                ]

                barCenter: Workspaces {
                    screen: instance.modelData
                }

                panels: [
                    DemoPanel {},
                    NotificationCentre {}
                ]

                tabs: [
                    AppLauncher {},
                    Power {},
                    Osd {}
                ]
            }
        }
    }
}
