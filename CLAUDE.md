# QuickShell Snippet Manager

## Project Overview
A modular snippet manager for Arch Linux Hyprland systems built with QuickShell. Features cursor-positioned overlay access to stored text snippets with direct text injection capabilities.

## Architecture
**Layered Service Architecture** with three distinct layers:
- **Data Persistence Layer**: JSON storage in `~/.config/quickshell/snippet-manager/`
- **Business Logic Layer**: Snippet management, search, variable substitution, text injection
- **Presentation Layer**: Wayland overlay UI, keyboard navigation, user interaction

## Technology Stack
- **Frontend**: QuickShell + QML for Wayland layer overlay
- **Backend**: JavaScript services with Qt integration
- **Storage**: JSON files in user config directory
- **System Integration**: Hyprland native clipboard system, wl-clipboard tools

## Development Phases

### Phase 1: Basic Frontend + Static Data ✅ COMPLETED
**Goal**: Create working overlay UI with static snippet list

**Implemented Features**:
- ✅ Overlay window appears immediately on command execution
- ✅ Keyboard navigation (Up/Down arrows, Enter to select)
- ✅ Mouse navigation (hover to select, click to choose)
- ✅ JSON-based snippet loading with validation (16 test snippets)
- ✅ Text injection via Hyprland native clipboard system with proper error handling
- ✅ Cursor positioning within injected text using `[cursor]` markers
- ✅ Auto-exit after selection or dismissal (Escape key)
- ✅ High-visibility UI with orange borders and clear numbering

**Current File Structure**:
```
quickshell-snippet-manager/
├── shell.qml                         # ✅ Main application (ShellRoot + LazyLoader)
├── ui/
│   ├── OverlayWindow.qml             # ✅ Main UI coordination and keyboard handling
│   ├── NavigationController.qml      # ✅ Navigation logic component
│   ├── CombiningModeController.qml   # ✅ Snippet combination state management
│   ├── SnippetCombiner.qml           # ✅ Core combination business logic
│   └── EmptyStateView.qml            # ✅ Empty state display component
├── utils/
│   ├── Constants.qml                 # ✅ Centralized configuration singleton
│   └── FuzzySearch.qml               # ✅ Multi-criteria fuzzy search engine
├── data/
│   └── snippets.json                 # ✅ JSON data source for snippets
├── inject-text.sh                    # ✅ Hyprland-native text injection script
└── test_injection.sh                 # ✅ Testing utility
```

**Implementation Notes**:
- **Modular QML Architecture**: Clean separation of concerns across 8 specialized components
- **JSON-based Data Loading**: Real-time loading from data/snippets.json with comprehensive validation
- **Fuzzy Search Engine**: Multi-criteria scoring with position weighting and adaptive filtering
- **Snippet Combination System**: SPACE key workflow for collecting and combining multiple snippets
- **Smart Keyboard Navigation**: Mode-aware ENTER/ESC behavior with progressive escape handling
- **Size Validation**: 10KB security limits with user-friendly desktop notifications
- **Performance Optimization**: 3-stage caching architecture eliminates binding loops
- **Error Resilience**: Comprehensive validation and graceful degradation for all failure modes

## Key Requirements

### Overlay Window
- Wayland layer overlay (top-most)
- Positioned at current cursor location
- Exclusive keyboard focus when visible
- Fixed size: 400x300 pixels
- Manual dismiss only (Escape key or selection)

### Keyboard Navigation
- `Escape`: Hide overlay
- `Up Arrow`: Move selection up (wraps to bottom when at top)
- `Down Arrow`: Move selection down (wraps to top when at bottom)
- `Enter`: Select current snippet and inject text
- `Ctrl+Q`: Quit application (alternative to Escape)

### Global Shortcut
User handles SUPER_L registration via Hyprland configuration.

## Technical Notes

### Dependencies
- QuickShell (Wayland compositor integration)
- wtype (text injection)
- hyprctl (cursor positioning)

### JSON Schema (Current)
```json
[
  {
    "title": "Snippet Title",
    "content": "The actual text content to inject"
  }
]
```

**Note**: The JSON schema was simplified to remove the separate "id" field, using only "title" and "content" properties.

### Integration Points
- Text injection happens after overlay dismissal
- Cursor position obtained via hyprctl
- JSON data loaded from user config directory

### Phase 2: Advanced Features ✅ COMPLETED
**Goal**: Implement fuzzy search and snippet combination capabilities

**Implemented Features**:
- ✅ **Fuzzy Search System**: Multi-criteria relevance scoring with position-based weighting
- ✅ **Snippet Combination**: SPACE key collection workflow for multi-snippet selection
- ✅ **Smart Keyboard Handling**: Mode-aware ENTER/ESC behavior for normal vs combining modes
- ✅ **Adaptive Filtering**: Intelligent result limiting based on search relevance scores
- ✅ **Size Validation**: 10KB limit enforcement with user feedback via desktop notifications
- ✅ **Modular Architecture**: Clean separation between business logic and UI components

