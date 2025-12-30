---
summary: Advanced SwiftUI view patterns and composition techniques
read_when:
  - Building complex SwiftUI layouts
  - Implementing custom view modifiers
  - Handling navigation and sheets
---

# Advanced SwiftUI Patterns

## Navigation (iOS 16+)

### NavigationStack with Path

```swift
struct ContentView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List(items) { item in
                NavigationLink(value: item) {
                    ItemRow(item: item)
                }
            }
            .navigationDestination(for: Item.self) { item in
                ItemDetailView(item: item)
            }
            .navigationDestination(for: User.self) { user in
                UserProfileView(user: user)
            }
        }
    }
    
    // Programmatic navigation
    func navigateToItem(_ item: Item) {
        path.append(item)
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
}
```

### Coordinator Pattern (When Needed)

```swift
@Observable
class AppCoordinator {
    var path = NavigationPath()
    var sheet: Sheet?
    var alert: AlertState?
    
    enum Sheet: Identifiable {
        case settings
        case profile(User)
        
        var id: String {
            switch self {
            case .settings: return "settings"
            case .profile(let user): return "profile-\(user.id)"
            }
        }
    }
    
    func showSettings() {
        sheet = .settings
    }
    
    func showProfile(_ user: User) {
        sheet = .profile(user)
    }
}
```

## Preference Keys

### Collecting Child Data

```swift
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct MeasuredView<Content: View>: View {
    @Binding var size: CGSize
    let content: Content
    
    var body: some View {
        content
            .background(GeometryReader { geo in
                Color.clear.preference(key: SizePreferenceKey.self, value: geo.size)
            })
            .onPreferenceChange(SizePreferenceKey.self) { size = $0 }
    }
}
```

### Anchor Preferences

```swift
struct BoundsPreferenceKey: PreferenceKey {
    static var defaultValue: [String: Anchor<CGRect>] = [:]
    static func reduce(value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue()) { $1 }
    }
}

// Usage: Spotlight effect, tooltips, etc.
```

## Custom Layouts (iOS 16+)

### Flow Layout

```swift
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }
        
        return (CGSize(width: maxX, height: currentY + lineHeight), positions)
    }
}

// Usage
FlowLayout(spacing: 8) {
    ForEach(tags) { tag in
        TagView(tag: tag)
    }
}
```

## Animation Patterns

### Matched Geometry Effect

```swift
struct HeroAnimation: View {
    @Namespace private var namespace
    @State private var isExpanded = false
    
    var body: some View {
        if isExpanded {
            ExpandedView()
                .matchedGeometryEffect(id: "hero", in: namespace)
                .onTapGesture { withAnimation(.spring()) { isExpanded = false } }
        } else {
            ThumbnailView()
                .matchedGeometryEffect(id: "hero", in: namespace)
                .onTapGesture { withAnimation(.spring()) { isExpanded = true } }
        }
    }
}
```

### Phase Animator (iOS 17+)

```swift
struct PulsingView: View {
    var body: some View {
        Circle()
            .phaseAnimator([false, true]) { content, phase in
                content
                    .scaleEffect(phase ? 1.2 : 1.0)
                    .opacity(phase ? 0.5 : 1.0)
            } animation: { _ in
                .easeInOut(duration: 1)
            }
    }
}
```

### Keyframe Animation (iOS 17+)

```swift
struct BounceView: View {
    @State private var trigger = false
    
    var body: some View {
        Image(systemName: "heart.fill")
            .keyframeAnimator(initialValue: AnimationValues(), trigger: trigger) { content, value in
                content
                    .scaleEffect(value.scale)
                    .offset(y: value.yOffset)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    SpringKeyframe(1.5, duration: 0.2)
                    SpringKeyframe(1.0, duration: 0.2)
                }
                KeyframeTrack(\.yOffset) {
                    SpringKeyframe(-20, duration: 0.2)
                    SpringKeyframe(0, duration: 0.2)
                }
            }
            .onTapGesture { trigger.toggle() }
    }
}

struct AnimationValues {
    var scale: CGFloat = 1.0
    var yOffset: CGFloat = 0
}
```

## Sheets and Alerts

### Type-Safe Sheets

```swift
struct ContentView: View {
    @State private var sheet: SheetType?
    
    enum SheetType: Identifiable {
        case add
        case edit(Item)
        case settings
        
        var id: String {
            switch self {
            case .add: return "add"
            case .edit(let item): return "edit-\(item.id)"
            case .settings: return "settings"
            }
        }
    }
    
    var body: some View {
        content
            .sheet(item: $sheet) { type in
                switch type {
                case .add:
                    AddItemView()
                case .edit(let item):
                    EditItemView(item: item)
                case .settings:
                    SettingsView()
                }
            }
    }
}
```

### Confirmation Dialogs

```swift
struct DeleteButton: View {
    @State private var showConfirmation = false
    let onDelete: () -> Void
    
    var body: some View {
        Button("Delete", role: .destructive) {
            showConfirmation = true
        }
        .confirmationDialog("Delete this item?", isPresented: $showConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: onDelete)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
}
```

## Performance

### Lazy Containers

```swift
// Always use Lazy* for large collections
LazyVStack {  // Not VStack
    ForEach(items) { item in
        ItemRow(item: item)
    }
}

LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
    ForEach(items) { item in
        ItemCard(item: item)
    }
}
```

### Equatable Views

```swift
struct ExpensiveView: View, Equatable {
    let item: Item
    
    var body: some View {
        // Complex rendering
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.item.id == rhs.item.id && lhs.item.updatedAt == rhs.item.updatedAt
    }
}

// Usage
ExpensiveView(item: item).equatable()
```

### drawingGroup for Complex Graphics

```swift
Canvas { context, size in
    // Complex drawing
}
.drawingGroup()  // Renders to Metal texture
```
