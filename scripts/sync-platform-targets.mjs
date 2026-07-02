#!/usr/bin/env node
/**
 * Sync Package.swift platform minimums from scripts/platform-targets.json.
 * Policy: PLATFORM_SUPPORT.md
 */
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const configPath = join(root, "scripts", "platform-targets.json");
const packagePath = join(root, "Package.swift");

const config = JSON.parse(readFileSync(configPath, "utf8"));

function minorFromStable(version) {
  const parts = version.split(".");
  if (parts.length < 2) {
    throw new Error(`Invalid stable version: ${version}`);
  }
  return Number.parseInt(parts[1], 10);
}

function minimumTarget(platformKey, majors, latestStable) {
  const oldestMajor = Math.min(...majors);
  const minor = minorFromStable(latestStable);
  return `${oldestMajor}.${minor}`;
}

const targets = {
  iOS: minimumTarget("iOS", config.supportedMajors.iOS, config.latestStable.iOS),
  macOS: minimumTarget("macOS", config.supportedMajors.macOS, config.latestStable.macOS),
  tvOS: minimumTarget("tvOS", config.supportedMajors.tvOS, config.latestStable.tvOS)
};

const packageSwift = readFileSync(packagePath, "utf8");
const platformsBlock = `    platforms: [
        .iOS("${targets.iOS}"),
        .macOS("${targets.macOS}"),
        .tvOS("${targets.tvOS}")
    ],`;

const updated = packageSwift.replace(
  /platforms: \[[\s\S]*?\],/,
  platformsBlock
);

if (updated === packageSwift) {
  console.error("sync-platform-targets: could not update Package.swift platforms block");
  process.exit(1);
}

writeFileSync(packagePath, updated);

console.log("Platform minimums synced:");
console.log(`  iOS / iPadOS : ${targets.iOS}`);
console.log(`  macOS        : ${targets.macOS}`);
console.log(`  tvOS         : ${targets.tvOS}`);
console.log(`  (from latest stable iOS ${config.latestStable.iOS})`);
