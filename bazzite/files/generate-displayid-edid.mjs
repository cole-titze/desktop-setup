#!/usr/bin/env node
// Self-contained EDID generator for virtual Sunshine displays that need a
// pixel clock beyond the base EDID Detailed Timing Descriptor's 655.35 MHz
// field limit (2-byte, 10 kHz units) -- e.g. 2752x2064@120Hz (~763 MHz) for
// the iPad Pro 13" virtual display.
//
// The base EDID block gets a same-resolution fallback DTD at the highest
// refresh rate that DOES fit under 655.35 MHz (so a non-DisplayID-aware
// consumer of the EDID still gets a sane mode). The requested high-clock
// mode is carried in a DisplayID 1.3 extension block (tag 0x70, version
// 0x13) as a Type I Detailed Timing (tag 0x03), which uses a 3-byte pixel
// clock field (10 kHz units, ~167 GHz headroom) -- unlike DisplayID 2.0's
// Type VII block, which this GPU generation/driver (tested: RTX 4070 Ti,
// NVIDIA 610.43.03) silently ignores for a `drm.edid_firmware`-loaded
// virtual connector. See the "iPad streaming" section of README.md.
//
// Usage: node generate-displayid-edid.mjs <width> <height> <refreshHz> <mfgId> <displayName> <dpi> <outFile>
// Example: node generate-displayid-edid.mjs 2752 2064 120 IPD "iPad Pro 13" 264 edid.bin

import { writeFileSync } from 'node:fs';

// ---- CVT Reduced Blanking v1 (VESA CVT Standard v1.2), no external deps ----
const RB_H_BLANK = 160, RB_H_SYNC = 32, RB_H_FRONT = 48;
const RB_V_FRONT = 3, RB_MIN_V_BLANK_US = 460.0, RB_MIN_V_BACK = 6;
const CLOCK_STEP_KHZ = 250;

function computeVSync(width, height) {
  const r = width / height;
  if (Math.abs(r - 4 / 3) < 0.02) return 4;
  if (Math.abs(r - 16 / 9) < 0.02) return 5;
  if (Math.abs(r - 16 / 10) < 0.02) return 6;
  if (Math.abs(r - 5 / 4) < 0.02) return 7;
  if (Math.abs(r - 15 / 9) < 0.02) return 7;
  return 10;
}

function computeTiming(width, height, refreshRate) {
  const hTotal = width + RB_H_BLANK;
  const vSync = computeVSync(width, height);
  const hPeriodUs = (1e6 / refreshRate - RB_MIN_V_BLANK_US) / (height + RB_V_FRONT);
  const vbiLines = Math.floor(RB_MIN_V_BLANK_US / hPeriodUs) + 1;
  const minVbi = RB_V_FRONT + vSync + RB_MIN_V_BACK;
  const actVbi = Math.max(vbiLines, minVbi);
  const vTotal = height + actVbi;
  const rawClockKhz = refreshRate * vTotal * hTotal / 1000;
  const pixelClockKhz = Math.floor(rawClockKhz / CLOCK_STEP_KHZ) * CLOCK_STEP_KHZ;
  return {
    pixelClockKhz, hActive: width, hBlanking: RB_H_BLANK, hSyncOffset: RB_H_FRONT,
    hSyncPulse: RB_H_SYNC, vActive: height, vBlanking: actVbi, vSyncOffset: RB_V_FRONT,
    vSyncPulse: vSync, hsyncPol: 1, vsyncPol: 0, refreshRate, reducedBlanking: true,
  };
}

// ---- EDID base block helpers ----
const SRGB_CHROMATICITY = Buffer.from([0xea, 0x5e, 0xc0, 0xa4, 0x59, 0x4a, 0x98, 0x25, 0x20, 0x50]);
const COLOR_DEPTH_BITS = { 6: 0b001, 8: 0b010, 10: 0b011, 12: 0b100 };
const INTERFACE_BITS = { HDMI: 0b0010, DisplayPort: 0b0101 };
const MAX_DTD_CLOCK_KHZ = 655350;

function encodeMfgId(c1, c2, c3) {
  const v = ((c1.charCodeAt(0) - 0x40) & 0x1f) << 10
          | ((c2.charCodeAt(0) - 0x40) & 0x1f) << 5
          | ((c3.charCodeAt(0) - 0x40) & 0x1f);
  return [(v >> 8) & 0xff, v & 0xff];
}

