---
summary: Swift structured concurrency patterns and best practices
read_when:
  - Implementing async/await code
  - Working with actors
  - Handling task cancellation
---

# Swift Concurrency

## Async/Await Basics

### Async Functions

```swift
func fetchUser(id: String) async throws -> User {
    let url = URL(string: "https://api.example.com/users/\(id)")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(User.self, from: data)
}

// Calling
Task {
    do {
        let user = try await fetchUser(id: "123")
        print(user)
    } catch {
        print("Error: \(error)")
    }
}
```

### Async Properties

```swift
struct ImageLoader {
    let url: URL
    
    var image: UIImage {
        get async throws {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                throw ImageError.invalidData
            }
            return image
        }
    }
}
```

## Task Groups

### Parallel Execution

```swift
func fetchAllUsers(ids: [String]) async throws -> [User] {
    try await withThrowingTaskGroup(of: User.self) { group in
        for id in ids {
            group.addTask {
                try await fetchUser(id: id)
            }
        }
        
        var users: [User] = []
        for try await user in group {
            users.append(user)
        }
        return users
    }
}
```

### With Results (Don't Throw on Individual Failures)

```swift
func fetchAllUsersSafe(ids: [String]) async -> [Result<User, Error>] {
    await withTaskGroup(of: (String, Result<User, Error>).self) { group in
        for id in ids {
            group.addTask {
                do {
                    let user = try await fetchUser(id: id)
                    return (id, .success(user))
                } catch {
                    return (id, .failure(error))
                }
            }
        }
        
        var results: [Result<User, Error>] = []
        for await (_, result) in group {
            results.append(result)
        }
        return results
    }
}
```

## Actors

### Basic Actor

```swift
actor ImageCache {
    private var cache: [URL: UIImage] = [:]
    
    func image(for url: URL) -> UIImage? {
        cache[url]
    }
    
    func store(_ image: UIImage, for url: URL) {
        cache[url] = image
    }
    
    func clear() {
        cache.removeAll()
    }
}

// Usage (must await)
let cache = ImageCache()
await cache.store(image, for: url)
if let cached = await cache.image(for: url) { ... }
```

### nonisolated

```swift
actor DataStore {
    let id: String  // Immutable, safe to access
    private var items: [Item] = []
    
    nonisolated var storeID: String { id }  // No await needed
    
    func addItem(_ item: Item) {
        items.append(item)
    }
}

let store = DataStore(id: "main")
print(store.storeID)  // No await
await store.addItem(item)  // Needs await
```

### @MainActor

```swift
@MainActor
@Observable
class ViewModel {
    var items: [Item] = []
    var isLoading = false
    var error: Error?
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            items = try await api.fetchItems()
        } catch {
            self.error = error
        }
    }
}

// All property access and method calls are on main thread
```

### Isolated Parameters

```swift
func updateUI(on actor: isolated MainActor, with data: Data) {
    // Runs on main actor, no await needed inside
    label.text = String(data: data, encoding: .utf8)
}
```

## Task Cancellation

### Checking Cancellation

```swift
func processItems(_ items: [Item]) async throws {
    for item in items {
        // Check before expensive work
        try Task.checkCancellation()
        
        await processItem(item)
    }
}

// Or cooperative checking
func processItems(_ items: [Item]) async {
    for item in items {
        if Task.isCancelled { return }
        await processItem(item)
    }
}
```

### withTaskCancellationHandler

```swift
func downloadFile(url: URL) async throws -> Data {
    let session = URLSession.shared
    
    return try await withTaskCancellationHandler {
        let (data, _) = try await session.data(from: url)
        return data
    } onCancel: {
        // Called immediately when cancelled
        session.invalidateAndCancel()
    }
}
```

### Task Lifetime in Views

```swift
struct DataView: View {
    @State private var data: [Item] = []
    
    var body: some View {
        List(data) { item in
            ItemRow(item: item)
        }
        .task {
            // Automatically cancelled when view disappears
            data = await fetchData()
        }
    }
}
```

## AsyncSequence

### For-await-in

```swift
func processNotifications() async {
    for await notification in NotificationCenter.default.notifications(named: .userDidLogin) {
        print("User logged in: \(notification)")
    }
}
```

### AsyncStream

```swift
func locationUpdates() -> AsyncStream<CLLocation> {
    AsyncStream { continuation in
        let manager = CLLocationManager()
        let delegate = LocationDelegate { location in
            continuation.yield(location)
        }
        manager.delegate = delegate
        manager.startUpdatingLocation()
        
        continuation.onTermination = { _ in
            manager.stopUpdatingLocation()
        }
    }
}

// Usage
for await location in locationUpdates() {
    print("Location: \(location)")
}
```

### AsyncThrowingStream

```swift
func fetchPages<T: Decodable>(url: URL) -> AsyncThrowingStream<T, Error> {
    AsyncThrowingStream { continuation in
        Task {
            var nextURL: URL? = url
            while let currentURL = nextURL {
                do {
                    let (data, response) = try await URLSession.shared.data(from: currentURL)
                    let page = try JSONDecoder().decode(Page<T>.self, from: data)
                    for item in page.items {
                        continuation.yield(item)
                    }
                    nextURL = page.nextURL
                } catch {
                    continuation.finish(throwing: error)
                    return
                }
            }
            continuation.finish()
        }
    }
}
```

## Sendable

### Sendable Types

```swift
// Value types are Sendable by default if all properties are Sendable
struct User: Sendable {
    let id: String
    let name: String
}

// Reference types need explicit conformance
final class Configuration: Sendable {
    let apiKey: String  // Must be let, not var
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
}

// @unchecked for manual thread-safety
final class ThreadSafeCache: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [String: Data] = [:]
    
    func get(_ key: String) -> Data? {
        lock.lock()
        defer { lock.unlock() }
        return storage[key]
    }
}
```

### @Sendable Closures

```swift
func performAsync(_ work: @Sendable @escaping () async -> Void) {
    Task {
        await work()
    }
}

// Captures must be Sendable
let user = User(id: "1", name: "Test")  // Sendable
performAsync {
    print(user)  // OK
}
```

## Common Patterns

### Debouncing

```swift
actor Debouncer {
    private var task: Task<Void, Never>?
    
    func debounce(delay: Duration, action: @Sendable @escaping () async -> Void) {
        task?.cancel()
        task = Task {
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }
            await action()
        }
    }
}
```

### Timeout

```swift
func withTimeout<T>(seconds: Double, operation: @escaping () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await operation()
        }
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw TimeoutError()
        }
        
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}
```

### Retry

```swift
func withRetry<T>(
    maxAttempts: Int = 3,
    delay: Duration = .seconds(1),
    operation: () async throws -> T
) async throws -> T {
    var lastError: Error?
    
    for attempt in 1...maxAttempts {
        do {
            return try await operation()
        } catch {
            lastError = error
            if attempt < maxAttempts {
                try await Task.sleep(for: delay * Double(attempt))
            }
        }
    }
    
    throw lastError!
}
```
