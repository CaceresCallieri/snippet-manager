pragma Singleton
import QtQuick

QtObject {
    // UI Layout
    readonly property int maxVisibleSnippets: 5
    readonly property int overlayWidth: 350
    readonly property int overlayHeight: 350
    readonly property int snippetItemHeight: 35
    readonly property real overlayTopOffsetFraction: 1.0 / 6.0
    
    // UI Spacing
    readonly property int mainMargins: 15
    readonly property int headerMargins: 20
    readonly property int headerTopMargin: 10
    readonly property int itemSpacing: 5
    readonly property int textMargins: 15
    readonly property int headerHeight: 45
    readonly property int titleHeight: 25
    readonly property int countHeight: 15
    readonly property int instructionsHeight: 25
    
    // Text Injection Timing (milliseconds)
    readonly property int injectionDelayMs: 250
    readonly property int wtypeKeystrokeDelayMs: 5
    
    // UI Styling - Mac Tahoe inspired with mixed rounding
    readonly property int borderRadius: 16
    readonly property int itemBorderRadius: 8
    readonly property int borderWidth: 1
    readonly property real backgroundOpacity: 0.6
    
    // Font Sizes
    readonly property int headerFontSize: 16
    readonly property int titleFontSize: 16
    readonly property int countFontSize: 11
    readonly property int snippetFontSize: 14
    readonly property int instructionsFontSize: 12
    readonly property int snippetTitleFontSize: 14
    
    // Search Input Styling - Mac Tahoe Dark Mode
    readonly property QtObject search: QtObject {
        readonly property int inputHeight: 35
        readonly property int fontSize: 14
        readonly property color backgroundColor: "#2c2c2e"
        readonly property color borderColor: "#48484a"
        readonly property color textColor: "#ffffff"
        readonly property color selectionColor: "#0a84ff"
        readonly property color selectedTextColor: "#ffffff"
        readonly property int borderWidth: 1
        readonly property int borderRadius: 8
        readonly property int maxInputLength: 100
        readonly property color warningColor: "#ff453a"
        readonly property color noResultsColor: "#8e8e93"
        readonly property int feedbackFontSize: 12
        readonly property color matchHighlightTextColor: "#98FB98"
        readonly property int characterCountThreshold: 50
        readonly property int smallTextFontSize: 8
        readonly property color characterCountColor: "#8e8e93"
        readonly property color placeholderTextColor: "#8e8e93"
    }

    // Data Validation Limits
    readonly property QtObject validation: QtObject {
        readonly property int maxTitleLength: 200
        readonly property int maxContentLength: 10000
    }

    // UI Colors - Mac Tahoe Dark Mode
    readonly property QtObject colors: QtObject {
        readonly property color mainBackground: "#1c1c1e"
        readonly property color mainBorder: "#48484a"
        readonly property color selectedBackground: "#3a3a3c"
        readonly property color unselectedBackground: "#2c2c2e"
        readonly property color selectedBorder: "#ffffff"
        readonly property color unselectedBorder: "#48484a"
        readonly property color selectedText: "#ffffff"
        readonly property color unselectedText: "#ffffff"
        readonly property color headerText: "#ffffff"
        readonly property color subtitleText: "#8e8e93"
        readonly property color characterCountNormal: "#8e8e93"
    }
    
    // Glass effect colors for selected snippet
    readonly property QtObject glassEffect: QtObject {
        readonly property color innerShadow: Qt.rgba(0, 0, 0, 0.25)
        readonly property color topHighlight: Qt.rgba(1, 1, 1, 0.4)
        readonly property color bottomHighlight: Qt.rgba(1, 1, 1, 0.1)
        readonly property color borderGlow: Qt.rgba(1, 1, 1, 0.15)
        readonly property color glassOverlay: Qt.rgba(1, 1, 1, 0.05)
    }

    // Layout Fractions
    readonly property QtObject layout: QtObject {
        readonly property real emptyStateWidthFraction: 0.9
    }
}