function encodeDetailedTiming(timing, displaySizeMm) {
  const buf = Buffer.alloc(18);
  const { pixelClockKhz, hActive, hBlanking, hSyncOffset, hSyncPulse,
          vActive, vBlanking, vSyncOffset, vSyncPulse, hsyncPol, vsyncPol } = timing;
  buf.writeUInt16LE(Math.round(pixelClockKhz / 10), 0);
  buf[2] = hActive & 0xff;
  buf[3] = hBlanking & 0xff;
  buf[4] = ((hActive >> 8) & 0x0f) << 4 | ((hBlanking >> 8) & 0x0f);
  buf[5] = vActive & 0xff;
  buf[6] = vBlanking & 0xff;
  buf[7] = ((vActive >> 8) & 0x0f) << 4 | ((vBlanking >> 8) & 0x0f);
  buf[8] = hSyncOffset & 0xff;
  buf[9] = hSyncPulse & 0xff;
  buf[10] = ((vSyncOffset & 0x0f) << 4) | (vSyncPulse & 0x0f);
  buf[11] = ((hSyncOffset >> 8) & 0x03) << 6 | ((hSyncPulse >> 8) & 0x03) << 4
          | ((vSyncOffset >> 4) & 0x03) << 2 | ((vSyncPulse >> 4) & 0x03);
  const { hMm, vMm } = displaySizeMm;
  buf[12] = hMm & 0xff;
  buf[13] = vMm & 0xff;
  buf[14] = ((hMm >> 8) & 0x0f) << 4 | ((vMm >> 8) & 0x0f);
  buf[17] = 0x18 | ((vsyncPol ? 1 : 0) << 2) | ((hsyncPol ? 1 : 0) << 1);
  return buf;
}

// Range covers both the base-block fallback DTD and the higher-clock
// DisplayID timing, so edid-decode doesn't warn about the preferred mode
// falling outside the declared monitor range.
function encodeRangeLimits(fallbackTiming, preferredTiming) {
  const buf = Buffer.alloc(18);
  buf[3] = 0xfd;
  const fallbackHFreqKhz = fallbackTiming.pixelClockKhz / (fallbackTiming.hActive + fallbackTiming.hBlanking);
  const preferredHFreqKhz = preferredTiming.pixelClockKhz / (preferredTiming.hActive + preferredTiming.hBlanking);
  const minVFreq = Math.min(fallbackTiming.refreshRate, preferredTiming.refreshRate);
  const maxVFreq = Math.max(fallbackTiming.refreshRate, preferredTiming.refreshRate);
  const minHFreq = Math.min(fallbackHFreqKhz, preferredHFreqKhz);
  const maxHFreq = Math.max(fallbackHFreqKhz, preferredHFreqKhz);

  let maxV = Math.min(510, Math.ceil(maxVFreq) + 1);
  let maxH = Math.min(510, Math.ceil(maxHFreq) + 1);
  // EDID 1.4 byte4 offset flags let V/H max exceed the single-byte 255 cap.
  let byte4 = 0;
  if (maxV > 255) { byte4 |= 0x02; maxV -= 255; }
  if (maxH > 255) { byte4 |= 0x08; maxH -= 255; }
  buf[4] = byte4;

  buf[5] = Math.max(1, Math.floor(minVFreq) - 1);
  buf[6] = maxV;
  buf[7] = Math.max(1, Math.floor(minHFreq) - 1);
  buf[8] = maxH;
  buf[9] = Math.min(255, Math.ceil(preferredTiming.pixelClockKhz / 10000) + 1);
  buf[10] = 0x01; // Range Limits Only (EDID 1.4)
  buf[11] = 0x0a;
  for (let i = 12; i < 18; i++) buf[i] = 0x20;
  return buf;
}

function encodeTextDescriptor(tag, text) {
  const buf = Buffer.alloc(18);
  buf[3] = tag;
  const bytes = Buffer.from(String(text).substring(0, 13), 'ascii');
  bytes.copy(buf, 5);
  const endPos = 5 + Math.min(bytes.length, 13);
  if (endPos < 18) buf[endPos] = 0x0a;
  for (let i = endPos + 1; i < 18; i++) buf[i] = 0x20;
  return buf;
}

function computeChecksum(block128) {
  let sum = 0;
  for (let i = 0; i < 127; i++) sum += block128[i];
  return (256 - (sum & 0xff)) & 0xff;
}

