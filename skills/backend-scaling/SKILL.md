---
name: backend-scaling
description: Expert backend engineering for building and scaling services to 100k+ users. Use when designing APIs, implementing job queues, handling concurrency, managing database connections, implementing caching, optimizing memory usage, debugging production issues, or architecting scalable systems. Covers Node.js/TypeScript patterns, Cloud Run/serverless scaling, Redis, PostgreSQL, stream processing, and production reliability.
---

# Backend Scaling Expert

Comprehensive patterns for building and scaling backend services to 100k+ users.

## Architecture Principles

### 1. Stateless Services
- Store state in external systems (Redis, PostgreSQL, GCS)
- Enable horizontal scaling
- Use sticky sessions only when absolutely necessary

### 2. Async Everything
- Fire-and-forget for non-critical paths
- Use job queues for long-running tasks
- Implement proper timeout handling

### 3. Fail Fast, Recover Gracefully
- Circuit breakers for external dependencies
- Graceful degradation
- Health checks and readiness probes

## Memory Management

### Node.js Memory Patterns

```typescript
// BAD: Unbounded buffer accumulation
const chunks: Buffer[] = [];
stream.on('data', (chunk) => chunks.push(chunk));

// GOOD: Bounded buffer with backpressure
class BoundedBuffer {
  private chunks: Buffer[] = [];
  private totalSize = 0;
  private readonly maxSize: number;

  constructor(maxSizeBytes: number) {
    this.maxSize = maxSizeBytes;
  }

  push(chunk: Buffer): void {
    if (this.totalSize + chunk.length > this.maxSize) {
      throw new Error(`Buffer exceeded ${this.maxSize} bytes`);
    }
    this.chunks.push(chunk);
    this.totalSize += chunk.length;
  }
}
```

### Stream Backpressure

```typescript
// CRITICAL: Always set highWaterMark on PassThrough
const passThrough = new PassThrough({
  highWaterMark: 2 * 1024 * 1024, // 2MB max buffer
});

// Handle backpressure properly
source.pipe(destination);
destination.on('drain', () => source.resume());
```

### Preventing Memory Leaks

1. **Event Listeners**: Always remove listeners
```typescript
const handler = (data) => process(data);
emitter.on('event', handler);
// Later:
emitter.off('event', handler);
```

2. **Maps/Sets**: Implement cleanup
```typescript
class JobTracker {
  private jobs = new Map<string, Job>();
  private readonly MAX_JOBS = 1000;
  private readonly TTL_MS = 24 * 60 * 60 * 1000;

  cleanup(): void {
    const now = Date.now();
    for (const [id, job] of this.jobs) {
      if (job.status === 'completed' && now - job.updatedAt > this.TTL_MS) {
        this.jobs.delete(id);
      }
    }
  }
}
```

3. **Timers**: Always clear intervals
```typescript
const interval = setInterval(() => monitor(), 60000);
// On shutdown:
clearInterval(interval);
```

## Concurrency Patterns

### Rate Limiting

```typescript
class RateLimiter {
  private tokens: number;
  private lastRefill: number;

  constructor(
    private readonly maxTokens: number,
    private readonly refillRate: number, // tokens per second
  ) {
    this.tokens = maxTokens;
    this.lastRefill = Date.now();
  }

  async acquire(): Promise<boolean> {
    this.refill();
    if (this.tokens > 0) {
      this.tokens--;
      return true;
    }
    return false;
  }

  private refill(): void {
    const now = Date.now();
    const elapsed = (now - this.lastRefill) / 1000;
    this.tokens = Math.min(this.maxTokens, this.tokens + elapsed * this.refillRate);
    this.lastRefill = now;
  }
}
```

### Semaphore for Bounded Concurrency

```typescript
class Semaphore {
  private permits: number;
  private waiting: (() => void)[] = [];

  constructor(permits: number) {
    this.permits = permits;
  }

  async acquire(): Promise<void> {
    if (this.permits > 0) {
      this.permits--;
      return;
    }
    await new Promise<void>((resolve) => this.waiting.push(resolve));
  }

  release(): void {
    const next = this.waiting.shift();
    if (next) {
      next();
    } else {
      this.permits++;
    }
  }
}

// Usage
const sem = new Semaphore(10); // Max 10 concurrent
await sem.acquire();
try {
  await doWork();
} finally {
  sem.release();
}
```

### Batch Processing

```typescript
async function processBatch<T, R>(
  items: T[],
  batchSize: number,
  processor: (item: T) => Promise<R>,
): Promise<R[]> {
  const results: R[] = [];
  for (let i = 0; i < items.length; i += batchSize) {
    const batch = items.slice(i, i + batchSize);
    const batchResults = await Promise.all(batch.map(processor));
    results.push(...batchResults);
  }
  return results;
}
```

## Database Patterns

### Connection Pooling

```typescript
// PostgreSQL with pg
const pool = new Pool({
  max: 20, // Max connections
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Always release connections
const client = await pool.connect();
try {
  await client.query('SELECT ...');
} finally {
  client.release();
}
```

### Redis Best Practices

```typescript
// Bounded operations - NEVER use unbounded SMEMBERS/KEYS
const MAX_ITEMS = 100;
const members = await redis.srandmember('large_set', MAX_ITEMS);

// Use SCAN instead of KEYS
async function* scanKeys(pattern: string) {
  let cursor = '0';
  do {
    const [nextCursor, keys] = await redis.scan(cursor, 'MATCH', pattern, 'COUNT', 100);
    cursor = nextCursor;
    yield* keys;
  } while (cursor !== '0');
}

// Set TTLs on everything
await redis.setex('key', 3600, 'value'); // 1 hour TTL
```

## Caching Strategies

### Multi-Level Cache

