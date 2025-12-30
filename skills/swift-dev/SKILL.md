---
name: swift-dev
description: Modern Swift/SwiftUI development for iOS 17+ and macOS 14+. Use when writing SwiftUI views, handling state management (@State, @Observable, @Environment), implementing async/await patterns, composing views, testing Swift code, or following Apple's latest architectural recommendations. Covers property wrappers, structured concurrency, Observation framework, and common gotchas.
---

# Swift Development

Modern Swift/SwiftUI patterns for iOS 17+ and macOS 14+.

## State Management

### Property Wrappers (iOS 17+)

| Wrapper | Use Case |
|---------|----------|
| `@State` | Local view state, value types |
| `@Binding` | Two-way reference to parent's state |
| `@Observable` | Shared state across views (replaces ObservableObject) |
| `@Environment` | Dependency injection, app-wide values |
| `@Bindable` | Create bindings from @Observable objects |

### @Observable (iOS 17+)

```swift
@Observable
class AppState {
    var count = 0
    var user: User?
}

struct ContentView: View {
    @State private var state = AppState()
    
    var body: some View {
        ChildView()
            .environment(state)
    }
}

struct ChildView: View {
    @Environment(AppState.self) private var state
    
    var body: some View {
        // Access state.count - auto-tracks dependencies
        Text("\(state.count)")
    }
}
```

### When to Use What

- **Local UI state** (toggle, text field): `@State`
- **Child needs to modify parent**: `@Binding`
- **Shared across many views**: `@Observable` + `@Environment`
- **System values** (colorScheme, dismiss): `@Environment(\.key)`

## View Composition

### Small, Focused Views

```swift
// GOOD: Focused, reusable
struct UserAvatar: View {
    let user: User
    var size: CGFloat = 44
    
    var body: some View {
        AsyncImage(url: user.avatarURL) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Circle().fill(.gray.opacity(0.3))
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

// BAD: Monolithic view doing too much
struct ProfileScreen: View {
    var body: some View {
        // 200+ lines of nested code
    }
}
```

### View Modifiers

```swift
extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 2)
    }
}

// Usage
Text("Hello").cardStyle()
```

## Async Patterns

### .task Modifier (Preferred)

```swift
struct DataView: View {
    @State private var items: [Item] = []
    @State private var error: Error?
    
    var body: some View {
        List(items) { item in
            ItemRow(item: item)
        }
        .task {
            // Automatically cancelled when view disappears
            do {
                items = try await fetchItems()
            } catch {
                self.error = error
            }
        }
    }
}
```

### Async with ID Changes

```swift
struct DetailView: View {
    let itemID: String
    @State private var item: Item?
    
    var body: some View {
        content
            .task(id: itemID) {
                // Re-runs when itemID changes
                item = try? await fetchItem(id: itemID)
            }
    }
}
```

### Avoid Combine for Simple Cases

```swift
// AVOID: Combine for simple async
class ViewModel: ObservableObject {
    @Published var data: [Item] = []
    private var cancellables = Set<AnyCancellable>()
    
    func load() {
        api.fetchItems()
            .receive(on: DispatchQueue.main)
            .sink { ... }
            .store(in: &cancellables)
    }
}

// PREFER: async/await
@Observable
class ViewModel {
    var data: [Item] = []
    
    func load() async {
        data = try? await api.fetchItems()
    }
}
```

## Common Commands

```bash
# Build
swift build
xcodebuild -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# Test
swift test
xcodebuild test -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Format
swiftformat .

# Lint
swiftlint
swiftlint --fix

# Generate Xcode project
xcodegen generate
```

## File Organization

```
MyApp/
├── App/
│   └── MyAppApp.swift
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── HomeViewModel.swift (if needed)
│   │   └── Components/
│   └── Settings/
├── Shared/
│   ├── Models/
│   ├── Services/
│   └── Extensions/
└── Resources/
```

## Common Gotchas

### 1. @State Initialization

```swift
// WRONG: @State initialized from parameter doesn't update
struct ItemView: View {
    @State private var name: String  // Won't update when parent changes
    
    init(item: Item) {
        _name = State(initialValue: item.name)
    }
}

// RIGHT: Use the source directly or @Binding
struct ItemView: View {
    let item: Item  // Just use the value
    // OR
    @Binding var name: String  // If editing needed
}
```

### 2. Environment Object Access

```swift
// CRASH: Accessing before injection
struct ChildView: View {
    @Environment(AppState.self) var state  // Crashes if not in environment
}

// SAFE: Use optional or ensure injection
struct ChildView: View {
    @Environment(AppState.self) var state?
}
```

### 3. Main Actor for UI Updates

```swift
@Observable
class ViewModel {
    @MainActor var items: [Item] = []  // UI property
    
    func load() async {
        let data = await api.fetch()
        await MainActor.run {
            items = data
        }
    }
}
```

## References

- [references/swiftui-patterns.md](references/swiftui-patterns.md) - Advanced view patterns
- [references/concurrency.md](references/concurrency.md) - Structured concurrency deep-dive
- [references/testing.md](references/testing.md) - Testing strategies