function buildBaseBlock(state, preferredTiming, fallbackTiming, displaySizeMm) {
  const buf = Buffer.alloc(128);
  Buffer.from([0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00]).copy(buf, 0);
  const [mfgHi, mfgLo] = encodeMfgId(...state.mfgId.toUpperCase());
  buf[8] = mfgHi; buf[9] = mfgLo;
  const now = new Date();
  buf[16] = Math.min(54, Math.ceil(((now - new Date(now.getFullYear(), 0, 1)) / 86400000 + 1) / 7));
  buf[17] = now.getFullYear() - 1990;
  buf[18] = 1; buf[19] = 4; // EDID 1.4
  buf[20] = 0x80 | (COLOR_DEPTH_BITS[state.colorDepth] << 4) | INTERFACE_BITS['DisplayPort'];
  buf[21] = Math.round(displaySizeMm.hMm / 10);
  buf[22] = Math.round(displaySizeMm.vMm / 10);
  buf[23] = 120; // Gamma 2.20
  buf[24] = 0xea;
  SRGB_CHROMATICITY.copy(buf, 25);
  Buffer.alloc(16, 0x01).copy(buf, 38); // No standard timings
  encodeDetailedTiming(fallbackTiming, displaySizeMm).copy(buf, 54);
  encodeRangeLimits(fallbackTiming, preferredTiming).copy(buf, 72);
  encodeTextDescriptor(0xfc, state.displayName).copy(buf, 90);
  encodeTextDescriptor(0xff, 'Linux #0').copy(buf, 108);
  buf[126] = 1; // 1 extension block follows
  buf[127] = computeChecksum(buf);
  return buf;
}

// ---- DisplayID 1.3 extension (tag 0x70, version 0x13) ----
// Verified against edid-decode's parse_displayid_type_1_7_timing(): both
// Type I (1.x) and Type VII (2.0) share the same 20-byte layout and "-1
// stored / +1 on read" convention; only the pixel clock unit differs
// (Type I = 10 kHz, Type VII = 1 kHz).
function detectDisplayIdAspect(width, height) {
  const ratio = width / height;
  const aspects = [
    { code: 0x0, value: 1 }, { code: 0x1, value: 5 / 4 }, { code: 0x2, value: 4 / 3 },
    { code: 0x3, value: 15 / 9 }, { code: 0x4, value: 16 / 9 }, { code: 0x5, value: 16 / 10 },
    { code: 0x6, value: 64 / 27 }, { code: 0x7, value: 256 / 135 },
  ];
  let best = aspects[4], bestDiff = Math.abs(ratio - best.value);
  for (const a of aspects) {
    const diff = Math.abs(ratio - a.value);
    if (diff < bestDiff) { best = a; bestDiff = diff; }
  }
  return best.code;
}

function encodeTypeITiming(timing, isPreferred) {
  const buf = Buffer.alloc(20);
  const { pixelClockKhz, hActive, hBlanking, hSyncOffset, hSyncPulse,
          vActive, vBlanking, vSyncOffset, vSyncPulse, hsyncPol, vsyncPol } = timing;
  const clock10kM1 = Math.round(pixelClockKhz / 10) - 1;
  buf[0] = clock10kM1 & 0xff; buf[1] = (clock10kM1 >> 8) & 0xff; buf[2] = (clock10kM1 >> 16) & 0xff;
  buf[3] = (isPreferred ? 0x80 : 0x00) | (detectDisplayIdAspect(hActive, vActive) & 0x0f);
  const hActM1 = hActive - 1;
  buf[4] = hActM1 & 0xff; buf[5] = (hActM1 >> 8) & 0xff;
  const hBlkM1 = hBlanking - 1;
  buf[6] = hBlkM1 & 0xff; buf[7] = (hBlkM1 >> 8) & 0xff;
  const hFpM1 = hSyncOffset - 1;
  buf[8] = hFpM1 & 0xff; buf[9] = ((hsyncPol ? 1 : 0) << 7) | ((hFpM1 >> 8) & 0x7f);
  const hSwM1 = hSyncPulse - 1;
  buf[10] = hSwM1 & 0xff; buf[11] = (hSwM1 >> 8) & 0xff;
  const vActM1 = vActive - 1;
  buf[12] = vActM1 & 0xff; buf[13] = (vActM1 >> 8) & 0xff;
  const vBlkM1 = vBlanking - 1;
  buf[14] = vBlkM1 & 0xff; buf[15] = (vBlkM1 >> 8) & 0xff;
  const vFpM1 = vSyncOffset - 1;
  buf[16] = vFpM1 & 0xff; buf[17] = ((vsyncPol ? 1 : 0) << 7) | ((vFpM1 >> 8) & 0x7f);
  const vSwM1 = vSyncPulse - 1;
  buf[18] = vSwM1 & 0xff; buf[19] = (vSwM1 >> 8) & 0xff;
  return buf;
}

