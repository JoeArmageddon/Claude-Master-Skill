#!/usr/bin/env node
// .claude/hooks/context-monitor.mjs
// StatusLine script — displays live context usage percentage.
// Configure in .claude/settings.json under "statusLine".

import { createInterface } from 'readline';

const rl = createInterface({ input: process.stdin });

rl.on('line', (line) => {
  try {
    const data = JSON.parse(line);
    const ctx = data?.context_window;
    if (!ctx) { process.stdout.write(''); return; }

    const used  = ctx.used_tokens  ?? 0;
    const total = ctx.total_tokens ?? 200000;
    const pct   = Math.round((used / total) * 100);

    let icon = '●';
    let note = '';
    if (pct >= 80) { icon = '⚠'; note = ' compact now';      }
    else if (pct >= 70) { icon = '◕'; note = ' consider compact'; }
    else if (pct >= 50) { icon = '◑'; }

    process.stdout.write(`${icon} ${pct}% ctx${note}`);
  } catch {
    process.stdout.write('');
  }
});
