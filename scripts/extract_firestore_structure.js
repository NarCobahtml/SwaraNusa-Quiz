#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

const DEFAULT_OUTPUT = path.join('data', 'firestore-structure.generated.json');
const DEFAULT_SAMPLE_SIZE = 25;
const DEFAULT_MAX_DEPTH = 5;

function printHelp() {
  console.log(`
Extract Firestore database structure into a JSON schema summary.

Usage:
  npm run extract:firestore-structure -- [options]
  node scripts/extract_firestore_structure.js [options]

Options:
  --out <file>             Output JSON path. Default: ${DEFAULT_OUTPUT}
  --sample-size <number>   Documents sampled per collection. Default: ${DEFAULT_SAMPLE_SIZE}
  --max-depth <number>     Max subcollection depth. Default: ${DEFAULT_MAX_DEPTH}
  --include-samples        Include redacted sample values for each field.
  --project-id <id>        Override Firebase project ID.
  --help                   Show this help text.

Authentication priority:
  1. FIREBASE_SERVICE_ACCOUNT as JSON string
  2. FIREBASE_SERVICE_ACCOUNT as path to a service account JSON file
  3. GOOGLE_APPLICATION_CREDENTIALS path
  4. ./serviceAccountKey.json
  5. Application Default Credentials
`);
}

function parseArgs(argv) {
  const options = {
    out: DEFAULT_OUTPUT,
    sampleSize: DEFAULT_SAMPLE_SIZE,
    maxDepth: DEFAULT_MAX_DEPTH,
    includeSamples: false,
    projectId: process.env.FIREBASE_PROJECT_ID || null,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    const next = argv[index + 1];

    if (arg === '--help' || arg === '-h') {
      options.help = true;
    } else if (arg === '--include-samples') {
      options.includeSamples = true;
    } else if (arg === '--out') {
      assertValue(arg, next);
      options.out = next;
      index += 1;
    } else if (arg === '--sample-size') {
      assertValue(arg, next);
      options.sampleSize = parsePositiveInt(arg, next);
      index += 1;
    } else if (arg === '--max-depth') {
      assertValue(arg, next);
      options.maxDepth = parsePositiveInt(arg, next);
      index += 1;
    } else if (arg === '--project-id') {
      assertValue(arg, next);
      options.projectId = next;
      index += 1;
    } else {
      throw new Error(`Unknown option: ${arg}`);
    }
  }

  return options;
}

function assertValue(arg, value) {
  if (!value || value.startsWith('--')) {
    throw new Error(`${arg} needs a value.`);
  }
}

function parsePositiveInt(arg, value) {
  const parsed = Number.parseInt(value, 10);
  if (!Number.isInteger(parsed) || parsed < 1) {
    throw new Error(`${arg} must be a positive integer.`);
  }
  return parsed;
}

function initializeFirebase(projectId) {
  if (admin.apps.length > 0) {
    return;
  }

  const credential = loadCredential();
  const appOptions = {};

  if (credential) {
    appOptions.credential = credential;
  } else {
    appOptions.credential = admin.credential.applicationDefault();
  }

  if (projectId) {
    appOptions.projectId = projectId;
  } else {
    const inferredProjectId = inferProjectId();
    if (inferredProjectId) {
      appOptions.projectId = inferredProjectId;
    }
  }

  admin.initializeApp(appOptions);
}

function loadCredential() {
  const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT;

  if (serviceAccount) {
    const trimmed = serviceAccount.trim();
    const parsed = trimmed.startsWith('{')
      ? JSON.parse(trimmed)
      : JSON.parse(fs.readFileSync(path.resolve(trimmed), 'utf8'));
    return admin.credential.cert(parsed);
  }

  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    const filePath = path.resolve(process.env.GOOGLE_APPLICATION_CREDENTIALS);
    return admin.credential.cert(JSON.parse(fs.readFileSync(filePath, 'utf8')));
  }

  const localServiceAccount = path.resolve('serviceAccountKey.json');
  if (fs.existsSync(localServiceAccount)) {
    return admin.credential.cert(JSON.parse(fs.readFileSync(localServiceAccount, 'utf8')));
  }

  return null;
}