**Snippet Combination Workflow**:
```
1. Search "upd" → Navigate to snippet
2. Press SPACE → Add to combination, clear search, enter combining mode
3. Search "com" → Navigate to next snippet  
4. Press SPACE → Add second snippet to combination
5. Press ENTER → Combine snippets with newline separation and inject text
```

**Key Architecture Components**:
- **CombiningModeController**: State management for multi-snippet collection
- **SnippetCombiner**: Pure business logic for text combination and validation
- **FuzzySearch**: Singleton providing relevance-based search with adaptive filtering

## Future Phases
- **Phase 3**: Variable substitution, preview pane, usage statistics

## Success Criteria for Phase 1
- Overlay appears at cursor within 200ms of activation
- All keyboard navigation works smoothly
- Text injection succeeds for simple text content
- Clean code structure supports easy Phase 2 integration

## Code Quality Standards

### Variable Naming Conventions
The codebase follows consistent, self-documenting naming patterns:

**Navigation & Display Properties**:
- `visibleRangeStartIndex` - Starting index of the visible snippet window
- `maxVisibleSnippets` - Maximum number of snippets displayed simultaneously  
- `visibleSnippetWindow` - Currently visible snippet array subset
- `globalIndex` - Absolute position across all snippets (visibleRangeStartIndex + currentIndex)

**Search & Data Flow Properties (Source/Display Pattern)**:
- `sourceSnippets` - Original unfiltered snippet data from JSON file
- `displayedSnippets` - Currently shown snippets after search filtering
- `hasSnippetsToDisplay` - Boolean indicating if filtered results are available

**State Management Properties**:
- `isOverlayVisible` - Boolean overlay visibility state
- `isDebugLoggingEnabled` - Debug logging toggle state
- `loadedValidSnippets` - Array of validated snippets from JSON file

**Performance Tracking**:
- `displayCalculationCount` - Tracks visibleSnippetWindow recalculation frequency

These names immediately communicate purpose and reduce cognitive load for maintenance and development.

### Navigation Controller Architecture
Navigation logic extracted into dedicated `ui/NavigationController.qml` component for clean separation of concerns:

**Refactored Navigation Controller (Major Simplification)**:
- **Simplified from 384 → 211 lines**: Achieved 45% code reduction through over-engineering elimination
- **Removed 16+ helper functions**: Replaced complex predicate system with direct array index calculations
- **Streamlined navigation logic**: Two main functions (`moveUp()`, `moveDown()`) with inline bounds checking
- **Maintained full functionality**: All sliding window, wrap-around, and API compatibility preserved
- **Direct calculations**: Eliminated unnecessary abstraction layers while keeping code readable

**Technical Improvements**:
- **Inline bounds checking**: Replaced `canMoveUpWithinWindow()`, `canScrollWindowUp()` with direct conditions
- **Consolidated state management**: Eliminated separate action functions for window/cursor movement
- **Clear variable names**: `visibleRangeStartIndex` instead of `windowStart` for better clarity
- **Simplified property bindings**: Direct calculations in `globalIndex` and `visibleSnippetWindow`

**Benefits**: 
- **Reduced cognitive load**: Easier to understand navigation logic without layers of abstraction
- **Better maintainability**: Fewer functions to track and modify for changes
- **Improved debuggability**: Direct calculations easier to trace and troubleshoot
- **Lower bug risk**: Simpler code with fewer complex interactions between functions
- **Easier extensions**: Cleaner foundation for future navigation enhancements

### JSDoc Documentation Standards
Comprehensive JSDoc comments added to 20+ functions across the codebase for maintainability:

**Documentation Coverage**:
- **Navigation functions**: All helper functions with parameter types, side effects, and examples
- **Data management**: Validation and loading functions with security boundaries documented
- **Performance tracking**: Binding optimization and performance monitoring functions
- **Computed properties**: Complex calculations like `visibleSnippetWindow` and `globalIndex`

**Documentation Pattern**:
```javascript
/**
 * Brief function description with purpose
 * Extended explanation for complex behavior, edge cases, examples
 * 
 * @param {type} paramName - Parameter description with constraints
 * @returns {type} Return value description
 * 
 * Side effects:
 * - State changes, logging, notifications documented
 * - Performance implications noted
 */
function exampleFunction(param) {
    // Implementation
}
```

**Benefits**: Self-documenting code reduces cognitive load, improves debugging, and enables faster onboarding for future development.

## Code Quality Documentation

### Function Documentation Guidelines
All complex functions use JSDoc format with:
- **Purpose and behavior**: Clear description of what the function does
- **Parameter documentation**: Types, constraints, and expected values
- **Return value specification**: Type and meaning of returned data
- **Side effects**: State changes, logging, notifications, performance implications
- **Examples**: For complex mathematical calculations and edge cases
- **Security notes**: Validation boundaries and safety measures