```typescript
class MultiLevelCache<T> {
  constructor(
    private readonly memory: Map<string, { value: T; expires: number }>,
    private readonly redis: Redis,
    private readonly memoryTTL: number,
    private readonly redisTTL: number,
  ) {}

  async get(key: string): Promise<T | null> {
    // L1: Memory
    const cached = this.memory.get(key);
    if (cached && cached.expires > Date.now()) {
      return cached.value;
    }

    // L2: Redis
    const redisValue = await this.redis.get(key);
    if (redisValue) {
      const value = JSON.parse(redisValue) as T;
      this.memory.set(key, { value, expires: Date.now() + this.memoryTTL });
      return value;
    }

    return null;
  }

  async set(key: string, value: T): Promise<void> {
    this.memory.set(key, { value, expires: Date.now() + this.memoryTTL });
    await this.redis.setex(key, this.redisTTL, JSON.stringify(value));
  }
}
```

### Cache Invalidation Patterns

1. **TTL-based**: Simple, eventual consistency
2. **Write-through**: Update cache on write
3. **Cache-aside**: Application manages cache
4. **Pub/sub invalidation**: For distributed systems

## Job Queue Patterns

### Reliable Job Processing

```typescript
interface Job {
  id: string;
  status: 'pending' | 'running' | 'success' | 'error';
  heartbeat: number;
  attempts: number;
  maxAttempts: number;
}

class JobProcessor {
  private readonly HEARTBEAT_INTERVAL = 30000; // 30s
  private readonly STALE_THRESHOLD = 300000; // 5 min

  async processJob(job: Job): Promise<void> {
    const heartbeatInterval = setInterval(async () => {
      await this.updateHeartbeat(job.id);
    }, this.HEARTBEAT_INTERVAL);

    try {
      await this.doWork(job);
      await this.markSuccess(job.id);
    } catch (err) {
      if (job.attempts < job.maxAttempts) {
        await this.retry(job.id);
      } else {
        await this.markError(job.id, err);
      }
    } finally {
      clearInterval(heartbeatInterval);
    }
  }

  async recoverStaleJobs(): Promise<void> {
    const staleJobs = await this.findStaleJobs(this.STALE_THRESHOLD);
    for (const job of staleJobs) {
      if (job.attempts < job.maxAttempts) {
        await this.retry(job.id);
      } else {
        await this.markError(job.id, 'Job stalled');
      }
    }
  }
}
```

## Cloud Run / Serverless

### Configuration for Long-Running Tasks

```yaml
# Cloud Run service.yaml
spec:
  template:
    metadata:
      annotations:
        run.googleapis.com/cpu-throttling: "false"  # Keep CPU during background work
        run.googleapis.com/startup-cpu-boost: "true"
    spec:
      containerConcurrency: 8  # Requests per instance
      timeoutSeconds: 900      # 15 min max
      containers:
        - resources:
            limits:
              memory: 8Gi
              cpu: "4"
```

### Memory-Backed /tmp (tmpfs)

**CRITICAL**: On Cloud Run, `/tmp` is memory-backed. Writing large files consumes RAM.

```typescript
// BAD: Writing large files to /tmp
await writeFile('/tmp/large-video.mp4', videoBuffer); // Uses RAM!

// GOOD: Stream directly to cloud storage
const writeStream = storage.bucket('bucket').file('video.mp4').createWriteStream();
sourceStream.pipe(writeStream);
```

### Graceful Shutdown

```typescript
let isShuttingDown = false;

process.on('SIGTERM', async () => {
  isShuttingDown = true;

  // Stop accepting new work
  server.close();

  // Wait for in-flight requests
  await waitForInflightRequests();

  // Cleanup resources
  await pool.end();
  await redis.quit();

  process.exit(0);
});
```

## API Design

### Input Validation

```typescript
// Validate all user input
const VIDEO_ID_REGEX = /^[a-zA-Z0-9_-]{1,64}$/;

function isValidVideoId(videoId: string): boolean {
  return VIDEO_ID_REGEX.test(videoId);
}

// In route handler
if (!isValidVideoId(req.params.videoId)) {
  return res.status(400).json({ error: 'invalid_video_id' });
}
```

### Error Handling

```typescript
// Consistent error responses
interface ErrorResponse {
  error: string;      // Machine-readable code
  message?: string;   // Human-readable details
}

// Global error handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  logger.error({ err, path: req.path }, 'request error');

  if (err instanceof ValidationError) {
    return res.status(400).json({ error: 'validation_error', message: err.message });
  }

  if (err instanceof NotFoundError) {
    return res.status(404).json({ error: 'not_found' });
  }

  res.status(500).json({ error: 'internal_error' });
});
```

## Monitoring & Observability

### Structured Logging

```typescript
const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => ({ level: label }),
  },
});

// Always include context
logger.info({ jobId, videoId, duration }, 'job completed');
logger.error({ err, jobId }, 'job failed');
```

### Health Checks

```typescript
app.get('/health', async (req, res) => {
  const checks = {
    redis: await checkRedis(),
    postgres: await checkPostgres(),
    memory: process.memoryUsage().heapUsed < MAX_HEAP,
  };

  const healthy = Object.values(checks).every(Boolean);
  res.status(healthy ? 200 : 503).json(checks);
});
```

## Performance Checklist

- [ ] Connection pooling for all databases
- [ ] Bounded buffers for all streams
- [ ] TTLs on all cache entries
- [ ] Cleanup for all Maps/Sets
- [ ] Timeouts on all external calls
- [ ] Backpressure handling on all streams
- [ ] Health checks for all dependencies
- [ ] Graceful shutdown handling
- [ ] Rate limiting on public endpoints
- [ ] Input validation on all endpoints
