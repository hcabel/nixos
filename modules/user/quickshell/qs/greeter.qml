import Quickshell
import qs.greeter

// Entry point for the login screen, launched by greetd as
//   quickshell -p /etc/greetd/qs/greeter.qml
// which makes this file's directory the config root, so `import qs.core`
// resolves against the same tree the bar uses.
//
// It also runs as-is inside a normal session for design work:
//   qs -p ~/nixos/modules/user/quickshell/qs/greeter.qml
// where greetd is unreachable and qs.greeter's Session falls back to dev mode.
ShellRoot {
    Variants {
        model: Quickshell.screens

        GreeterSurface {
            required property var modelData

            screen: modelData
        }
    }
}
