#!/usr/bin/env python3
"""Make a downscaled copy of a texture mod by dropping the top mip levels of
large DDS files (e.g. 4K/8K -> 2K). Nothing is re-encoded: the output is the
author's own mip, so quality matches an official downscale.

Usage: dds-downscale.py [--max 2048] OUTDIR SRC1 [SRC2 ...]

SRCs are mod folders (e.g. LMO staging dirs) merged into OUTDIR, which must not
exist yet. Non-DDS files and small DDS files are hardlinked (same filesystem
required). Sources are never modified. Files that can't be safely trimmed
(no mips, unknown format, size mismatch) are linked unchanged and listed."""
import os, struct, sys

MAX = 2048
BC8 = {70, 71, 72, 79, 80, 81}                      # BC1, BC4
BC16 = {73, 74, 75, 76, 77, 78, 82, 83, 84, 94, 95, 96, 97, 98, 99}  # BC2/3/5/6H/7
UNC = {2: 16, 10: 8, 11: 8, 24: 4, 26: 4, 27: 4, 28: 4, 29: 4, 41: 4,
       49: 2, 61: 1, 65: 1, 85: 2, 86: 2, 87: 4, 88: 4, 91: 4, 93: 4, 115: 2}
FOURCC8 = {b'DXT1', b'ATI1', b'BC4U', b'BC4S'}
FOURCC16 = {b'DXT2', b'DXT3', b'DXT4', b'DXT5', b'ATI2', b'BC5U', b'BC5S'}

stats = dict(stripped=0, linked=0, kept_nomips=0, kept_unknown=0, kept_badsize=0,
             in_bytes=0, out_bytes=0)
problems = []


def level_size(w, h, blk, bpp):
    if blk:
        return max(1, (w + 3) // 4) * max(1, (h + 3) // 4) * blk
    return max(1, w) * max(1, h) * bpp


def convert(src, dst):
    data = open(src, 'rb').read()
    if data[:4] != b'DDS ' or len(data) < 128:
        return 'unknown'
    h, w, pitch, depth, mips = struct.unpack_from('<IIIII', data, 12)
    mips = max(1, mips)
    if max(w, h) <= MAX:
        return 'small'
    pfflags = struct.unpack_from('<I', data, 80)[0]
    four = data[84:88]
    caps2 = struct.unpack_from('<I', data, 112)[0]
    hdr = 128
    faces = 6 if caps2 & 0x200 else 1
    blk = bpp = 0
    if pfflags & 0x4 and four == b'DX10':
        fmt, dim, misc, arr = struct.unpack_from('<IIII', data, 128)
        hdr = 148
        faces = max(1, arr) * (6 if misc & 0x4 else 1)
        if fmt in BC8: blk = 8
        elif fmt in BC16: blk = 16
        elif fmt in UNC: bpp = UNC[fmt]
        else: return 'unknown'
    elif pfflags & 0x4:
        if four in FOURCC8: blk = 8
        elif four in FOURCC16: blk = 16
        else: return 'unknown'
    else:
        bits = struct.unpack_from('<I', data, 88)[0]
        if bits % 8: return 'unknown'
        bpp = bits // 8
    if caps2 & 0x200000 and depth > 1:  # volume texture
        return 'unknown'
    k = 0
    while max(w, h) >> k > MAX:
        k += 1
    if mips <= k:
        return 'nomips'
    sizes = [level_size(w >> i, h >> i, blk, bpp) for i in range(mips)]
    per_face = sum(sizes)
    if hdr + per_face * faces != len(data):
        return 'badsize'
    skip = sum(sizes[:k])
    out = bytearray(data[:hdr])
    nw, nh = max(1, w >> k), max(1, h >> k)
    struct.pack_into('<II', out, 12, nh, nw)
    struct.pack_into('<I', out, 20, sizes[k] if blk else nw * bpp)
    struct.pack_into('<I', out, 28, mips - k)
    for f in range(faces):
        base = hdr + f * per_face
        out += data[base + skip: base + per_face]
    tmp = dst + '.tmp'
    with open(tmp, 'wb') as fh:
        fh.write(out)
    os.replace(tmp, dst)
    stats['in_bytes'] += len(data)
    stats['out_bytes'] += len(out)
    return 'ok'


def main():
    global MAX
    args = sys.argv[1:]
    if args[:1] == ['--max']:
        MAX = int(args[1]); args = args[2:]
    if len(args) < 2:
        sys.exit(__doc__)
    outdir, srcs = args[0], args[1:]
    if os.path.exists(outdir):
        sys.exit(f'{outdir} already exists')
    for src in srcs:
        for root, dirs, files in os.walk(src):
            rel = os.path.relpath(root, src)
            od = os.path.normpath(os.path.join(outdir, rel))
            os.makedirs(od, exist_ok=True)
            for n in files:
                s, d = os.path.join(root, n), os.path.join(od, n)
                if os.path.lexists(d):
                    problems.append(('duplicate', d)); continue
                r = convert(s, d) if n.lower().endswith('.dds') else 'small'
                if r == 'ok':
                    stats['stripped'] += 1
                    continue
                if r in ('nomips', 'unknown', 'badsize'):
                    stats['kept_' + r] += 1
                    problems.append((r, s))
                else:
                    stats['linked'] += 1
                os.link(s, d)
    print(stats)
    for p in problems:
        print(*p)


main()