function inferProjectId() {
  const googleServicesPath = path.resolve('android', 'app', 'google-services.json');
  if (!fs.existsSync(googleServicesPath)) {
    return null;
  }

  try {
    const googleServices = JSON.parse(fs.readFileSync(googleServicesPath, 'utf8'));
    return googleServices.project_info && googleServices.project_info.project_id
      ? googleServices.project_info.project_id
      : null;
  } catch (error) {
    return null;
  }
}

function emptyCollectionSummary(collectionRef, depth) {
  return {
    id: collectionRef.id,
    path: collectionRef.path,
    pathPattern: toCollectionPathPattern(collectionRef.path),
    depth,
    documentsScanned: 0,
    fields: {},
    subcollections: {},
  };
}

function toCollectionPathPattern(collectionPath) {
  const segments = collectionPath.split('/');

  return segments
    .map((segment, index) => {
      if (index % 2 === 0) {
        return segment;
      }

      const collectionId = segments[index - 1] || 'document';
      return `{${collectionId}Id}`;
    })
    .join('/');
}

async function extractDatabaseStructure(db, options) {
  const rootCollections = await db.listCollections();
  const collections = {};

  for (const collectionRef of rootCollections.sort((left, right) => left.id.localeCompare(right.id))) {
    collections[collectionRef.id] = await extractCollection(collectionRef, options, 0);
  }

  return {
    projectId: db.projectId,
    generatedAt: new Date().toISOString(),
    sampleSizePerCollection: options.sampleSize,
    maxDepth: options.maxDepth,
    includesSamples: options.includeSamples,
    collections,
  };
}

async function extractCollection(collectionRef, options, depth) {
  const summary = emptyCollectionSummary(collectionRef, depth);
  const snapshot = await collectionRef.limit(options.sampleSize).get();

  summary.documentsScanned = snapshot.size;

  for (const documentSnapshot of snapshot.docs) {
    mergeDocumentFields(summary.fields, documentSnapshot.data(), options);

    if (depth + 1 <= options.maxDepth) {
      const subcollections = await documentSnapshot.ref.listCollections();

      for (const subcollectionRef of subcollections.sort((left, right) => left.id.localeCompare(right.id))) {
        const subcollectionSummary = await extractCollection(subcollectionRef, options, depth + 1);

        if (summary.subcollections[subcollectionRef.id]) {
          summary.subcollections[subcollectionRef.id] = mergeCollectionSummaries(
            summary.subcollections[subcollectionRef.id],
            subcollectionSummary
          );
        } else {
          summary.subcollections[subcollectionRef.id] = subcollectionSummary;
        }
      }
    }
  }

  return summary;
}

function mergeCollectionSummaries(left, right) {
  const merged = {
    ...left,
    documentsScanned: left.documentsScanned + right.documentsScanned,
    fields: mergeNestedFields(left.fields || {}, right.fields || {}),
    subcollections: { ...(left.subcollections || {}) },
  };

  for (const [id, subcollection] of Object.entries(right.subcollections || {})) {
    merged.subcollections[id] = merged.subcollections[id]
      ? mergeCollectionSummaries(merged.subcollections[id], subcollection)
      : subcollection;
  }

  return merged;
}

function mergeDocumentFields(fields, data, options) {
  for (const [fieldName, value] of Object.entries(data)) {
    const fieldInfo = fields[fieldName] || {
      types: {},
      occurrences: 0,
    };
    const analyzed = analyzeValue(value);

    fieldInfo.occurrences += 1;
    fieldInfo.types[analyzed.type] = (fieldInfo.types[analyzed.type] || 0) + 1;

    if (analyzed.fields) {
      fieldInfo.fields = mergeNestedFields(fieldInfo.fields || {}, analyzed.fields);
    }

    if (analyzed.elementTypes) {
      fieldInfo.elementTypes = mergeCounts(fieldInfo.elementTypes || {}, analyzed.elementTypes);
    }

    if (options.includeSamples) {
      fieldInfo.samples = addSample(fieldInfo.samples || [], redactSample(value));
    }

    fields[fieldName] = fieldInfo;
  }
}

