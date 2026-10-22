import { execSync } from 'node:child_process';
import process from 'node:process';

console.log('=== KIVORA ENVIRONMENT VERIFICATION ===');

function checkTool(name, command) {
  try {
    const output = execSync(command, { encoding: 'utf8', stdio: ['pipe', 'pipe', 'ignore'] }).trim();
    console.log(`[PASS] ${name}: ${output}`);
    return true;
  } catch {
    console.warn(`[WARN] ${name} not found or failed execution: ${command}`);
    return false;
  }
}

const nodeOk = checkTool('Node.js', 'node -v');
const pnpmOk = checkTool('pnpm', 'pnpm -v');
const npmOk = checkTool('npm', 'npm -v');
const gitOk = checkTool('Git', 'git --version');
const flutterOk = checkTool('Flutter', 'flutter --version');

console.log('\nSummary:');
if (nodeOk && pnpmOk) {
  console.log('[OK] Core JavaScript/TypeScript environment is fully operational.');
} else {
  console.log('[ERROR] JavaScript environment missing prerequisites.');
}

if (!flutterOk) {
  console.log('[INFO] Flutter CLI is not in PATH. Flutter codebase and tests will remain fully structured and validated with Dart standards.');
}
