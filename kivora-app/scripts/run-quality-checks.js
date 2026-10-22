import { execSync } from 'node:child_process';
import process from 'node:process';

console.log('=== KIVORA MONOREPO QUALITY CHECKS ===');

let exitCode = 0;

function runStep(label, cmd) {
  console.log(`\n--- Running ${label} ---`);
  try {
    execSync(cmd, { stdio: 'inherit' });
    console.log(`[PASS] ${label}`);
  } catch (err) {
    console.error(`[FAIL] ${label}`);
    exitCode = 1;
  }
}

runStep('Workspace Validation', 'node scripts/validate-workspace.js');
runStep('Environment Validation', 'node scripts/check-environment.js');

process.exit(exitCode);
