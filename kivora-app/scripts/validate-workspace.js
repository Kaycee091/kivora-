import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const rootDir = path.resolve(__dirname, '..');

console.log('=== KIVORA WORKSPACE VALIDATION ===');

const requiredDirs = [
  'web/admin',
  'app',
  'server',
  'docs',
  'scripts',
  'web/admin/src',
  'server/supabase/migrations',
  'server/supabase/functions',
  'app/lib',
  'app/test',
];

const requiredFiles = [
  'package.json',
  'pnpm-workspace.yaml',
  '.gitignore',
  '.editorconfig',
  '.env.example',
  'README.md',
  'docs/product-requirements.md',
  'docs/requirements-traceability.md',
  'docs/screen-inventory.md',
  'docs/navigation-map.md',
  'docs/design-system.md',
  'docs/architecture.md',
  'docs/database-schema.md',
  'docs/relationship-diagram.md',
  'docs/permissions-matrix.md',
  'docs/business-rules.md',
  'docs/api-functions.md',
  'docs/security-and-privacy.md',
  'docs/verification-limitations.md',
  'docs/testing-strategy.md',
  'docs/deployment-guide.md',
  'docs/environment-variables.md',
  'docs/open-decisions.md',
  'docs/implementation-roadmap.md',
];

let errors = 0;

console.log('Checking directories:');
for (const dir of requiredDirs) {
  const p = path.join(rootDir, dir);
  if (fs.existsSync(p) && fs.statSync(p).isDirectory()) {
    console.log(`  [PASS] Directory exists: ${dir}`);
  } else {
    console.error(`  [FAIL] Missing directory: ${dir}`);
    errors++;
  }
}

console.log('\nChecking files:');
for (const file of requiredFiles) {
  const p = path.join(rootDir, file);
  if (fs.existsSync(p) && fs.statSync(p).isFile()) {
    console.log(`  [PASS] File exists: ${file}`);
  } else {
    console.error(`  [FAIL] Missing file: ${file}`);
    errors++;
  }
}

if (errors > 0) {
  console.error(`\nValidation completed with ${errors} missing items.`);
  process.exit(1);
} else {
  console.log('\n[SUCCESS] All workspace directories and core documentation files are present and verified.');
  process.exit(0);
}