**Priority Areas Documented**:
1. Navigation logic (condition predicates, actions, wrap-around calculations)
2. Data validation and loading (multi-level validation, error handling)
3. Performance monitoring (binding optimization, calculation tracking)
4. UI state management (computed properties, debug logging)

**IMPORTANT**: All new functions must include JSDoc documentation following the established pattern above. This ensures consistent code quality and maintainability.

### Performance Optimization Patterns
**Eliminate Over-Engineering**: The codebase has been systematically simplified to remove unnecessary complexity:

**Three-Stage Caching Elimination**: Replaced over-engineered `filteredSnippets` → `highlightedSnippets` → `displayedSnippets` pipeline with single `processedSnippets` property for better maintainability and equivalent performance.

**Header Function Consolidation**: Consolidated 8+ trivial header functions with excessive documentation into single `getCountText()` function with clear conditional logic, removing ~75 lines of unnecessary code.

**Principles**:
- Prefer inline logic over excessive function delegation for simple operations
- Consolidate trivial functions that only return single values or simple calculations
- Eliminate intermediate caching layers unless they provide measurable performance benefits
- Keep documentation proportional to code complexity

### Function Extraction Patterns
**Complex Conditional Logic**: When functions have multiple nested conditions handling different UI states, extract each state into focused functions:

```javascript
// Before: Complex nested conditionals
function getCountText() {
    if (condition1) { return "message1" }
    if (condition2 && subcondition) { return "complex message" }
    // ... more conditions
}

// After: Clear delegation with focused helpers
function getCountText() {
    if (isEmpty()) return getEmptyStateMessage()
    if (isSearchActive()) return getSearchStateMessage()
    return getNormalMessage()
}
```

**Benefits**: Improved testability, easier modification of specific cases, reduced cognitive load, better maintainability.

### Validation Logic Consolidation
**Implementation**: Unified validation utility (`utils/Validation.qml`) eliminates code duplication across multiple components.

**Problem Solved**: The same snippet validation logic was repeated in 4+ places (`shell.qml`, `CombiningModeController.qml`, `SnippetCombiner.qml`, `OverlayWindow.qml`), making maintenance difficult and increasing risk of inconsistent validation behavior.

**Architecture**:
- **Single source of truth**: All validation logic centralized in singleton
- **Consistent validation**: Same validation rules applied across all components
- **Maintainable constants**: Validation limits sourced from Constants.validation
- **Backward compatibility**: Preserved existing error messages and logging behavior

**Key Functions**:
- `isValidSnippet()` - Comprehensive validation with size limits and detailed logging
- `isValidSnippetStructure()` - Fast validation without size limits or logging
- `isValidSnippetArray()` - Collection validation for combination operations  
- `validateSnippetForAddition()` - UI-specific validation with error callback support

**Benefits**: Single point of maintenance for validation logic, consistent behavior across components, reduced code duplication (~100+ lines eliminated), improved testability.

### Debug Logging Standards
**Centralized Pattern**: Use single canonical `debugLog()` function with property delegation pattern:

```javascript
// In shell.qml - canonical implementation
function debugLog(message) {
    if (isDebugLoggingEnabled) {
        console.log(message)
    }
}

// In components - receive as property
property var debugLog: null

// In parent - pass function down
Component {
    debugLog: root.debugLog
}
```

**Guidelines**: Always use passed `debugLog` property, never create local wrapper functions, consistent emoji markers for categorization.

## Development Resources

### QuickShell Documentation
- **Official Guide**: https://quickshell.org/docs/v0.2.0/guide/
- **Official Examples**: https://git.outfoxxed.me/quickshell/quickshell-examples
- **Advanced Shell Reference**: https://github.com/caelestia-dots/shell

### QuickShell Best Practices
Based on official examples:
- Use `qs -p shell.qml` for command-line testing
- Structure: ShellRoot with LazyLoader for conditional windows
- Use Scope for complex logic organization
- PanelWindow with proper anchoring for overlays
- LazyLoader reduces memory when windows aren't active

### Development Commands
```bash
# Run snippet manager (normal mode) - requires environment variable for JSON loading
QML_XHR_ALLOW_FILE_READ=1 qs -p shell.qml

# Run with verbose QuickShell logging and JSON loading
QML_XHR_ALLOW_FILE_READ=1 qs -p shell.qml --verbose

# Run with debug mode (requires debugMode: true in shell.qml)
QML_XHR_ALLOW_FILE_READ=1 qs -p shell.qml --verbose

# Test text injection directly
wtype "Hello from snippet manager!"
```

**IMPORTANT**: Always test changes by running `QML_XHR_ALLOW_FILE_READ=1 qs -p shell.qml` after making modifications to ensure the application loads correctly and can access the JSON file.

### Debug Mode
Toggle debug logging by changing `debugMode: true/false` in shell.qml:
- **Normal mode**: Clean output, no debug messages
- **Debug mode**: Comprehensive emoji-marked logging for keyboard navigation, focus management, and user interactions

**IMPORTANT**: Always use `window.debugLog()` for debug messages instead of `console.log()`. This ensures conditional logging based on the debug mode setting and maintains consistent emoji-marked debug output throughout the application.

