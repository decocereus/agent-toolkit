#!/usr/bin/env bun

/**
 * Lists markdown documentation files with YAML frontmatter validation.
 * Enforces that docs have summary and optional read_when fields.
 */
import { readdir, readFile } from 'node:fs/promises';
import path from 'node:path';
import matter from 'gray-matter';

interface DocInfo {
  path: string;
  summary: string;
  readWhen?: string[];
  valid: boolean;
  error?: string;
}

async function findMarkdownFiles(dir: string): Promise<string[]> {
  const files: string[] = [];
  
  async function scan(currentDir: string) {
    const entries = await readdir(currentDir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(currentDir, entry.name);
      if (entry.isDirectory() && !entry.name.startsWith('.') && entry.name !== 'node_modules') {
        await scan(fullPath);
      } else if (entry.isFile() && entry.name.endsWith('.md')) {
        files.push(fullPath);
      }
    }
  }
  
  await scan(dir);
  return files.sort();
}

async function parseDoc(filePath: string): Promise<DocInfo> {
  const content = await readFile(filePath, 'utf-8');
  const relativePath = path.relative(process.cwd(), filePath);
  
  try {
    const { data } = matter(content);
    
    if (!data.summary || typeof data.summary !== 'string') {
      return {
        path: relativePath,
        summary: '',
        valid: false,
        error: 'Missing or invalid "summary" in frontmatter',
      };
    }
    
    const readWhen = Array.isArray(data.read_when) ? data.read_when : undefined;
    
    return {
      path: relativePath,
      summary: data.summary,
      readWhen,
      valid: true,
    };
  } catch (err) {
    return {
      path: relativePath,
      summary: '',
      valid: false,
      error: err instanceof Error ? err.message : 'Failed to parse frontmatter',
    };
  }
}

async function main() {
  const targetDir = process.argv[2] || 'docs';
  const showAll = process.argv.includes('--all');
  const jsonOutput = process.argv.includes('--json');
  
  const files = await findMarkdownFiles(targetDir);
  const docs = await Promise.all(files.map(parseDoc));
  
  if (jsonOutput) {
    console.log(JSON.stringify(docs, null, 2));
    return;
  }
  
  const valid = docs.filter(d => d.valid);
  const invalid = docs.filter(d => !d.valid);
  
  if (valid.length > 0) {
    console.log('Documentation files:\n');
    for (const doc of valid) {
      console.log(`  ${doc.path}`);
      console.log(`    Summary: ${doc.summary}`);
      if (doc.readWhen && doc.readWhen.length > 0) {
        console.log(`    Read when: ${doc.readWhen.join(', ')}`);
      }
      console.log('');
    }
  }
  
  if (invalid.length > 0 && (showAll || invalid.length === docs.length)) {
    console.log('\nFiles missing valid frontmatter:\n');
    for (const doc of invalid) {
      console.log(`  ${doc.path}: ${doc.error}`);
    }
  }
  
  console.log(`\nTotal: ${valid.length} valid, ${invalid.length} missing frontmatter`);
}

main().catch(console.error);
