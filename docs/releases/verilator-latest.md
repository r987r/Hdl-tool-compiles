# Verilator — Latest Release

| Field | Value |
|-------|-------|
| **Version** | `v5.046` |
| **Release Date** | 2026-03-09 |
| **Source** | [verilator/verilator @ v5.046](https://github.com/verilator/verilator/tree/v5.046) |
| **Release Page** | [verilator-v5.046](https://github.com/r987r/Hdl-tool-compiles/releases/tag/verilator-v5.046) |

## Downloads

| Platform | Architecture | Binary | Checksum |
|----------|--------------|--------|----------|
| Linux | x86_64 | [verilator-v5.046-linux-x86_64.tar.gz](https://github.com/r987r/Hdl-tool-compiles/releases/download/verilator-v5.046/verilator-v5.046-linux-x86_64.tar.gz) | [SHA256](https://github.com/r987r/Hdl-tool-compiles/releases/download/verilator-v5.046/verilator-v5.046-linux-x86_64.tar.gz.sha256) |

## GitHub Actions Usage

```yaml
steps:
  - name: Install Verilator (latest)
    run: |
      VERSION="v5.046"
      curl -fsSL "https://github.com/r987r/Hdl-tool-compiles/releases/download/verilator-${VERSION}/verilator-${VERSION}-linux-x86_64.tar.gz" \
        -o verilator.tar.gz
      sudo tar -xzf verilator.tar.gz -C /usr/local
      echo "/usr/local/bin" >> $GITHUB_PATH
```