**IMPORTANT**: Always add JSDoc comments to all new functions following the established documentation pattern. This maintains code quality and helps future development.

### Hyprland Integration
```bash
# Add to hyprland.conf (recommended)
bind = SUPER SHIFT, SPACE, exec, qs -p /absolute/path/to/snippet-manager/shell.qml
```

### Known Issues & Current Status
- ✅ **QuickShell compatibility**: Fixed with quickshell-git package
- ✅ **UI visibility**: Fixed with high-contrast design and proper Component structure
- ✅ **Process API**: Fixed by removing non-existent `onErrorOccurred` property
- ✅ **Keyboard navigation**: Fixed with HyprlandFocusGrab for reliable input capture
- ✅ **Focus management**: Coordinated focus system eliminates race conditions between Qt and HyprlandFocusGrab
- ✅ **Debug system**: Working conditional logging with emoji markers for development
- ✅ **Text injection**: Fixed with proper `Quickshell.execDetached()` syntax and detached script approach
- ✅ **JSON loading reliability**: Fixed working directory dependency using Qt.resolvedUrl()

### Current Working Features
- ✅ Overlay shows immediately on command execution
- ✅ JSON-based snippet loading from data/snippets.json (10 test snippets)
- ✅ Simplified JSON schema (title + content only, no id field)
- ✅ **Empty state handling** - graceful UI when no snippets available with clear user guidance
- ✅ **Sliding window navigation** - access ALL snippets while displaying only 5
- ✅ **Wrap-around navigation** - infinite scrolling in both directions
- ✅ **Smart header feedback** - shows current position "X of Y snippets"
- ✅ Keyboard navigation (↑/↓ arrows, Enter, Esc) with smooth scrolling
- ✅ Mouse interaction (hover + click)
- ✅ **Text injection via wtype** - working with detached script approach and proper `execDetached()` syntax
- ✅ Auto-exit after selection or dismissal
- ✅ Clean UI with subtitle design (no numbers, clean titles)
- ✅ Debug mode with comprehensive logging system
- ✅ **Performance optimized** - eliminated binding loops in displayedSnippets property
- ✅ **Focus reliability** - coordinated focus management prevents race conditions

### Sliding Window Navigation Implementation
- **windowStart property**: Tracks the first snippet index in the visible window
- **displayedSnippets computed property**: Uses `snippets.slice(windowStart, windowStart + maxDisplayed)`
- **globalIndex property**: Computes absolute position as `windowStart + currentIndex`
- **VS Code-style navigation**: Smooth scrolling that maintains visual continuity
- **Within-window movement**: Arrow keys move cursor locally until boundary reached
- **Boundary scrolling**: At edges, window slides by 1 position while cursor stays at boundary
- **Full range access**: Navigate through all snippets (tested with 8 snippets)
- **Robust edge handling**: Clear feedback at absolute top/bottom boundaries

### Performance Optimization: Binding Loop Fix
**Issue**: The `displayedSnippets` property previously caused QML binding loops due to side effects within the binding.

**Solution**: 
- Made binding pure with `readonly property var displayedSnippets`
- Separated debug tracking to `onDisplayedSnippetsChanged` handler
- Eliminated unnecessary recalculations and callback scheduling

**Technical Implementation**:
```javascript
// Before (caused binding loops)
property var displayedSnippets: {
    Qt.callLater(function() { calculationCount++ })  // Side effect!
    return snippets.slice(windowStart, end)
}

// After (pure binding)  
readonly property var displayedSnippets: {
    if (snippets.length === 0) return []
    const end = Math.min(windowStart + maxDisplayed, snippets.length)
    return snippets.slice(windowStart, end)
}

// Debug tracking handled separately
onDisplayedSnippetsChanged: trackCalculation()
```

**Benefits**:
- Zero binding loop warnings in console output
- Optimal performance - recalculates only when dependencies change
- Maintains all debug tracking functionality
- Follows QML best practices for computed properties

### Performance Optimization: 3-Stage Caching Architecture
**Enhancement**: Replaced single `displayedSnippets` property with 3-stage caching system for optimal performance.

**Architecture** (`ui/OverlayWindow.qml:30-84`):
- **Stage 1** `filteredSnippets`: Only recomputes when search text changes
- **Stage 2** `highlightedSnippets`: Only recomputes when filtering results or search text changes  
- **Stage 3** `displayedSnippets`: Only recomputes when navigation state changes

**Performance Monitoring**: Added separate counters (`filteringCalculationCount`, `highlightingCalculationCount`, `displayCalculationCount`) with debug handlers to track optimization effectiveness.

**Benefits**:
- Navigation operations no longer trigger expensive filtering operations
- Search performance scales better with larger snippet collections
- Clear separation between filtering, highlighting, and display logic
- Detailed performance monitoring for future optimization efforts

### Persistent Focus with WlrLayershell

