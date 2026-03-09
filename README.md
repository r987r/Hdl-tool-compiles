# HDL Tool Compiles

Pre-compiled Linux x86_64 binaries for HDL (Hardware Description Language) tools,
built from the **latest upstream releases** and published as **permanent GitHub
release artifacts**. Binaries are never deleted, ensuring stable download URLs
for dependent projects.

---

## Available Tools

| Tool | Latest Release | Source | Purpose |
|------|---------------|--------|---------|
| **Verilator** | [Latest](docs/releases/verilator-latest.md) · [History](docs/releases/verilator-history.md) | [verilator/verilator](https://github.com/verilator/verilator) | Fast open-source SystemVerilog simulator |
| **Slang** | [Latest](docs/releases/slang-latest.md) · [History](docs/releases/slang-history.md) | [MikePopoloski/slang](https://github.com/MikePopoloski/slang) | SystemVerilog language services & toolset |

---

## Supported Platforms

| Platform | OS | Architecture | Notes |
|----------|----|--------------|-------|
| `linux-x86_64` | Ubuntu 22.04 LTS | x86_64 | Compatible with most modern Linux distros, GitHub Actions runners, and Copilot agents |

---

## Usage in GitHub Actions

### Download Verilator

```yaml
steps:
  - name: Install Verilator
    run: |
      VERSION="v5.022"          # Replace with desired version
      curl -fsSL \
        "https://github.com/r987r/Hdl-tool-compiles/releases/download/verilator-${VERSION}/verilator-${VERSION}-linux-x86_64.tar.gz" \
        -o verilator.tar.gz
      sudo tar -xzf verilator.tar.gz -C /usr/local
      echo "/usr/local/bin" >> $GITHUB_PATH

  - name: Verify
    run: verilator --version
```

### Download Slang

```yaml
steps:
  - name: Install Slang
    run: |
      VERSION="v7.0"            # Replace with desired version
      curl -fsSL \
        "https://github.com/r987r/Hdl-tool-compiles/releases/download/slang-${VERSION}/slang-${VERSION}-linux-x86_64.tar.gz" \
        -o slang.tar.gz
      sudo tar -xzf slang.tar.gz -C /usr/local
      echo "/usr/local/bin" >> $GITHUB_PATH

  - name: Verify
    run: slang --version
```

---

## Download Script

A helper script is included for local or CI use:

```bash
# Download and install Verilator (latest built version)
./scripts/download-tool.sh verilator v5.022

# Download and install Slang
./scripts/download-tool.sh slang v7.0

# Specify destination
./scripts/download-tool.sh verilator v5.022 linux-x86_64 /opt/hdl-tools
```

The script:
- Auto-detects the platform (Linux x86_64)
- Verifies the SHA-256 checksum before installation
- Installs to `/usr/local` by default (configurable)

---

## Release Flow

### How It Works

The build workflows **automatically detect the latest upstream release** — no
version needs to be specified. Simply trigger the workflow and the latest version
is fetched, built, and published.

### Triggering a New Release (GitHub UI)

1. Go to [Actions](https://github.com/r987r/Hdl-tool-compiles/actions)
2. Select the appropriate workflow:
   - [**Build and Release Verilator**](https://github.com/r987r/Hdl-tool-compiles/actions/workflows/build-verilator.yml)
   - [**Build and Release Slang**](https://github.com/r987r/Hdl-tool-compiles/actions/workflows/build-slang.yml)
3. Click **Run workflow** → click **Run workflow** (the latest version is auto-detected)

### Triggering via GitHub CLI

```bash
# Release latest Verilator
gh workflow run build-verilator.yml \
  --repo r987r/Hdl-tool-compiles

# Release latest Slang
gh workflow run build-slang.yml \
  --repo r987r/Hdl-tool-compiles

# Force rebuild of latest version
gh workflow run build-slang.yml \
  --repo r987r/Hdl-tool-compiles \
  --field force_rebuild=true
```

### What the Workflow Does

1. **Detects** the latest upstream release version automatically
2. **Checks** whether the release already exists (skips if so, unless `force_rebuild=true`)
3. **Builds** the tool from source on Linux x86_64 (Ubuntu 22.04)
4. **Packages** the install tree as `.tar.gz` with a SHA-256 checksum file
5. **Creates a GitHub release** marked as "Latest" with all artifacts and release notes
6. **Updates documentation** (`docs/releases/`) and commits back to the repository

### Checking for New Upstream Versions

A [scheduled workflow](https://github.com/r987r/Hdl-tool-compiles/actions/workflows/check-upstream-versions.yml)
runs every Monday at 08:00 UTC. It compares the latest upstream releases with what has been
released here and creates GitHub issues for any gaps. You can also run it manually.

---

## Build Information

### Verilator

| Item | Value |
|------|-------|
| Source | https://github.com/verilator/verilator |
| Build OS | Ubuntu 22.04 LTS |
| Architecture | x86_64 |
| Build dependencies | `autoconf`, `flex`, `bison`, `g++`, `ccache`, `libfl-dev`, `zlib1g-dev` |
| Package format | `.tar.gz` (full install prefix tree — extract to `/usr/local`) |

### Slang

| Item | Value |
|------|-------|
| Source | https://github.com/MikePopoloski/slang |
| Build OS | Ubuntu 22.04 LTS |
| Architecture | x86_64 |
| Build system | CMake + Ninja, `Release` build type, IPO/LTO enabled |
| Build dependencies | `cmake`, `ninja-build`, `g++` |
| Package format | `.tar.gz` (full install prefix tree — extract to `/usr/local`) |

---

## Release Naming

| Format | Example |
|--------|---------|
| Tag | `verilator-v5.022` / `slang-v7.0` |
| Title | `Verilator v5.022 (Latest)` / `Slang v7.0 (Latest)` |
| Asset | `verilator-v5.022-linux-x86_64.tar.gz` |
| Checksum | `verilator-v5.022-linux-x86_64.tar.gz.sha256` |

---

## For AI Agents

See [AGENT_INSTRUCTIONS.md](AGENT_INSTRUCTIONS.md) for step-by-step instructions on how
to check for new versions, trigger releases, and verify results via the GitHub CLI or API.

---

## Documentation

- [Verilator — Latest Release](docs/releases/verilator-latest.md)
- [Verilator — Release History](docs/releases/verilator-history.md)
- [Slang — Latest Release](docs/releases/slang-latest.md)
- [Slang — Release History](docs/releases/slang-history.md)
