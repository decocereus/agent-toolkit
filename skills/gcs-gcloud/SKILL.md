---
name: gcs-gcloud
description: Expert at Google Cloud Storage (GCS) and gcloud CLI. Use when working with GCS buckets, uploading/downloading files, generating signed URLs, managing IAM permissions, configuring CORS, streaming uploads, Cloud Run deployments, Cloud Build, or any gcloud CLI operations. Covers both CLI usage and Node.js/TypeScript SDK patterns.
---

# GCS & gcloud CLI Expert

Comprehensive knowledge for Google Cloud Storage and gcloud CLI operations.

## gcloud CLI Essentials

### Authentication

```bash
# Login interactively
gcloud auth login

# Service account authentication
gcloud auth activate-service-account --key-file=key.json

# Application default credentials
gcloud auth application-default login

# Check current auth
gcloud auth list
gcloud config get-value account
```

### Project Configuration

```bash
# Set project
gcloud config set project PROJECT_ID

# List projects
gcloud projects list

# Get current config
gcloud config list

# Create named configuration
gcloud config configurations create my-config
gcloud config configurations activate my-config
```

## Google Cloud Storage (GCS)

### Bucket Operations

```bash
# Create bucket
gsutil mb -l us-central1 gs://my-bucket/

# List buckets
gsutil ls

# Delete bucket (must be empty)
gsutil rb gs://my-bucket/

# Bucket info
gsutil ls -L -b gs://my-bucket/
```

### File Operations

```bash
# Upload
gsutil cp local-file.txt gs://bucket/path/
gsutil -m cp -r local-dir/ gs://bucket/path/  # Parallel, recursive

# Download
gsutil cp gs://bucket/path/file.txt ./
gsutil -m cp -r gs://bucket/path/ ./local/  # Parallel, recursive

# List files
gsutil ls gs://bucket/
gsutil ls -l gs://bucket/path/  # Long format with sizes

# Delete
gsutil rm gs://bucket/path/file.txt
gsutil -m rm -r gs://bucket/path/  # Recursive delete

# Move/Rename
gsutil mv gs://bucket/old.txt gs://bucket/new.txt
```

### Streaming Upload/Download

```bash
# Stream to GCS
cat file.txt | gsutil cp - gs://bucket/file.txt

# Stream from GCS
gsutil cp gs://bucket/file.txt - | process_data
```

### Signed URLs

```bash
# Generate signed URL (requires service account)
gsutil signurl -d 1h key.json gs://bucket/file.txt

# Using gcloud (no key file needed)
gcloud storage sign-url gs://bucket/file.txt --duration=1h
```

### CORS Configuration

```bash
# Set CORS
gsutil cors set cors.json gs://bucket/

# Get CORS
gsutil cors get gs://bucket/
```

cors.json example:
```json
[
  {
    "origin": ["https://example.com"],
    "method": ["GET", "PUT", "POST", "DELETE"],
    "responseHeader": ["Content-Type", "x-goog-resumable"],
    "maxAgeSeconds": 3600
  }
]
```

### IAM & Permissions

```bash
# Get IAM policy
gsutil iam get gs://bucket/

# Add member
gsutil iam ch user:email@example.com:objectViewer gs://bucket/

# Make public
gsutil iam ch allUsers:objectViewer gs://bucket/

# Remove public access
gsutil iam ch -d allUsers:objectViewer gs://bucket/
```

## Node.js/TypeScript SDK

### Setup

```typescript
import { Storage } from '@google-cloud/storage';

const storage = new Storage({
  projectId: 'my-project',
  // keyFilename: './key.json', // Optional if using ADC
});

const bucket = storage.bucket('my-bucket');
```

### Upload Patterns

```typescript
// Simple upload from file
await bucket.upload('./local-file.txt', {
  destination: 'path/in/bucket/file.txt',
  metadata: {
    contentType: 'text/plain',
  },
});

// Upload from buffer
const file = bucket.file('path/file.txt');
await file.save(buffer, {
  contentType: 'application/octet-stream',
});

// Stream upload (RECOMMENDED for large files)
import { pipeline } from 'stream/promises';

const writeStream = bucket.file('video.mp4').createWriteStream({
  resumable: false,  // IMPORTANT: false prevents memory buffering
  contentType: 'video/mp4',
  metadata: {
    cacheControl: 'public, max-age=31536000',
  },
});

await pipeline(sourceStream, writeStream);
```

### Download Patterns

```typescript
// Download to file
await bucket.file('remote.txt').download({ destination: './local.txt' });

// Download to buffer
const [contents] = await bucket.file('file.txt').download();

// Stream download (RECOMMENDED for large files)
const readStream = bucket.file('video.mp4').createReadStream();
await pipeline(readStream, fs.createWriteStream('./video.mp4'));
```

### Signed URLs

```typescript
// Generate signed URL for download
const [url] = await bucket.file('file.txt').getSignedUrl({
  action: 'read',
  expires: Date.now() + 60 * 60 * 1000, // 1 hour
});

// Generate signed URL for upload
const [uploadUrl] = await bucket.file('upload-target.txt').getSignedUrl({
  action: 'write',
  expires: Date.now() + 15 * 60 * 1000, // 15 min
  contentType: 'application/octet-stream',
});

// Resumable upload signed URL
const [resumableUrl] = await bucket.file('large-file.mp4').getSignedUrl({
  action: 'resumable',
  expires: Date.now() + 60 * 60 * 1000,
  contentType: 'video/mp4',
});
```