Replaced HyprlandFocusGrab with Wayland layer shell exclusive keyboard focus to prevent system shortcuts from dismissing the overlay.

**Key Configuration**:
- `WlrLayer.Overlay` - positions above all windows including fullscreen
- `WlrKeyboardFocus.Exclusive` - prevents system shortcut interruption  
- `namespace: "snippet-manager"` - external tool identifier

**Focus Protection**: Timer-based acquisition with 3 retry attempts and desktop notifications for failures.

**Protocol Monitoring**: Connections object monitors WlrLayershell property changes and notifies user of external modifications affecting functionality.

**Result**: Screenshots (super+p) and other shortcuts work without closing overlay.

### Navigation Patterns (8 snippets, 5 displayed):
```
Initial:     Window [0,1,2,3,4] cursor at 0 → Global index 0
Down 4x:     Window [0,1,2,3,4] cursor at 4 → Global index 4
Down 1x:     Window [1,2,3,4,5] cursor at 4 → Global index 5 (scrolled!)
Down 2x:     Window [3,4,5,6,7] cursor at 4 → Global index 7 (end)
Down 1x:     Window [0,1,2,3,4] cursor at 0 → Global index 0 (wrapped!)
Up scroll:   Window [2,3,4,5,6] cursor at 0 → Global index 2 (reverse)
```

### Wrap-Around Navigation Implementation
- **Infinite scrolling**: No dead ends - navigation continues infinitely in both directions
- **Down wrap-around**: From last item (global index 7) → jumps to first item (global index 0)
- **Up wrap-around**: From first item (global index 0) → jumps to last item (global index 7)  
- **Smart positioning**: Wrap-around places window and cursor optimally for continued navigation
- **Seamless UX**: Users can navigate through collections of any size without boundaries
- **Visual continuity**: Window positioning ensures selected item is always clearly visible

### Wrap-Around Logic:
```javascript
// Down arrow at absolute bottom: windowStart = 0, currentIndex = 0
// Up arrow at absolute top: windowStart = max(0, total-maxDisplayed), currentIndex = min(4, total-1)
```

## Text Injection Implementation

### Hyprland Native Clipboard System
The text injection system uses Hyprland's native clipboard and key dispatch capabilities for optimal performance and reliability.

**Core Implementation:**
```javascript
onSnippetSelected: function(snippet) {
    console.log("📋 Selected snippet:", snippet.title)
    root.debugLog("🚀 Launching detached script with text argument...")
    
    // Use command array + working directory for Quickshell.execDetached()
    var command = ["/home/jc/Dev/snippet-manager/inject-text.sh", snippet.content]
    Quickshell.execDetached(command, "/home/jc/Dev/snippet-manager")
    
    // Exit immediately
    Qt.quit()
}
```

### Hyprland-Native Script Architecture
**File**: `inject-text.sh` - Uses Hyprland's native clipboard and key dispatch system

**Key Features:**
1. **Application Detection**: Automatically detects terminal vs GUI applications
2. **Smart Paste Shortcuts**: Uses `Ctrl+Shift+V` for terminals, `Ctrl+V` for other apps
3. **Clipboard Backup/Restore**: Minimizes clipboard pollution through quick backup/restore cycle
4. **Instant Injection**: Leverages `hyprctl dispatch sendshortcut` for native paste operations

**Application Detection Logic:**
```bash
# Detect active window class using Hyprland
active_window_class=$(hyprctl activewindow -j | grep '"class":' | cut -d'"' -f4)

if [[ "$active_window_class" == "com.mitchellh.ghostty" ]]; then
    paste_shortcut="CTRL+SHIFT,V,"  # Terminal paste
else
    paste_shortcut="CTRL,V,"        # Standard paste
fi

# Execute instant paste via Hyprland dispatcher
hyprctl dispatch sendshortcut "$paste_shortcut"
```

### Security & Performance Benefits
1. **No dependency on external text injection tools** - Uses native Hyprland capabilities
2. **Instant bulk injection** - Much faster than character-by-character typing
3. **Input validation**: 10KB length limit prevents resource exhaustion attacks
4. **Clipboard pollution minimization** - Quick backup/restore cycle
5. **Application-aware pasting** - Automatically uses correct paste shortcut

### Input Validation System (P1 Critical Security)
Comprehensive validation in `shell.qml` prevents crashes and security issues from malformed snippets:

**Validation Layers**:
1. **Object Structure**: Ensures items are objects, not null/string/number
2. **Required Fields**: Validates presence of `title` and `content` properties
3. **Type Safety**: Enforces string types for both title and content
4. **Content Limits**: 
   - Title: 200 characters maximum
   - Content: 10KB maximum (consistent with inject-text.sh security boundary)

**Graceful Degradation**:
- Invalid snippets filtered out with detailed console warnings
- Valid snippets continue loading normally
- Application never crashes from malformed JSON data
- Users receive clear feedback about validation failures

