{ ... }:
{
  flake.modules.homeManager.hyprpolkitagent =
    { pkgs, theme, ... }:
    let
      inherit (theme) palette;
      themedQml = pkgs.writeText "main.qml" ''
        import QtQuick
        import QtQuick.Controls.Basic
        import QtQuick.Layouts

        ApplicationWindow {
            id: window

            property var windowWidth: Math.round(fontMetrics.height * 32.2856)
            property var windowHeight: Math.round(fontMetrics.height * 13.9528)
            property var heightSafeMargin: 15

            minimumWidth: Math.max(windowWidth, mainLayout.Layout.minimumWidth) + mainLayout.anchors.margins * 2
            minimumHeight: Math.max(windowHeight, mainLayout.Layout.minimumHeight) + mainLayout.anchors.margins * 2 + heightSafeMargin
            maximumWidth: minimumWidth
            maximumHeight: minimumHeight
            visible: true

            color: "${palette.bgHard}"
            palette.window: "${palette.bgHard}"
            palette.windowText: "${palette.fg}"
            palette.base: "${palette.bg}"
            palette.alternateBase: "${palette.bg1}"
            palette.text: "${palette.fg}"
            palette.button: "${palette.bg1}"
            palette.buttonText: "${palette.fg}"
            palette.highlight: "${palette.orange}"
            palette.highlightedText: "${palette.bgHard}"
            palette.placeholderText: "${palette.gray}"
            palette.mid: "${palette.bg2}"
            palette.midlight: "${palette.bg2}"
            palette.dark: "${palette.bgHard}"
            palette.shadow: "${palette.bgHard}"
            palette.light: "${palette.bg2}"

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
                        color: "${palette.fg}"
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
                        color: "${palette.fg3}"
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
                        placeholderTextColor: "${palette.gray}"
                        color: "${palette.fg}"
                        selectionColor: "${palette.orange}"
                        selectedTextColor: "${palette.bgHard}"
                        hoverEnabled: true
                        persistentSelection: true
                        echoMode: TextInput.Password
                        focus: true

                        background: Rectangle {
                            color: "${palette.bg}"
                            radius: 8
                            border.width: 1
                            border.color: passwordField.activeFocus ? "${palette.orange}" : "${palette.bg2}"
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

                        color: "${palette.red}"
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
                color: "${palette.bg1}"
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
                    color: btn.accent ? "${palette.bgHard}" : "${palette.fg}"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 8
                    color: btn.accent
                        ? (btn.down ? "${palette.yellow}" : (btn.hovered ? "${palette.yellow}" : "${palette.orange}"))
                        : (btn.down ? "${palette.bg2}" : (btn.hovered ? "${palette.bg2}" : "${palette.bg1}"))
                    border.width: btn.accent ? 0 : 1
                    border.color: "${palette.bg2}"
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