### File Operations

```typescript
// Check if exists
const [exists] = await bucket.file('file.txt').exists();

// Get metadata
const [metadata] = await bucket.file('file.txt').getMetadata();

// Set metadata
await bucket.file('file.txt').setMetadata({
  contentType: 'text/plain',
  cacheControl: 'public, max-age=3600',
  metadata: {
    customKey: 'customValue',
  },
});

// Copy
await bucket.file('source.txt').copy(bucket.file('dest.txt'));

// Move (copy + delete)
await bucket.file('old.txt').move('new.txt');

// Delete
await bucket.file('file.txt').delete();

// List files
const [files] = await bucket.getFiles({ prefix: 'path/' });
for (const file of files) {
  console.log(file.name);
}
```

### Resumable vs Non-Resumable Uploads

```typescript
// NON-RESUMABLE: Better for small files, less memory
const stream = bucket.file('small.txt').createWriteStream({
  resumable: false,  // No chunking, direct upload
});

// RESUMABLE: Better for large files, can retry
const stream = bucket.file('large.mp4').createWriteStream({
  resumable: true,   // Chunks upload, retryable
  chunkSize: 5 * 1024 * 1024, // 5MB chunks
});
```

**IMPORTANT**: `resumable: true` buffers data in memory. For memory-constrained environments (Cloud Run), use `resumable: false` for better memory efficiency.

## Cloud Run

### Deployment

```bash
# Deploy from source
gcloud run deploy SERVICE_NAME \
  --source . \
  --region us-central1 \
  --allow-unauthenticated

# Deploy from container
gcloud run deploy SERVICE_NAME \
  --image gcr.io/PROJECT/IMAGE:TAG \
  --region us-central1 \
  --memory 8Gi \
  --cpu 4 \
  --timeout 900 \
  --concurrency 8 \
  --no-cpu-throttling \
  --cpu-boost
```

### Configuration

```bash
# Set environment variables
gcloud run services update SERVICE \
  --set-env-vars "KEY=value,KEY2=value2" \
  --region us-central1

# Set secrets
gcloud run services update SERVICE \
  --set-secrets "API_KEY=secret-name:latest" \
  --region us-central1

# Scale settings
gcloud run services update SERVICE \
  --min-instances 1 \
  --max-instances 100 \
  --region us-central1
```

### Logs

```bash
# View logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=SERVICE" \
  --limit 100 \
  --format "table(timestamp,severity,textPayload)"

# Stream logs
gcloud beta run services logs tail SERVICE --region us-central1

# Filter by severity
gcloud logging read "resource.type=cloud_run_revision AND severity>=ERROR" --limit 50
```

## Cloud Build

### cloudbuild.yaml

```yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/myapp:$COMMIT_SHA', '.']

  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/myapp:$COMMIT_SHA']

  - name: 'gcr.io/cloud-builders/gcloud'
    args:
      - 'run'
      - 'deploy'
      - 'myapp'
      - '--image=gcr.io/$PROJECT_ID/myapp:$COMMIT_SHA'
      - '--region=us-central1'
      - '--platform=managed'

options:
  machineType: 'E2_HIGHCPU_8'

timeout: '1200s'
```

### Trigger Build

```bash
# Submit build
gcloud builds submit --config cloudbuild.yaml .

# From Git
gcloud builds submit --tag gcr.io/PROJECT/IMAGE .
```

## Service Account Best Practices

```bash
# Create service account
gcloud iam service-accounts create sa-name \
  --display-name="Service Account"

# Grant bucket access
gsutil iam ch serviceAccount:sa@project.iam.gserviceaccount.com:objectAdmin gs://bucket/

# Create key (for local dev only)
gcloud iam service-accounts keys create key.json \
  --iam-account=sa@project.iam.gserviceaccount.com
```

### Workload Identity (recommended for GKE/Cloud Run)

```bash
# No key files needed - uses attached service account
gcloud run deploy SERVICE \
  --service-account=sa@project.iam.gserviceaccount.com
```

## Common Patterns

### Upload with Retry

```typescript
async function uploadWithRetry(
  bucket: Bucket,
  path: string,
  data: Buffer,
  maxRetries = 3,
): Promise<void> {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      await bucket.file(path).save(data);
      return;
    } catch (err) {
      if (attempt === maxRetries) throw err;
      await new Promise((r) => setTimeout(r, 1000 * attempt));
    }
  }
}
```

### Parallel Uploads

```typescript
async function uploadFiles(files: { path: string; data: Buffer }[]): Promise<void> {
  const BATCH_SIZE = 10;
  for (let i = 0; i < files.length; i += BATCH_SIZE) {
    const batch = files.slice(i, i + BATCH_SIZE);
    await Promise.all(
      batch.map(({ path, data }) => bucket.file(path).save(data))
    );
  }
}
```

### Signed URL Cache

```typescript
class SignedUrlCache {
  private cache = new Map<string, { url: string; expires: number }>();
  private readonly BUFFER = 5 * 60 * 1000; // 5 min before expiry

  async getSignedUrl(file: File, expiresIn: number): Promise<string> {
    const key = file.name;
    const cached = this.cache.get(key);

    if (cached && cached.expires > Date.now() + this.BUFFER) {
      return cached.url;
    }

    const expires = Date.now() + expiresIn;
    const [url] = await file.getSignedUrl({
      action: 'read',
      expires,
    });

    this.cache.set(key, { url, expires });
    return url;
  }
}
```