**Security Benefits**:
- Prevents UI crashes from missing properties (`snippet.title` on undefined objects)
- Blocks memory exhaustion from oversized content
- Ensures consistent security boundaries between QML and shell script layers
- Eliminates type confusion attacks (non-string content causing injection failures)

### Dependencies
- **wl-copy/wl-paste**: Wayland clipboard utilities
- **hyprctl**: Hyprland compositor control tool
- **timeout**: Command timeout utility (standard on most systems)

**Benefits**: Prevents infinite hangs, provides user feedback, maintains system stability with bounded execution time.

### Cursor Positioning Support
**Feature**: Intelligent cursor positioning using `[cursor]` markers within snippet content.

**Implementation**: After text injection, cursor is positioned using Hyprland key dispatch:

```bash
# Parse cursor marker and calculate positioning
if [[ "$text" == *"[cursor]"* ]]; then
    prefix="${text%%\[cursor\]*}"     # Text before marker
    suffix="${text##*\[cursor\]}"     # Text after marker  
    cursor_offset=${#suffix}          # Characters to move back
    clean_text="${prefix}${suffix}"   # Remove marker from text
    
    # After text injection, position cursor using Hyprland dispatcher
    for ((i=0; i<cursor_offset; i++)); do
        hyprctl dispatch sendshortcut "Left" || break
    done
fi
```

**Usage Examples**:
```json
{
    "title": "Function Template",
    "content": "function myFunction() {\n    [cursor]\n    return true;\n}"
},
{
    "title": "Email Template", 
    "content": "Hi [cursor],\n\nBest regards,\nYour Name"
}
```

### Technical Notes
- **execDetached syntax**: Use command array + working directory pattern from QuickShell DesktopAction docs
- **Hyprland integration**: Native clipboard and key dispatch system provides optimal performance
- **Process isolation**: Detached script runs independently after QuickShell exits
- **Timeout protection**: Bounded execution prevents hanging with desktop error notifications

## Focus Management & Cursor Configuration

### Current Solution: Hyprland Cursor Configuration
The focus switching issue is resolved by configuring Hyprland cursor behavior:

```bash
# Add to hyprland.conf
cursor {
    no_warps = false
}
```

This setting allows the cursor to warp, which maintains proper window focus when the snippet manager overlay appears and disappears.

### Advanced Focus Preservation (Future Enhancement)
For environments where `no_warps = true` is required or for more reliable focus management, implement pre-overlay window capture:

**Problem**: QuickShell overlay interferes with `hyprctl activewindow` queries, returning overlay information instead of the original focused window.

**Solution Strategy**:
1. **Capture window BEFORE showing overlay**: Get active window address in shell.qml before LazyLoader becomes active
2. **Alternative dispatchers**: Test Hyprland's focus dispatchers:
   - `focuscurrentorlast` - Focus current or last focused window
   - `focusurgentorlast` - Focus urgent or last focused window
3. **Timing considerations**: Ensure window capture happens before overlay gains focus

**Implementation Notes**:
- Move `captureFocusedWindow()` call to occur before overlay becomes visible
- Test if alternative dispatchers eliminate need for explicit address tracking
- Consider using Hyprland's window history rather than manual address storage

### Current Status
- ✅ **Simple solution**: `no_warps = false` configuration resolves focus issues
- 🔄 **Advanced solution**: Available for future implementation if needed
- 📋 **Dispatcher testing**: `focuscurrentorlast` and `focusurgentorlast` remain untested but promising

## Path Resolution Fixes
- **JSON loading**: Fixed using `Qt.resolvedUrl("data/snippets.json")` for reliable file access from any directory
- **Script execution**: Fixed using `Qt.resolvedUrl("inject-text.sh")` for portable script path resolution

## Constants Architecture
- **Centralized configuration**: All UI dimensions, timing, styling values, and validation limits in `/utils/Constants.qml` singleton
- **QML singleton pattern**: Use `import "../utils"` then `Constants.propertyName` for consistent values
- **Shell script integration**: Timing constants documented in comments for bash script reference

**Organized Constant Categories**:
- `validation`: Data validation limits (maxTitleLength: 200, maxContentLength: 10000)
- `colors`: UI color palette (mainBorder, selectedBackground, unselectedBackground, etc.)
- `search`: Search-related constants (characterCountThreshold: 50, placeholderTextColor, etc.)
- `layout`: Layout calculations (emptyStateWidthFraction: 0.9)

**IMPORTANT**: Always use Constants references instead of hardcoded values to maintain consistency and enable easy configuration changes.

## Error Handling & User Notifications

### Script Error Handling
The `inject-text.sh` script includes proper error handling with timeout protection and graceful exit behavior. Critical fix: replaced invalid `return` statement with `exit 1` on clipboard failures to prevent memory leaks from hanging processes.

### Search Highlighting Security
The search highlighting function includes XSS protection using HTML escaping. Critical fix: replaced `$1` backreference with escaped search term directly to prevent HTML injection through regex replacement in `ui/OverlayWindow.qml:402`.

