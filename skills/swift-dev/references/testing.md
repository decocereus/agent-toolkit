---
summary: Swift testing strategies and patterns
read_when:
  - Writing unit tests
  - Testing async code
  - Mocking dependencies
---

# Swift Testing

## Swift Testing Framework (iOS 18+)

### Basic Tests

```swift
import Testing

@Test func userInitialization() {
    let user = User(name: "Alice", age: 30)
    #expect(user.name == "Alice")
    #expect(user.age == 30)
}

@Test("User age must be positive")
func userAgeValidation() throws {
    #expect(throws: ValidationError.self) {
        try User(name: "Bob", age: -1)
    }
}
```

### Parameterized Tests

```swift
@Test(arguments: [
    ("alice@example.com", true),
    ("invalid", false),
    ("bob@test", false),
    ("valid@domain.co", true)
])
func emailValidation(email: String, isValid: Bool) {
    #expect(Email.isValid(email) == isValid)
}
```

### Async Tests

```swift
@Test func fetchUser() async throws {
    let api = MockAPI()
    let user = try await api.fetchUser(id: "123")
    #expect(user.id == "123")
}
```

### Test Suites

```swift
@Suite("User Tests")
struct UserTests {
    let sut: UserService
    
    init() {
        sut = UserService(api: MockAPI())
    }
    
    @Test func creation() { ... }
    @Test func deletion() async throws { ... }
}
```

## XCTest (iOS 8+)

### Basic XCTest

```swift
import XCTest
@testable import MyApp

final class UserTests: XCTestCase {
    var sut: UserService!
    var mockAPI: MockAPI!
    
    override func setUp() {
        super.setUp()
        mockAPI = MockAPI()
        sut = UserService(api: mockAPI)
    }
    
    override func tearDown() {
        sut = nil
        mockAPI = nil
        super.tearDown()
    }
    
    func testUserCreation() {
        let user = sut.createUser(name: "Alice")
        XCTAssertEqual(user.name, "Alice")
        XCTAssertNotNil(user.id)
    }
    
    func testUserCreationFailure() {
        XCTAssertThrowsError(try sut.createUser(name: "")) { error in
            XCTAssertEqual(error as? ValidationError, .emptyName)
        }
    }
}
```

### Async XCTest

```swift
func testAsyncFetch() async throws {
    let user = try await sut.fetchUser(id: "123")
    XCTAssertEqual(user.id, "123")
}

// Or with expectations for older code
func testAsyncWithExpectation() {
    let expectation = expectation(description: "Fetch completes")
    
    sut.fetchUser(id: "123") { result in
        switch result {
        case .success(let user):
            XCTAssertEqual(user.id, "123")
        case .failure:
            XCTFail("Should not fail")
        }
        expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5.0)
}
```

## Dependency Injection for Testing

### Protocol-Based

```swift
protocol APIClient {
    func fetchUser(id: String) async throws -> User
}

class RealAPIClient: APIClient {
    func fetchUser(id: String) async throws -> User {
        // Real implementation
    }
}

class MockAPIClient: APIClient {
    var fetchUserResult: Result<User, Error> = .success(User.mock)
    var fetchUserCallCount = 0
    var lastFetchedID: String?
    
    func fetchUser(id: String) async throws -> User {
        fetchUserCallCount += 1
        lastFetchedID = id
        return try fetchUserResult.get()
    }
}

// In tests
func testFetchUser() async throws {
    let mock = MockAPIClient()
    mock.fetchUserResult = .success(User(id: "123", name: "Test"))
    
    let sut = UserService(api: mock)
    let user = try await sut.getUser(id: "123")
    
    XCTAssertEqual(user.name, "Test")
    XCTAssertEqual(mock.fetchUserCallCount, 1)
    XCTAssertEqual(mock.lastFetchedID, "123")
}
```

### Environment-Based (@Observable)

```swift
@Observable
class AppDependencies {
    var api: APIClient
    var storage: StorageClient
    var analytics: AnalyticsClient
    
    init(
        api: APIClient = RealAPIClient(),
        storage: StorageClient = RealStorageClient(),
        analytics: AnalyticsClient = RealAnalyticsClient()
    ) {
        self.api = api
        self.storage = storage
        self.analytics = analytics
    }
    
    static let mock = AppDependencies(
        api: MockAPIClient(),
        storage: MockStorageClient(),
        analytics: MockAnalyticsClient()
    )
}
```

## Testing @Observable

```swift
@Observable
class CounterViewModel {
    var count = 0
    
    func increment() {
        count += 1
    }
}

@Test func counterIncrement() {
    let sut = CounterViewModel()
    sut.increment()
    #expect(sut.count == 1)
}
```

## Testing Actors

```swift
actor Cache {
    private var storage: [String: Data] = [:]
    
    func store(_ data: Data, for key: String) {
        storage[key] = data
    }
    
    func get(_ key: String) -> Data? {
        storage[key]
    }
}

@Test func cacheStorage() async {
    let cache = Cache()
    let data = Data("test".utf8)
    
    await cache.store(data, for: "key")
    let retrieved = await cache.get("key")
    
    #expect(retrieved == data)
}
```

## Snapshot Testing

```swift
import SnapshotTesting

func testProfileView() {
    let view = ProfileView(user: .mock)
    
    assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
}

func testProfileViewDarkMode() {
    let view = ProfileView(user: .mock)
        .environment(\.colorScheme, .dark)
    
    assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13)))
}
```

## Test Utilities

### Test Fixtures

```swift
extension User {
    static let mock = User(
        id: "test-id",
        name: "Test User",
        email: "test@example.com"
    )
    
    static func mock(
        id: String = "test-id",
        name: String = "Test User",
        email: String = "test@example.com"
    ) -> User {
        User(id: id, name: name, email: email)
    }
}
```

### Async Test Helpers

```swift
func waitUntil(
    timeout: TimeInterval = 1.0,
    condition: @escaping () -> Bool
) async throws {
    let start = Date()
    while !condition() {
        if Date().timeIntervalSince(start) > timeout {
            throw TestError.timeout
        }
        try await Task.sleep(nanoseconds: 10_000_000) // 10ms
    }
}

// Usage
@Test func eventuallyUpdates() async throws {
    let sut = ViewModel()
    sut.load()
    
    try await waitUntil { sut.isLoaded }
    #expect(sut.items.count > 0)
}
```

## Running Tests

```bash
# Run all tests
swift test
xcodebuild test -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Run specific test
swift test --filter UserTests
xcodebuild test -scheme MyApp -only-testing:MyAppTests/UserTests

# Run with coverage
xcodebuild test -scheme MyApp -enableCodeCoverage YES

# Parallel testing
xcodebuild test -scheme MyApp -parallel-testing-enabled YES
```
