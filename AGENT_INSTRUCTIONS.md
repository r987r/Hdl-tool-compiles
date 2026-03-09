# Agent Instructions — HDL Tool Compiles

This document provides instructions for AI agents (GitHub Copilot, etc.) to facilitate
the release process for this repository.

---

## Repository Purpose

This repository provides **pre-compiled Linux x86_64 binaries** for HDL (Hardware
Description Language) tools. Binaries are built from the **latest upstream releases**
and published as GitHub release artifacts. Artifacts are **never deleted**, ensuring
stable, permanent download URLs for dependent projects.

### Managed Tools

| Tool | Source | Release Tag Format |
|------|--------|-------------------|
| Verilator | [verilator/verilator](https://github.com/verilator/verilator) | `verilator-<version>` (e.g. `verilator-v5.022`) |
| Slang | [MikePopoloski/slang](https://github.com/MikePopoloski/slang) | `slang-<version>` (e.g. `slang-v7.0`) |

### Platform

Only **Linux x86_64** (Ubuntu 22.04 LTS) binaries are built. This is the platform
used by GitHub Actions runners and Copilot agents.

---

## Checking for New Upstream Versions

### Automated (Weekly)

A scheduled workflow runs every Monday at 08:00 UTC:
- **Workflow:** `.github/workflows/check-upstream-versions.yml`
- Creates a GitHub issue for any new version not yet released here.

### Manual Check

You can trigger the check manually:

```bash
# Via GitHub CLI
gh workflow run check-upstream-versions.yml --repo r987r/Hdl-tool-compiles
```

Or navigate to: **Actions → Check Upstream Versions → Run workflow**

### Via API

```bash
# Check latest Verilator tag (Verilator uses git tags, not GitHub Releases)
curl -s https://api.github.com/repos/verilator/verilator/tags?per_page=1 | jq '.[0].name'

# Check latest Slang release (Slang uses GitHub Releases)
curl -s https://api.github.com/repos/MikePopoloski/slang/releases/latest | jq '.tag_name'

# Check if a version is already released here
gh release view "verilator-v5.022" --repo r987r/Hdl-tool-compiles
```

---

## Triggering a New Release

The build workflows **automatically detect the latest upstream version** — no version
input is required. Simply trigger the workflow and it will fetch, build, and release
the latest version.

### Step 1: Trigger the Build Workflow

#### Via GitHub CLI

```bash
# Release latest Verilator
gh workflow run build-verilator.yml \
  --repo r987r/Hdl-tool-compiles

# Release latest Slang
gh workflow run build-slang.yml \
  --repo r987r/Hdl-tool-compiles
```

#### Via GitHub UI

1. Go to [Actions](https://github.com/r987r/Hdl-tool-compiles/actions)
2. Select **Build and Release Verilator** or **Build and Release Slang**
3. Click **Run workflow**
4. Click **Run workflow** (the latest version is auto-detected)

#### Via GitHub REST API

```bash
curl -X POST \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/r987r/Hdl-tool-compiles/actions/workflows/build-verilator.yml/dispatches" \
  -d '{"ref":"main"}'
```

### Step 2: Monitor the Workflow

```bash
# List recent workflow runs
gh run list --repo r987r/Hdl-tool-compiles --workflow build-verilator.yml --limit 5

# Watch a specific run
gh run watch <run-id> --repo r987r/Hdl-tool-compiles
```

### Step 3: Verify the Release

```bash
# Check release was created (replace version with actual detected version)
gh release view "verilator-v5.022" --repo r987r/Hdl-tool-compiles

# List release assets
gh release view "verilator-v5.022" --repo r987r/Hdl-tool-compiles --json assets --jq '.assets[].name'
```

Expected assets (Linux x86_64 only):
- `verilator-v5.022-linux-x86_64.tar.gz`
- `verilator-v5.022-linux-x86_64.tar.gz.sha256`

---

## Forcing a Rebuild

If a release needs to be rebuilt (e.g., build was broken):

```bash
gh workflow run build-verilator.yml \
  --repo r987r/Hdl-tool-compiles \
  --field force_rebuild=true
```

This will delete the existing release and rebuild the latest version from scratch.

---

## Closing Release Issues

After a successful release, close the corresponding GitHub issue:

```bash
# List open release issues
gh issue list --repo r987r/Hdl-tool-compiles --label release-needed

# Close an issue
gh issue close <issue-number> --repo r987r/Hdl-tool-compiles \
  --comment "Released as verilator-v5.022: https://github.com/r987r/Hdl-tool-compiles/releases/tag/verilator-v5.022"
```

---

## Release Naming Convention

| Tool | Upstream Tag | Release Tag | Release Title |
|------|-------------|-------------|---------------|
| Verilator | `v5.022` | `verilator-v5.022` | `Verilator v5.022 (Latest)` |
| Slang | `v7.0` | `slang-v7.0` | `Slang v7.0 (Latest)` |

---

## Documentation Updates

The build workflows automatically update:

- `docs/releases/verilator-latest.md` — Latest Verilator release info
- `docs/releases/verilator-history.md` — Verilator release history table
- `docs/releases/slang-latest.md` — Latest Slang release info
- `docs/releases/slang-history.md` — Slang release history table

These are committed back to the repository with `[skip ci]` to avoid triggering new workflows.

---

## Supported Platforms

| Platform Identifier | OS | Architecture |
|---------------------|-----|--------------|
| `linux-x86_64` | Ubuntu 22.04 LTS | x86_64 |

---

## Troubleshooting

### Build failed: dependency not found

Check the workflow logs in GitHub Actions. Common issues:
- Upstream version tag does not exist → verify with `git ls-remote --tags https://github.com/verilator/verilator`
- Build dependency changed → update the `apt-get install` step in the workflow

### Release not created

If the build succeeded but the release wasn't created:
1. Check the `release` job logs
2. Ensure the `contents: write` permission is set (it is by default in the workflows)
3. Try running with `force_rebuild=true`

### Documentation not updated

If docs weren't committed:
1. Check if the `git push` step failed (could be a branch protection rule)
2. Manually update the files and commit with `[skip ci]` in the message
