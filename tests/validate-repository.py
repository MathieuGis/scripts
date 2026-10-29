#!/usr/bin/env python3
"""Validate structure and script syntax without executing administration tools."""
from pathlib import Path
from urllib.parse import unquote
import hashlib, json, re, shutil, subprocess, tempfile

ROOT = Path(__file__).resolve().parents[1]
mapping = json.loads((ROOT / 'docs/path-migration.json').read_text())
hashes = json.loads((ROOT / 'tests/backup-sha256.json').read_text())
assert len(mapping) == len(hashes) == 56
assert len(set(mapping.values())) == len(mapping)
for old, new in mapping.items():
    assert (ROOT / new).is_file(), f'Missing migrated file: {new}'
    assert not (ROOT / old).exists(), f'Obsolete path remains: {old}'
for path, expected in hashes.items():
    assert hashlib.sha256((ROOT / 'backup' / path).read_bytes()).hexdigest() == expected, f'Changed snapshot: {path}'
assert not (ROOT / 'backup/backup').exists()
assert sum(p.is_file() for p in (ROOT / 'backup').rglob('*')) == 56
for script in (ROOT / 'bash').rglob('*.sh'):
    assert b'\r' not in script.read_bytes(), f'Bash CRLF: {script}'
    subprocess.run(['bash', '-n', str(script)], check=True)
for directory in ('powershell', 'bash', 'projects'):
    for script in (ROOT / directory).rglob('*'):
        if script.suffix.lower() in ('.sh', '.ps1'):
            text = script.read_text(encoding='utf-8-sig')
            assert not re.search(r'/home/[^\n]*/usercreation/', text), f'Old path in {script}'
for doc in ROOT.rglob('*.md'):
    if 'backup' in doc.relative_to(ROOT).parts: continue
    for target in re.findall(r'\[[^\]]*\]\(([^)]+)\)', doc.read_text()):
        if '://' in target or target.startswith('#'): continue
        target = unquote(target.split('#')[0])
        assert (doc.parent / target).exists(), f'Broken link in {doc}: {target}'
# Exercise only the path bootstrap in a checkout whose path contains spaces.
with tempfile.TemporaryDirectory(prefix='script path test ') as temp:
    clone = Path(temp) / 'checkout with spaces'
    shutil.copytree(ROOT / 'bash', clone / 'bash')
    for script in (clone / 'bash/user-management').glob('*.sh'):
        text = script.read_text()
        if 'SCRIPT_DIR=' not in text: continue
        bootstrap = text.split('mkdir -p -- "$LOG_DIR/newserver"')[0] + 'mkdir -p -- "$LOG_DIR/newserver"\n'
        script.write_text(bootstrap + 'test -d "$LOG_DIR/newserver" && test -f "$SCRIPT_DIR/create-user.sh"\n')
        subprocess.run(['bash', str(script)], cwd='/', check=True)
print('PASS: migration, snapshot, Bash syntax, portable paths and documentation links')
