
import Quickshell
import Quickshell.Hyprland
import qs

Scope {
    Variants {
        model: Actions.shortcuts

        GlobalShortcut {
            required property var modelData

            appid: "quickshell"
            name: modelData
            description: `quickshell: ${modelData}`

            onPressed: Actions.invoke(modelData)
        }
    }
}
