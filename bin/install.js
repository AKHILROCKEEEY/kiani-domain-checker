#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');
const readline = require('readline');

const PKG = require('../package.json');
const PKG_ROOT = path.resolve(__dirname, '..');

// ── Paths ──────────────────────────────────────────────────────────────────────
const GLOBAL_BASE = path.join(os.homedir(), '.claude');
const LOCAL_BASE = path.join(process.cwd(), '.claude');

// What to copy
const COPY_MAP = [
  { src: 'commands/domain', dest: 'commands/domain' },
  { src: 'domain-checker',  dest: 'domain-checker' },
];

const SCRIPTS = [
  'domain-checker/scripts/check-domains.sh',
  'domain-checker/scripts/dedup-check.sh',
];

// ── Helpers ────────────────────────────────────────────────────────────────────
function copyDirSync(src, dest) {
  fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      copyDirSync(srcPath, destPath);
    } else {
      fs.copyFileSync(srcPath, destPath);
    }
  }
}

function replacePlaceholdersInDir(dir, installBase) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      replacePlaceholdersInDir(fullPath, installBase);
    } else if (entry.name.endsWith('.md')) {
      let content = fs.readFileSync(fullPath, 'utf8');
      if (content.includes('__INSTALL_PATH__')) {
        content = content.replace(/__INSTALL_PATH__/g, installBase + '/');
        fs.writeFileSync(fullPath, content, 'utf8');
      }
    }
  }
}

function removeDirSync(dir) {
  if (!fs.existsSync(dir)) return false;
  fs.rmSync(dir, { recursive: true, force: true });
  return true;
}

function ask(question) {
  return new Promise((resolve) => {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
    rl.question(question, (answer) => {
      rl.close();
      resolve(answer.trim().toLowerCase());
    });
  });
}

// ── Install ────────────────────────────────────────────────────────────────────
function install(base) {
  const installBase = base;

  console.log(`\nInstalling @kianilab/domain-checker v${PKG.version}`);
  console.log(`Target: ${installBase}\n`);

  // Copy files
  for (const { src, dest } of COPY_MAP) {
    const srcPath = path.join(PKG_ROOT, src);
    const destPath = path.join(installBase, dest);
    console.log(`  Copying ${src} → ${dest}`);
    copyDirSync(srcPath, destPath);
  }

  // Replace __INSTALL_PATH__ in .md files
  console.log('  Replacing path placeholders...');
  replacePlaceholdersInDir(path.join(installBase, 'commands'), installBase);
  replacePlaceholdersInDir(path.join(installBase, 'domain-checker'), installBase);

  // Make scripts executable
  for (const script of SCRIPTS) {
    const scriptPath = path.join(installBase, script);
    if (fs.existsSync(scriptPath)) {
      fs.chmodSync(scriptPath, 0o755);
      console.log(`  chmod +x ${script}`);
    }
  }

  // Write VERSION file
  const versionPath = path.join(installBase, 'domain-checker', 'VERSION');
  fs.writeFileSync(versionPath, PKG.version + '\n', 'utf8');
  console.log(`  Written VERSION (${PKG.version})`);

  console.log(`
Done! Available commands:

  /domain:research  — Full brand naming + domain research workflow
  /domain:check     — Check domain availability directly
  /domain:review    — Brand review gate (evaluate names)
  /domain:help      — Show all commands and usage

Open Claude Code and type /domain:help to get started.
`);
}

// ── Uninstall ──────────────────────────────────────────────────────────────────
function uninstall() {
  console.log('\nUninstalling @kianilab/domain-checker...\n');
  let removed = false;

  for (const base of [GLOBAL_BASE, LOCAL_BASE]) {
    const commandsDir = path.join(base, 'commands', 'domain');
    const checkerDir = path.join(base, 'domain-checker');

    if (removeDirSync(commandsDir)) {
      console.log(`  Removed ${commandsDir}`);
      removed = true;
    }
    if (removeDirSync(checkerDir)) {
      console.log(`  Removed ${checkerDir}`);
      removed = true;
    }

    // Clean up empty commands/ dir
    const commandsParent = path.join(base, 'commands');
    if (fs.existsSync(commandsParent)) {
      const remaining = fs.readdirSync(commandsParent);
      if (remaining.length === 0) {
        fs.rmdirSync(commandsParent);
        console.log(`  Removed empty ${commandsParent}`);
      }
    }
  }

  if (!removed) {
    console.log('  Nothing to remove — not installed.');
  } else {
    console.log('\nUninstall complete.');
  }
}

// ── Help ───────────────────────────────────────────────────────────────────────
function showHelp() {
  console.log(`
@kianilab/domain-checker v${PKG.version}

Brand name research and domain availability checker for Claude Code.

Usage:
  npx @kianilab/domain-checker               Interactive install
  npx @kianilab/domain-checker --global       Install to ~/.claude/
  npx @kianilab/domain-checker --local        Install to ./.claude/
  npx @kianilab/domain-checker --uninstall    Remove from both locations
  npx @kianilab/domain-checker --help         Show this help

After install, open Claude Code and use:
  /domain:research  — Full brand naming workflow
  /domain:check     — Direct domain availability check
  /domain:review    — Brand review gate
  /domain:help      — Show all commands
`);
}

// ── Main ───────────────────────────────────────────────────────────────────────
async function main() {
  const args = process.argv.slice(2);

  if (args.includes('--help') || args.includes('-h')) {
    showHelp();
    return;
  }

  if (args.includes('--uninstall')) {
    uninstall();
    return;
  }

  if (args.includes('--global')) {
    install(GLOBAL_BASE);
    return;
  }

  if (args.includes('--local')) {
    install(LOCAL_BASE);
    return;
  }

  // Interactive mode
  if (process.stdin.isTTY) {
    console.log(`\n@kianilab/domain-checker v${PKG.version}\n`);
    console.log('Where should the skill be installed?\n');
    console.log('  1) Global  (~/.claude/)  — available in all projects');
    console.log('  2) Local   (./.claude/)  — this project only\n');

    const answer = await ask('Choose [1/2] (default: 1): ');

    if (answer === '2' || answer === 'local') {
      install(LOCAL_BASE);
    } else {
      install(GLOBAL_BASE);
    }
  } else {
    // Non-interactive, default to global
    install(GLOBAL_BASE);
  }
}

main().catch((err) => {
  console.error('Error:', err.message);
  process.exit(1);
});
