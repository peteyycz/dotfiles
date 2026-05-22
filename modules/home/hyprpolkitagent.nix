{ ... }:
{
  flake.modules.homeManager.hyprpolkitagent =
    { config, pkgs, ... }:
    let
      schemePath = "${config.home.homeDirectory}/.local/state/caelestia/scheme.json";
      themedQml = pkgs.writeText "main.qml" ''
        import QtQuick
        import QtQuick.Controls.Basic
        import QtQuick.Layouts

        ApplicationWindow {
            id: window

            property var scheme: ({})

            function colour(role, fallback) {
                return (scheme.colours && scheme.colours[role]) ? "#" + scheme.colours[role] : fallback;
            }

            Component.onCompleted: {
                const xhr = new XMLHttpRequest();
                xhr.open("GET", "file://${schemePath}");
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE && xhr.responseText) {
                        try { window.scheme = JSON.parse(xhr.responseText); } catch (e) {}
                    }
                };
                xhr.send();
            }

            property var windowWidth: Math.round(fontMetrics.height * 32.2856)
            property var windowHeight: Math.round(fontMetrics.height * 13.9528)
            property var heightSafeMargin: 15

            minimumWidth: Math.max(windowWidth, mainLayout.Layout.minimumWidth) + mainLayout.anchors.margins * 2
            minimumHeight: Math.max(windowHeight, mainLayout.Layout.minimumHeight) + mainLayout.anchors.margins * 2 + heightSafeMargin
            maximumWidth: minimumWidth
            maximumHeight: minimumHeight
            visible: true

            color: colour("surface", "#1d2021")
            palette.window: colour("surface", "#1d2021")
            palette.windowText: colour("onSurface", "#ebdbb2")
            palette.base: colour("surfaceContainer", "#282828")
            palette.alternateBase: colour("surfaceContainerHigh", "#3c3836")
            palette.text: colour("onSurface", "#ebdbb2")
            palette.button: colour("surfaceContainerHigh", "#3c3836")
            palette.buttonText: colour("onSurface", "#ebdbb2")
            palette.highlight: colour("primary", "#fe8019")
            palette.highlightedText: colour("surface", "#1d2021")
            palette.placeholderText: colour("outline", "#928374")
            palette.mid: colour("surfaceContainerHighest", "#504945")
            palette.midlight: colour("surfaceContainerHighest", "#504945")
            palette.dark: colour("surface", "#1d2021")
            palette.shadow: colour("surface", "#1d2021")
            palette.light: colour("surfaceContainerHighest", "#504945")

            onClosing: {
                hpa.setResult("fail");
            }

            FontMetrics {
                id: fontMetrics
            }

            Item {
                id: mainLayout

                anchors.fill: parent
                Keys.onEscapePressed: (e) => {
                    hpa.setResult("fail");
                }
                Keys.onReturnPressed: (e) => {
                    hpa.setResult("auth:" + passwordField.text);
                }
                Keys.onEnterPressed: (e) => {
                    hpa.setResult("auth:" + passwordField.text);
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 4

                    Label {
                        color: window.colour("onSurface", "#ebdbb2")
                        font.bold: true
                        font.pointSize: Math.round(fontMetrics.height * 1.05)
                        text: "Authenticating for " + hpa.getUser()
                        Layout.alignment: Qt.AlignHCenter
                        Layout.maximumWidth: parent.width
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                    }

                    HSeparator {
                        Layout.topMargin: fontMetrics.height / 2
                        Layout.bottomMargin: fontMetrics.height / 2
                    }

                    Label {
                        color: window.colour("onSurfaceVariant", "#bdae93")
                        text: hpa.getMessage()
                        Layout.maximumWidth: parent.width
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                    }

                    TextField {
                        id: passwordField

                        Layout.topMargin: fontMetrics.height / 2
                        Layout.fillWidth: true
                        Layout.preferredHeight: fontMetrics.height * 2.2
                        leftPadding: 12
                        rightPadding: 12
                        placeholderText: "Password"
                        placeholderTextColor: window.colour("outline", "#928374")
                        color: window.colour("onSurface", "#ebdbb2")
                        selectionColor: window.colour("primary", "#fe8019")
                        selectedTextColor: window.colour("surface", "#1d2021")
                        hoverEnabled: true
                        persistentSelection: true
                        echoMode: TextInput.Password
                        focus: true

                        background: Rectangle {
                            color: window.colour("surfaceContainer", "#282828")
                            radius: 8
                            border.width: 1
                            border.color: passwordField.activeFocus ? window.colour("primary", "#fe8019") : window.colour("surfaceContainerHighest", "#504945")
                        }

                        Connections {
                            target: hpa
                            function onFocusField() {
                                passwordField.focus = true;
                            }
                            function onBlockInput(block) {
                                passwordField.readOnly = block;
                                if (!block) {
                                    passwordField.focus = true;
                                    passwordField.selectAll();
                                }
                            }
                        }
                    }

                    Label {
                        id: errorLabel

                        color: window.colour("error", "#fb4934")
                        font.italic: true
                        Layout.topMargin: 0
                        text: ""
                        Layout.alignment: Qt.AlignHCenter

                        Connections {
                            target: hpa
                            function onSetErrorString(e) {
                                errorLabel.text = e;
                            }
                        }
                    }

                    Rectangle {
                        color: "transparent"
                        Layout.fillHeight: true
                    }

                    HSeparator {
                        Layout.topMargin: fontMetrics.height / 2
                        Layout.bottomMargin: fontMetrics.height / 2
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignRight
                        Layout.rightMargin: 4
                        spacing: 8

                        ThemedButton {
                            text: "Cancel"
                            accent: false
                            onClicked: hpa.setResult("fail")
                        }

                        ThemedButton {
                            text: "Authenticate"
                            accent: true
                            onClicked: hpa.setResult("auth:" + passwordField.text)
                        }
                    }
                }
            }

            component Separator: Rectangle {
                color: window.colour("surfaceContainerHigh", "#3c3836")
            }

            component HSeparator: Separator {
                implicitHeight: 1
                Layout.fillWidth: true
                Layout.leftMargin: fontMetrics.height * 8
                Layout.rightMargin: fontMetrics.height * 8
            }

            component ThemedButton: Button {
                id: btn
                property bool accent: false
                leftPadding: 18
                rightPadding: 18
                topPadding: 8
                bottomPadding: 8

                contentItem: Text {
                    text: btn.text
                    font: btn.font
                    color: btn.accent ? window.colour("surface", "#1d2021") : window.colour("onSurface", "#ebdbb2")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 8
                    color: btn.accent
                        ? (btn.down ? window.colour("primaryContainer", "#fabd2f") : (btn.hovered ? window.colour("primaryContainer", "#fabd2f") : window.colour("primary", "#fe8019")))
                        : (btn.down ? window.colour("surfaceContainerHighest", "#504945") : (btn.hovered ? window.colour("surfaceContainerHighest", "#504945") : window.colour("surfaceContainerHigh", "#3c3836")))
                    border.width: btn.accent ? 0 : 1
                    border.color: window.colour("surfaceContainerHighest", "#504945")
                }
            }
        }
      '';
    in
    {
      services.hyprpolkitagent = {
        enable = true;
        package = pkgs.hyprpolkitagent.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            cp ${themedQml} qml/main.qml
          '';
        });
      };
    };
}