### Desktop Notification Strategy
For critical errors and warnings that users need to be aware of, implement desktop notifications using `notify-send`:

**Implementation Pattern with Throttling:**
```javascript
// In shell.qml - notification system with spam prevention
function notifyUser(title, message, urgency = "normal") {
    const notificationKey = title + "|" + message
    
    // Always allow critical notifications (never throttle important errors)
    if (urgency !== "critical") {
        notificationCounts[notificationKey] = (notificationCounts[notificationKey] || 0) + 1
        // Throttle after 2 instances of same non-critical notification
        if (notificationCounts[notificationKey] > 2) return
    }
    
    const command = ["notify-send", "-u", urgency, title, message]
    Quickshell.execDetached(command)
}
```

**Throttling Behavior:**
- **Critical notifications**: Always sent (no throttling for important errors)
- **Normal/Low notifications**: Limited to 2 instances per unique title+message combination
- **Prevents spam**: Repeated error conditions don't flood desktop notifications
- **Memory efficient**: Simple counter-based tracking without cleanup overhead

**Notification Categories:**
- **Critical**: File system errors, JSON parsing failures, security violations
- **Normal**: Empty snippets, validation warnings, configuration issues  
- **Low**: Informational messages, successful operations

**Benefits:**
- **Non-blocking**: User sees errors even when overlay is dismissed
- **System integration**: Uses standard desktop notification system
- **Severity awareness**: Different urgency levels for different error types
- **Debugging aid**: Helps identify issues in production environments

### Comprehensive Error Handling Implementation

**Process Execution Safety**:
- `validateSnippetData()` function for runtime data validation
- Try-catch blocks around all `Quickshell.execDetached()` calls  
- Desktop notifications for injection failures
- Script path validation before execution

**UI Interaction Safety**:
- `validateAndSelectSnippet()` function for consistent validation
- Mouse click validation before snippet selection
- Bounds checking for hover events and array access
- Prevents crashes from corrupted `modelData`

**Race Condition Prevention**:
- Atomic array snapshots in navigation logic
- Elimination of check-then-use patterns  
- Safe bounds validation with captured snapshots
- Additional empty array checks in navigation

**Error Notification Integration**: All critical errors now trigger desktop notifications with appropriate urgency levels, providing users immediate feedback when operations fail.

## Empty State Handling Implementation

### Dedicated Empty State UI
**Component**: `/ui/EmptyStateView.qml` - Modular component for clean empty state presentation

**Architecture**: Conditional UI rendering based on `hasValidSnippets` property
- Empty state UI shown when `snippets.length === 0`
- Normal snippet list hidden during empty state
- Conditional header and instruction text

**User Experience**:
- Clear "No Snippets Available" message
- Helpful guidance: "Add snippets to data/snippets.json to get started"  
- File location reference for easy access
- Clean, professional appearance without cluttering fake data

**Navigation Safety**: 
- Navigation keys disabled when no valid snippets available
- Escape key always functional regardless of snippet state
- Prevents crashes and undefined behavior with empty arrays
- Debug logging: "🚫 Navigation disabled - no valid snippets available"

**Data Model Integrity**:
- Clean empty array `[]` when no valid snippets (no fake entries)
- Enhanced validation warnings distinguish between empty JSON vs filtered results
- Graceful handling of missing files, parse errors, and validation failures

### Comprehensive Error Notification System
Desktop notification system implemented using `notify-send` for all critical error states:

**Coverage Areas**:
- **Data Loading Failures**: HTTP errors, missing files, JSON parsing failures
- **Validation Errors**: Empty snippets, malformed data, invalid properties
- **UI Runtime Errors**: Corrupted snippet data, missing properties, selection failures

**Implementation Pattern**:
```javascript
// In shell.qml - notification helper function already implemented
function notifyUser(title, message, urgency = "normal") {
    const command = ["notify-send", "-u", urgency, title, message]
    Quickshell.execDetached(command)
}

// Critical error notifications integrated at key failure points
// OverlayWindow receives notifyUser function via property passing
```

**Notification Categories**:
- **Critical**: File system errors, JSON parsing failures, corrupted data
- **Normal**: Validation warnings, configuration issues, all invalid snippets
- **Low**: Empty snippets with user guidance, informational messages

**Benefits**: Transforms silent failures into clear user feedback, eliminates confusion when snippet manager appears empty, improves troubleshooting without checking console logs.

## Search Feature Implementation

### Search TextField Foundation
Basic search functionality implemented with QuickShell TextField component:

**Core Implementation**:
- Search input positioned between header and snippet list
- Focus management integrated with HyprlandFocusGrab system
- Keyboard handling: Escape closes overlay, Enter selects current snippet
- Styled to match existing UI theme with Constants.search configuration

**Focus Management Pattern**:
```qml
// HyprlandFocusGrab coordination with search input
onActiveChanged: {
    if (active) {
        Qt.callLater(function() {
            searchInput.forceActiveFocus()
        })
    }
}
```