// Display Parameters Data Block (tag 0x01) -- required by the DisplayID 1.x
// spec; edid-decode fails conformance without it.
function encodeDisplayParams13(buf, offset, displaySizeMm, hPixels, vPixels) {
  buf[offset] = 0x01; buf[offset + 1] = 0x00; buf[offset + 2] = 12;
  const p = offset + 3;
  const hSizeTenths = Math.round(displaySizeMm.hMm * 10);
  const vSizeTenths = Math.round(displaySizeMm.vMm * 10);
  buf[p] = hSizeTenths & 0xff; buf[p + 1] = (hSizeTenths >> 8) & 0xff;
  buf[p + 2] = vSizeTenths & 0xff; buf[p + 3] = (vSizeTenths >> 8) & 0xff;
  buf[p + 4] = hPixels & 0xff; buf[p + 5] = (hPixels >> 8) & 0xff;
  buf[p + 6] = vPixels & 0xff; buf[p + 7] = (vPixels >> 8) & 0xff;
  buf[p + 8] = 0x00;
  buf[p + 9] = Math.round(2.20 * 100) - 100;
  buf[p + 10] = Math.round((hPixels / vPixels) * 100) - 100;
  buf[p + 11] = (7 << 4) | 7; // 8 bpc native + overall
  return 3 + 12;
}

function buildDisplayId13ExtensionBlock(timing, displaySizeMm) {
  const buf = Buffer.alloc(128);
  buf[0] = 0x70; buf[1] = 0x13; buf[3] = 0x02; buf[4] = 0x00;
  let offset = 5;
  offset += encodeDisplayParams13(buf, offset, displaySizeMm, timing.hActive, timing.vActive);
  buf[offset] = 0x03; buf[offset + 1] = 0x00; buf[offset + 2] = 20;
  offset += 3;
  encodeTypeITiming(timing, true).copy(buf, offset);
  offset += 20;
  const sectionSize = offset - 5;
  buf[2] = sectionSize;
  const checksumPos = sectionSize + 5;
  let sum = 0;
  for (let i = 1; i < checksumPos; i++) sum += buf[i];
  buf[checksumPos] = (256 - (sum & 0xff)) & 0xff;
  buf[127] = computeChecksum(buf);
  return buf;
}

// ---- CLI ----
const [, , widthArg, heightArg, refreshArg, mfgId, displayName, dpiArg, outFile] = process.argv;
if (!outFile) {
  console.error('Usage: node generate-displayid-edid.mjs <width> <height> <refreshHz> <mfgId> <displayName> <dpi> <outFile>');
  process.exit(1);
}
const width = parseInt(widthArg, 10);
const height = parseInt(heightArg, 10);
const refreshHz = parseInt(refreshArg, 10);
const dpi = parseInt(dpiArg, 10);

const preferredTiming = computeTiming(width, height, refreshHz);
if (preferredTiming.pixelClockKhz <= MAX_DTD_CLOCK_KHZ) {
  console.error(`Note: ${width}x${height}@${refreshHz}Hz (${(preferredTiming.pixelClockKhz / 1000).toFixed(1)} MHz) ` +
    `fits under the 655.35 MHz DTD limit -- a plain crh-injected EDID (see README) works fine, no DisplayID needed.`);
}

let fallbackTiming = null;
for (const rate of [60, 50, 48, 30, 24]) {
  if (rate >= refreshHz) continue;
  const t = computeTiming(width, height, rate);
  if (t.pixelClockKhz <= MAX_DTD_CLOCK_KHZ) { fallbackTiming = t; break; }
}
if (!fallbackTiming) fallbackTiming = preferredTiming; // already fits

const displaySizeMm = { hMm: Math.round((width * 25.4) / dpi), vMm: Math.round((height * 25.4) / dpi) };
const state = { mfgId, displayName, colorDepth: 8 };

const baseBlock = buildBaseBlock(state, preferredTiming, fallbackTiming, displaySizeMm);
const ext = buildDisplayId13ExtensionBlock(preferredTiming, displaySizeMm);
writeFileSync(outFile, Buffer.concat([baseBlock, ext]));

console.log(`Wrote ${outFile}: base DTD ${fallbackTiming.hActive}x${fallbackTiming.vActive}@${fallbackTiming.refreshRate}Hz ` +
  `(${(fallbackTiming.pixelClockKhz / 1000).toFixed(1)} MHz), DisplayID 1.3 Type I ${width}x${height}@${refreshHz}Hz ` +
  `(${(preferredTiming.pixelClockKhz / 1000).toFixed(1)} MHz). Validate with: edid-decode -c ${outFile}`);
