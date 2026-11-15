#!/usr/bin/env python3
"""Build both Plus/4 variants. Python 3 + Java; bundled Linux/Windows packers."""
from pathlib import Path
import argparse, hashlib, os, platform, re, shutil, subprocess
ROOT = Path(__file__).resolve().parent
ap = argparse.ArgumentParser()
ap.add_argument('--no-pack', action='store_true', help='assemble ordinary PRGs only')
ap.add_argument('--use-prebuilt-noise', action='store_true', help='use supplied packed noise; verifies its runtime clock address')
args = ap.parse_args()
BUILD = ROOT / 'build'
BUILD.mkdir(exist_ok=True)
STAGE = BUILD / 'stage'
shutil.copytree(ROOT / 'src', STAGE, dirs_exist_ok=True)
JAR = Path(os.environ.get('KICKASS_JAR', str(ROOT / 'tools/KickAss.jar'))).resolve()
def run(argv, log):
    result = subprocess.run([str(x) for x in argv], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    (BUILD / log).write_text(result.stdout)
    if result.returncode:
        raise SystemExit(result.stdout)
def tool(name):
    override = os.environ.get(name.upper())
    if override: return Path(override).resolve()
    if platform.system() == 'Linux' and platform.machine() in ('x86_64', 'AMD64'):
        path = ROOT / 'tools/bin' / (name + '-linux-x86_64')
        path.chmod(path.stat().st_mode | 0o100)
        return path
    if os.name == 'nt' and name == 'exomizer':
        return ROOT / 'tools/bin/exomizer.exe'
    found = shutil.which(name)
    if found: return Path(found)
    if name == 'zx02':
        target = BUILD / ('zx02.exe' if os.name == 'nt' else 'zx02')
        folder = ROOT / 'tools/zx02-src'
        run([os.environ.get('CC', 'cc'), '-O2', *[folder / (x + '.c') for x in ('zx02', 'compress', 'optimize', 'memory')], '-o', target], 'build-zx02.log')
        return target
    raise SystemExit('Install Exomizer or set EXOMIZER to its path. See BUILDING.txt.')
def asm(name):
    run(['java', '-jar', JAR, STAGE / (name + '.asm'), '-o', BUILD / (name + '.prg'), '-symbolfile'], name + '-assembly.log')
    shutil.copy2(STAGE / (name + '.sym'), BUILD / (name + '.sym'))
def symbols(name):
    return {key: int(value, 16) for key, value in re.findall(r'\.label (\w+)=\$(\w+)', (BUILD / (name + '.sym')).read_text())}
# Iteration resolves the noise overlay's single resident ABI address after edits.
if not args.use_prebuilt_noise:
    zx02 = tool('zx02')
    for attempt in range(5):
        asm('noise')
        raw = (BUILD / 'noise.prg').read_bytes()[2:]
        (BUILD / 'noise.bin').write_bytes(raw)
        run([zx02, '-f', BUILD / 'noise.bin', BUILD / 'noise.zx02'], 'noise-compression.log')
        packed = (BUILD / 'noise.zx02').read_bytes()
        if not 512 < len(packed) <= 942: raise SystemExit('Noise exceeds its reserved packed memory banks.')
        (STAGE / 'noise_part1.bin').write_bytes(packed[:512])
        (STAGE / 'noise_part2.bin').write_bytes(packed[512:])
        asm('ntsc')
        address = symbols('ntsc')['pdr_phys_frame']
        source = (STAGE / 'noise.asm').read_text()
        updated = re.sub(r'\.label pdr_frame=\$[0-9a-f]+', f'.label pdr_frame=${address:04x}', source)
        if updated == source: break
        (STAGE / 'noise.asm').write_text(updated)
    else: raise SystemExit('Noise address did not converge.')
else:
    asm('ntsc')
    noise_address = int(re.search(r'\.label pdr_frame=\$([0-9a-f]+)', (STAGE / 'noise.asm').read_text())[1], 16)
    if symbols('ntsc')['pdr_phys_frame'] != noise_address:
        raise SystemExit('Resident clock moved. Rebuild without --use-prebuilt-noise.')
asm('pal')
assert symbols('ntsc')['pdr_phys_frame'] == symbols('pal')['pdr_phys_frame']
manifest = []
for standard in ('ntsc', 'pal'):
    out = BUILD / ('BackToThePET_Plus4_' + standard.upper() + '.prg')
    if args.no_pack:
        shutil.copy2(BUILD / (standard + '.prg'), out)
    else:
        run([tool('exomizer'), 'sfx', '8192', '-t4', '-n', '-o', out, BUILD / (standard + '.prg')], standard + '-compression.log')
    data = out.read_bytes()
    manifest.append(hashlib.sha256(data).hexdigest() + '  ' + out.name)
    print(out.name, len(data), 'bytes')
(BUILD / 'SHA256SUMS.txt').write_text('\n'.join(manifest) + '\n')
print('Builds and assembly symbols are in', BUILD)