function mergeNestedFields(target, source) {
  const merged = { ...target };

  for (const [key, sourceInfo] of Object.entries(source)) {
    const targetInfo = merged[key] || {
      types: {},
      occurrences: 0,
    };

    merged[key] = {
      ...targetInfo,
      occurrences: targetInfo.occurrences + sourceInfo.occurrences,
      types: mergeCounts(targetInfo.types || {}, sourceInfo.types || {}),
    };

    if (sourceInfo.fields) {
      merged[key].fields = mergeNestedFields(targetInfo.fields || {}, sourceInfo.fields);
    }

    if (sourceInfo.elementTypes) {
      merged[key].elementTypes = mergeCounts(targetInfo.elementTypes || {}, sourceInfo.elementTypes);
    }

    if (sourceInfo.samples) {
      merged[key].samples = [...(targetInfo.samples || [])];
      for (const sample of sourceInfo.samples) {
        merged[key].samples = addSample(merged[key].samples, sample);
      }
    }
  }

  return merged;
}

function mergeCounts(left, right) {
  const merged = { ...left };
  for (const [key, value] of Object.entries(right)) {
    merged[key] = (merged[key] || 0) + value;
  }
  return merged;
}

function analyzeValue(value) {
  if (value === null) {
    return { type: 'null' };
  }

  if (value instanceof admin.firestore.Timestamp) {
    return { type: 'timestamp' };
  }

  if (value instanceof admin.firestore.GeoPoint) {
    return { type: 'geopoint' };
  }

  if (value instanceof admin.firestore.DocumentReference) {
    return { type: 'reference' };
  }

  if (Buffer.isBuffer(value) || value instanceof Uint8Array) {
    return { type: 'bytes' };
  }

  if (Array.isArray(value)) {
    const elementTypes = {};
    for (const item of value) {
      const analyzed = analyzeValue(item);
      elementTypes[analyzed.type] = (elementTypes[analyzed.type] || 0) + 1;
    }
    return { type: 'array', elementTypes };
  }

  if (typeof value === 'object') {
    const fields = {};
    mergeDocumentFields(fields, value, { includeSamples: false });
    return { type: 'map', fields };
  }

  if (typeof value === 'number') {
    return { type: Number.isInteger(value) ? 'integer' : 'double' };
  }

  return { type: typeof value };
}

function redactSample(value) {
  if (value === null) {
    return null;
  }

  if (value instanceof admin.firestore.Timestamp) {
    return value.toDate().toISOString();
  }

  if (value instanceof admin.firestore.GeoPoint) {
    return { latitude: value.latitude, longitude: value.longitude };
  }

  if (value instanceof admin.firestore.DocumentReference) {
    return value.path;
  }

  if (Buffer.isBuffer(value) || value instanceof Uint8Array) {
    return `[bytes:${value.length}]`;
  }

  if (Array.isArray(value)) {
    return value.slice(0, 3).map(redactSample);
  }

  if (typeof value === 'object') {
    const output = {};
    for (const [key, nestedValue] of Object.entries(value).slice(0, 10)) {
      output[key] = redactSample(nestedValue);
    }
    return output;
  }

  if (typeof value === 'string') {
    return value.length > 80 ? `${value.slice(0, 77)}...` : value;
  }

  return value;
}

function addSample(samples, sample) {
  const encoded = JSON.stringify(sample);
  const isDuplicate = samples.some((existing) => JSON.stringify(existing) === encoded);

  if (!isDuplicate && samples.length < 3) {
    samples.push(sample);
  }

  return samples;
}

async function main() {
  const options = parseArgs(process.argv.slice(2));

  if (options.help) {
    printHelp();
    return;
  }

  initializeFirebase(options.projectId);

  const db = admin.firestore();
  const structure = await extractDatabaseStructure(db, options);
  const outputPath = path.resolve(options.out);

  fs.mkdirSync(path.dirname(outputPath), { recursive: true });
  fs.writeFileSync(outputPath, `${JSON.stringify(structure, null, 2)}\n`);

  console.log(`Firestore structure extracted to ${outputPath}`);
  console.log(`Root collections: ${Object.keys(structure.collections).length}`);
}

main().catch((error) => {
  console.error(error.stack || error.message);
  process.exitCode = 1;
});