**Key Events Handling**:
```qml
Keys.onEscapePressed: function(event) {
    event.accepted = true
    Qt.quit()
}

Keys.onReturnPressed: function(event) {
    // Select currently highlighted snippet
    const selectedSnippet = navigationController.visibleSnippetWindow[navigationController.currentIndex]
    validateAndSelectSnippet(selectedSnippet, "enter_key")
}
```

### Fuzzy Search Implementation ✅
**Modular Architecture**: Implemented as `utils/FuzzySearch.qml` singleton for clean separation of concerns and reusability.

**Core Integration**:
```qml
readonly property var filteredSnippets: {
    return FuzzySearch.searchAndRank(sourceSnippets, searchInput?.text || "")
}
```

**Multi-Criteria Scoring Algorithm**:
- **Position-based weighting**: Prefix matches (1000pts) > Word boundary (800pts) > Substring (400pts) > Fuzzy (200pts)
- **Field importance**: Title matches weighted 3x higher than content matches
- **Enhancement bonuses**: Capital letter matches, length normalization
- **Typo tolerance**: Basic fuzzy matching with 70% character coverage threshold

**Adaptive Filtering**: Intelligent result filtering based on relative score thresholds
- **30% relative threshold**: Shows results within 30% of top score for contextual relevance
- **150pt absolute minimum**: Always shows high-quality matches regardless of relative scores
- **Smart result limiting**: 1-10 results based on query specificity (empty query shows all)
- **Top result guarantee**: Always shows best match even if standing alone

**Performance**: Optimized for real-time search with <100 snippets, ES5 compatible for QML JavaScript engine

### Keyboard Navigation from Search Field
**QuickShell Launcher Pattern**: Search field maintains focus while delegating arrow keys to NavigationController
- Up/Down arrows in search TextField delegate directly to `navigationController.moveUp()` and `navigationController.moveDown()`
- Progressive Escape behavior: first Escape clears search, second Escape exits overlay
- Enter key triggers snippet selection using existing validation chain
- Legacy keyHandler disabled to prevent focus conflicts

**Implementation Pattern**:
```qml
Keys.onUpPressed: function(event) {
    event.accepted = true
    if (window.hasValidSnippets) {
        navigationController.moveUp()
    }
}
```

### Search Input Validation
**Implementation**: RegularExpressionValidator with user-friendly length limits and visual feedback
- Maximum input length: 100 characters (configurable via Constants.search.maxInputLength)
- Prevention-based validation: blocks input beyond limit rather than truncating
- Character count indicator: appears after 50 characters with color-coded feedback
- Visual warning: orange color when approaching or at limit

**Technical Implementation**:
```qml
validator: RegularExpressionValidator {
    regularExpression: new RegExp("^.{0," + Constants.search.maxInputLength + "}$")
}

// Character count indicator
Text {
    visible: parent.text.length > 50
    text: parent.text.length + "/" + Constants.search.maxInputLength
    color: parent.text.length >= Constants.search.maxInputLength ? Constants.search.warningColor : "#aaaaaa"
}
```

### Security Implementation
**HTML Injection Prevention**: Critical security measures implemented for Text.RichText contexts:
- `escapeHtml()` function sanitizes all user content before HTML generation
- `highlightSearchTerm()` includes comprehensive input validation and error handling
- All snippet titles and search terms are HTML-escaped to prevent XSS attacks
- Graceful error recovery prevents crashes from malformed inputs

**Security Functions** (ui/OverlayWindow.qml):
```javascript
function escapeHtml(text) {
    return text.replace(/&/g, '&amp;')
              .replace(/</g, '&lt;')
              .replace(/>/g, '&gt;')
              .replace(/"/g, '&quot;')
              .replace(/'/g, '&#39;')
}
```

**IMPORTANT**: Always use `escapeHtml()` before displaying user content in Text.RichText contexts to prevent HTML injection vulnerabilities.

### Search Feature Phases
**Phase 1**: Basic search TextField with real-time filtering, keyboard navigation, and input validation ✅
**Phase 2**: Enhanced visual feedback and highlighting with HTML injection security ✅
  - Performance optimized: Pre-computed highlighting during filtering eliminates render-time calculations
  - Code quality: Extracted complex header logic into `getHeaderText()` helper function with JSDoc documentation
  - Maintenance: Removed duplicate constants, comprehensive error handling in all highlighting operations
**Phase 3**: Fuzzy search with relevance-based ranking ✅
  - **Problem solved**: "co" search now ranks "Commit progress" before "Update CLAUDE.md file"
  - **Modular design**: `utils/FuzzySearch.qml` singleton for reusability and maintainability
  - **Zero regressions**: Full backward compatibility with existing search functionality

**Key Design Patterns**:
- Search field as single point of keyboard input (QuickShell launcher pattern)
- NavigationController provides public API for external control
- Reactive property binding enables instant filtering on keystroke
- Progressive UI feedback (clear search → exit overlay)
- User-friendly input validation with visual feedback
- HTML escaping for all user content in RichText contexts