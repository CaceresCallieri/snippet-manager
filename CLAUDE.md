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
- **System Integration**: wtype for text injection, hyprctl for cursor positioning

## Development Phases

### Phase 1: Basic Frontend + Static Data ✅ COMPLETED
**Goal**: Create working overlay UI with static snippet list

**Implemented Features**:
- ✅ Overlay window appears immediately on command execution
- ✅ Keyboard navigation (Up/Down arrows, Enter to select)
- ✅ Mouse navigation (hover to select, click to choose)
- ✅ Embedded static snippet data (5 test snippets)
- ✅ Text injection via wtype with proper error handling
- ✅ Auto-exit after selection or dismissal (Escape key)
- ✅ High-visibility UI with orange borders and clear numbering

**Current File Structure**:
```
quickshell-snippet-manager/
├── snippet-manager             # ✅ Simple startup script
├── shell.qml                   # ✅ Main application (ShellRoot + LazyLoader)
├── ui/
│   └── OverlayWindow.qml       # ✅ Simplified overlay with Repeater-based UI
├── services/                   # (Legacy - not currently used)
│   ├── DataLoader.qml          # (Replaced by embedded data)
│   ├── TextInjection.qml       # (Replaced by inline Process)
│   └── HyprlandService.qml     # (Simplified in shell.qml)
├── data/
│   └── snippets.json           # ✅ Available for future file-based loading
└── test_injection.sh           # ✅ Testing utility
```

**Current Implementation Notes**:
- Simplified architecture with embedded data for reliability
- LazyLoader pattern for memory efficiency
- Direct Process integration for text injection
- Robust UI using Column + Repeater instead of ListView
- Auto-quit functionality for launcher-style behavior

## Key Requirements

### Overlay Window
- Wayland layer overlay (top-most)
- Positioned at current cursor location
- Exclusive keyboard focus when visible
- Fixed size: 400x300 pixels
- Manual dismiss only (Escape key or selection)

### Keyboard Navigation
- `Escape`: Hide overlay
- `Up Arrow`: Move selection up  
- `Down Arrow`: Move selection down
- `Enter`: Select current snippet and inject text

### Global Shortcut
User handles SUPER_L registration via Hyprland configuration.

## Technical Notes

### Dependencies
- QuickShell (Wayland compositor integration)
- wtype (text injection)
- hyprctl (cursor positioning)

### JSON Schema (Phase 1)
```json
[
  {
    "id": "uuid-string",
    "title": "Snippet Title",
    "content": "The actual text content to inject"
  }
]
```

### Integration Points
- Text injection happens after overlay dismissal
- Cursor position obtained via hyprctl
- JSON data loaded from user config directory

## Future Phases
- **Phase 2**: Search functionality, enhanced backend architecture
- **Phase 3**: Variable substitution, preview pane, usage statistics

## Success Criteria for Phase 1
- Overlay appears at cursor within 200ms of activation
- All keyboard navigation works smoothly
- Text injection succeeds for simple text content
- Clean code structure supports easy Phase 2 integration

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
# Run snippet manager (recommended)
./snippet-manager

# Run directly with QuickShell
qs -p shell.qml --verbose

# Test text injection directly
wtype "Hello from snippet manager!"
```

**IMPORTANT**: Always test changes by running `./snippet-manager` after making modifications to ensure the application loads correctly.

### Hyprland Integration
```bash
# Add to hyprland.conf (recommended)
bind = SUPER SHIFT, SPACE, exec, /absolute/path/to/snippet-manager/snippet-manager
```

### Known Issues & Current Status
- ✅ **QuickShell compatibility**: Fixed with quickshell-git package
- ✅ **UI visibility**: Fixed with high-contrast design and proper Component structure
- ✅ **Process API**: Fixed by removing non-existent `onErrorOccurred` property
- ✅ **Keyboard navigation**: Fixed by using Item with Keys instead of PanelWindow directly
- ⚠️ **Issue noted**: Some UI elements may still need refinement for optimal user experience

### Current Working Features
- ✅ Overlay shows immediately on command execution
- ✅ 5 embedded test snippets visible and selectable
- ✅ Keyboard navigation (↑/↓ arrows, Enter, Esc)
- ✅ Mouse interaction (hover + click)
- ✅ Text injection via wtype
- ✅ Auto-exit after selection