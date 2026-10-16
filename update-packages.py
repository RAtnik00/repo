#!/usr/bin/env python3
import bz2
import gzip
import hashlib
import io
from pathlib import Path
import tarfile

root = Path.cwd()
entries = []
for path in sorted((root / 'debs').glob('*.deb')):
    data = path.read_bytes()
    if not data.startswith(b'!<arch>\n'):
        raise ValueError(f'Invalid deb: {path.name}')
    offset = 8
    control = None
    while offset + 60 <= len(data):
        header = data[offset:offset + 60]
        if header[58:60] != b'`\n':
            raise ValueError(f'Invalid archive header: {path.name}')
        name = header[:16].decode().strip().rstrip('/')
        size = int(header[48:58])
        start = offset + 60
        payload = data[start:start + size]
        if len(payload) != size:
            raise ValueError(f'Truncated archive: {path.name}')
        if name.startswith('control.tar'):
            with tarfile.open(fileobj=io.BytesIO(payload), mode='r:*') as archive:
                member = next(m for m in archive if m.name.lstrip('./') == 'control')
                control = archive.extractfile(member).read().decode('utf-8')
        offset = start + size + (size % 2)
    if control is None:
        raise ValueError(f'Missing control: {path.name}')
    fields = control.rstrip('\n')
    if 'Package: com.ratnik00.nextclock' in fields.splitlines():
        fields = '\n'.join(line for line in fields.splitlines()
                           if not line.startswith(('Depiction:', 'SileoDepiction:')))
        fields += '\nDepiction: https://ratnik00.github.io/repo/depictions/nextclock/'
        fields += '\nSileoDepiction: https://ratnik00.github.io/repo/depictions/nextclock/depiction.json'
    fields += f'\nFilename: debs/{path.name}\nSize: {len(data)}\n'
    for label, algorithm in [('MD5sum', 'md5'), ('SHA1', 'sha1'), ('SHA256', 'sha256')]:
        fields += f'{label}: {hashlib.new(algorithm, data).hexdigest()}\n'
    entries.append(fields)
if not entries:
    raise SystemExit('No .deb files found in debs; index left unchanged.')
index = ('\n'.join(entries) + '\n').encode('utf-8')
(root / 'Packages').write_bytes(index)
(root / 'Packages.gz').write_bytes(gzip.compress(index, mtime=0))
(root / 'Packages.bz2').write_bytes(bz2.compress(index))
print(f'Created package indexes: {len(entries)} package(s).')
