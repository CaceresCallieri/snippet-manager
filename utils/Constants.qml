pragma Singleton
import QtQuick

QtObject {
    // UI Layout
    readonly property int maxVisibleSnippets: 5
    readonly property int overlayWidth: 350
    readonly property int overlayHeight: 320
    readonly property int snippetItemHeight: 35
    readonly property real overlayTopOffsetFraction: 1.0 / 6.0
    
    // UI Spacing
    readonly property int mainMargins: 15
    readonly property int headerMargins: 20
    readonly property int headerTopMargin: 10
    readonly property int itemSpacing: 5
    readonly property int textMargins: 15
    readonly property int headerHeight: 40
    readonly property int instructionsHeight: 25
    
    // Text Injection Timing (milliseconds)
    readonly property int injectionDelayMs: 250
    readonly property int wtypeKeystrokeDelayMs: 5
    
    // UI Styling
    readonly property int borderRadius: 8
    readonly property int itemBorderRadius: 6
    readonly property int borderWidth: 1
    
    // Font Sizes
    readonly property int headerFontSize: 18
    readonly property int snippetFontSize: 14
    readonly property int instructionsFontSize: 12
    
    // Search Input Styling
    readonly property QtObject search: QtObject {
        readonly property int inputHeight: 35
        readonly property int fontSize: 14
        readonly property color backgroundColor: "#2a2a2a"
        readonly property color borderColor: "#555555"
        readonly property color textColor: "#ffffff"
        readonly property color selectionColor: "#ff6b35"
        readonly property color selectedTextColor: "#ffffff"
        readonly property int borderWidth: 1
        readonly property int borderRadius: 4
        readonly property int maxInputLength: 100
        readonly property color warningColor: "#ff6b35"
    }
}