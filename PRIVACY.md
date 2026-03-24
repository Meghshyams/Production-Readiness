# Privacy Policy

**Last updated**: March 23, 2026

## Overview

The **production-readiness** plugin for Claude Code is a local audit tool that runs entirely within your Claude Code session. It does not collect, store, transmit, or share any user data.

## What This Plugin Does

The plugin provides markdown-based instructions that guide Claude Code to analyze your project for production readiness. All analysis happens locally within your Claude Code environment.

## Data Collection

This plugin collects **no data whatsoever**. Specifically:

- **No telemetry**: No usage data, analytics, or metrics are collected
- **No network requests**: The plugin makes no outbound network calls (except commands you would run yourself, like `npm audit`, which contact public registries)
- **No user tracking**: No cookies, identifiers, or fingerprinting
- **No data storage**: No data is sent to any external server or third party

## Local Files

The plugin may create a `.production-readiness/` directory in your project root containing:

- `cache.json` — cached audit results for faster reruns
- `last-report.md` — the most recent audit report

These files are stored **locally in your project** and are not transmitted anywhere. We recommend adding `.production-readiness/` to your `.gitignore`.

## Third-Party Services

The plugin does not integrate with any third-party services. Commands like `npm audit` or `pip audit` are standard package manager features that contact their respective public registries — this behavior is identical to running those commands manually.

## Open Source

This plugin is fully open source under the MIT License. You can inspect the complete source code at [github.com/Meghshyams/production-readiness](https://github.com/Meghshyams/production-readiness).

## Contact

For questions about this privacy policy, open an issue at [github.com/Meghshyams/production-readiness/issues](https://github.com/Meghshyams/production-readiness/issues).
