# Console Dotfiles (`dubodots`)

A modular, cross-platform collection of dotfiles, shell scripts, and terminal configurations designed for **Cloud AI Forward Deployed Engineers (FDEs), cloud developers, and agentic terminal power users** on macOS and Linux.

## Features & Design Principles

* **Agentic Coding & `obra/superpowers` Ready**: Out-of-the-box integration with **Antigravity**, **Claude Code**, and **Gemini CLI**, pre-loaded with [`obra/superpowers`](https://github.com/obra/superpowers) skills (Socratic brainstorming, spec-first planning, RED-GREEN-REFACTOR TDD, subagent-driven development, systematic debugging, and isolated Git worktrees).
* **Mitchell Hashimoto Terminal & Harness Workflow**: Incorporates Mitchell Hashimoto's Ghostty configuration (`desktop-notifications = false` to prevent background agent focus-stealing, fast split navigation), **Jujutsu (`jj`)** workflow (`tug`, `retrunk`), **Harness Engineering** (`harness_init`, `spec_new`, `Justfile`), and `uv` / `gh` triage helpers.
* **Cloud & AI FDE Toolkit**: Pre-configured with `kubectl`, `kubectx` (`kx`), `kubens` (`kn`), `k9s`, `stern`, `helm`, `jq`, `yq`, `grpcurl`, `sops`, `age`, interactive `fzf` Kubernetes & GCP selectors (`gcpinfo`, `gprojf`, `gctxf`, `klog`, `kexec`, `kpf`), and instant Vertex AI Gemini endpoint testing (`vertex_ping`).
* **Fast Terminal Workflow**: Includes Powerlevel10k with instant prompt, `fzf` fuzzy finding, `ripgrep` (`rg`), `fd`, `bat`, `eza`, `atuin`, `htop`, `watch`, `direnv`, and lazy-loaded `nvm` for near-instant shell startup.
* **Enterprise & Managed Environment Safe**: Preserves system-provided `/bin/zsh`, `/etc/zshrc`, `/usr/local/git`, and `/usr/local/go` precedence, disables external agent telemetry (`SUPERPOWERS_DISABLE_TELEMETRY=1`, `DISABLE_TELEMETRY=1`), and avoids storing plaintext credentials.
* **Local Customization Hooks**: Supports untracked `~/.zshrc.local` and `~/.gitconfig.local` files so machine-specific or work-specific settings never pollute the repository.

---

## Installation

### Quick Start

Run the unified setup script (automatically detects macOS or Linux):

```sh
# Clone repository to ~/.dotfiles (or any preferred directory)
git clone https://github.com/duboc/dubodots.git "$HOME/.dotfiles"
cd "$HOME/.dotfiles"

# Execute unified setup script
./setup.sh
```

> **Note:** If you clone the repository to another path (e.g., `~/projects/dubodots`), running `./setup.sh` or `./setup_links.sh` automatically creates the `~/.dotfiles` symlink pointing to your checkout directory.

### Running Individual Setup Modules

Each setup stage is modular and idempotent, so you can run individual scripts anytime:

| Script | Description |
| :--- | :--- |
| `./setup.sh` | Full end-to-end base setup for macOS or Linux |
| `./setup_links.sh` | Creates/updates symlinks in `~`, `~/.config/` (Ghostty, Jujutsu, Git, htop) |
| `./setup_agents.sh` | **Optional:** Installs/configures [`obra/superpowers`](https://github.com/obra/superpowers), Claude Code (`--claude`), and/or Antigravity (`--antigravity`) |
| `./setup_zsh.sh` | Installs/updates Oh My Zsh, Powerlevel10k, and Zsh plugins |
| `./setup_tmux.sh` | Installs/updates Tmux Plugin Manager (`tpm`) and Tmux plugins |
| `./setup_git_user.sh` | Configures your Git `user.name` and `user.email` in `~/.gitconfig.local` |
| `./go_apps.sh` | Installs Go developer utilities (`2fa`, `benchstat`, `yaegi`) via `go install` |

---

## Agentic Development Workflow (`obra/superpowers` & Mitchell Hashimoto)

Configured via [`setup_agents.sh`](setup_agents.sh), [`agents/AGENTS.md`](agents/AGENTS.md), and [`shellconfig/agents.sh`](shellconfig/agents.sh).

### 1. Optional Multi-Harness `obra/superpowers` Integration
Agent configurations are **opt-in** so you can enable only the harnesses permitted on a given machine:

```sh
# Configure Claude Code (~/.claude + obra/superpowers)
./setup_agents.sh --claude

# Configure Antigravity & Gemini CLI (~/.gemini + obra/superpowers)
./setup_agents.sh --antigravity

# Configure both
./setup_agents.sh --all

# Remove all installed agent configurations and obra/superpowers
./setup_agents.sh --uninstall
```

When enabled, `./setup_agents.sh` clones [`obra/superpowers`](https://github.com/obra/superpowers) into `~/.local/share/superpowers` and wires its 15 core skills (`brainstorming`, `using-git-worktrees`, `writing-plans`, `subagent-driven-development`, `executing-plans`, `test-driven-development`, `systematic-debugging`, `verification-before-completion`, `dispatching-parallel-agents`, etc.) for the selected target(s):
* **Antigravity (`--antigravity`)**: Installed as a plugin in `~/.gemini/config/plugins/superpowers` with `always_on` bootstrap rules in `~/.gemini/config/rules/superpowers.md` and `~/.gemini/config/rules/global-engineering.md`, plus `~/.gemini/skills/` and `~/.agents/skills/`.
* **Claude Code (`--claude`)**: Symlinked into `~/.claude/skills/` with `~/.claude/CLAUDE.md` and privacy-hardened `~/.claude/settings.json` (and installs `claude-code` via Homebrew Cask on macOS if not present).

### 2. Git Worktrees, Jujutsu (`jj`) & Harness Engineering
Inspired by Mitchell Hashimoto's *"My AI Adoption Journey"* (separate planning from execution, engineer the harness, run background agents in isolated worktrees without desktop notification interruptions):

| Command / Alias | Usage | Description |
| :--- | :--- | :--- |
| `wta` | `wta <branch> [base]` | Create an isolated Git worktree in `../<repo>-worktrees/<branch>`, copy `.env`/`.envrc`, run `direnv allow`, and `cd` into it |
| `wts` | `wts` | Interactive `fzf` worktree switcher with live `git status` + `git log` preview |
| `wtrm` | `wtrm [worktree]` | Interactive `fzf` worktree remover + `git worktree prune` |
| `wtlist` | `wtlist` | List active Git worktrees (`git worktree list`) |
| `harness_init` | `harness_init` | Scaffold `AGENTS.md` (plus `CLAUDE.md` & `GEMINI.md` symlinks), `Justfile`, and `docs/plans/` in the current repo |
| `spec_new` | `spec_new <slug>` | Create a timestamped spec & TDD implementation plan in `docs/plans/YYYY-MM-DD-<slug>.md` |
| `ghprs` / `ghissues` | `ghprs` / `ghissues` | Interactive `fzf` GitHub PR checkout and Issue triage browsers with live preview |
| `js` / `jl` / `jd` / `jn` | Jujutsu (`jj`) | `jj st`, `jj log`, `jj desc`, `jj new` |
| `jtug` / `jretrunk` | Jujutsu (`jj`) | Move closest bookmark to `@-` (`jj tug`) or rebase onto trunk (`jj retrunk`) |
| `jx` / `jls` | `just` | Run `just` tasks or `just --list` |

---

## Cloud, Kubernetes & AI FDE Workflow

Defined in [`shellconfig/kubernetes.sh`](shellconfig/kubernetes.sh), [`shellconfig/agents.sh`](shellconfig/agents.sh), and [`shellconfig/aliases.sh`](shellconfig/aliases.sh).

### Google Cloud & Vertex AI FDE Helpers
| Command / Alias | Usage | Description |
| :--- | :--- | :--- |
| `gcpinfo` | `gcpinfo` | Print active `gcloud` config, account, project, region, ADC status, and Kubernetes context |
| `gprojf` | `gprojf` | Interactive `fzf` GCP project selector (`gcloud projects list` $\rightarrow$ `gcloud config set project`) |
| `gctxf` | `gctxf` | Interactive `fzf` `gcloud` configuration switcher |
| `vertex_ping` | `vertex_ping [prompt] [model] [region]` | Smoke-test Vertex AI Gemini REST endpoint (`generateContent`) in the active project to verify IAM, ADC, and VPC-SC |
| `crun_url` | `crun_url [service]` | Resolve Cloud Run service URL (opens interactive `fzf` picker if omitted) |
| `gtoken` / `gidtoken` | `gtoken` / `gidtoken` | Print active OAuth2 access token or OIDC identity token |
| `gadc` | `gadc` | Refresh Google Cloud Application Default Credentials (`gcloud auth application-default login`) |
| `tf` | `tf` | `terraform` shorthand |

### Kubernetes Context & Interactive Pod Helpers (`fzf`-Enabled)
All pod helper functions accept an optional pod name substring. **If called with no arguments, they open an interactive `fzf` selector** showing live pod status in the current namespace:

| Command / Alias | Usage | Description |
| :--- | :--- | :--- |
| `k` / `kx` / `kn` | `k` / `kx` / `kn` | `kubectl`, `kubectx` (switch cluster), `kubens` (switch namespace) |
| `k9` / `h` | `k9` / `h` | Launch `k9s` terminal UI or `helm` |
| `klog` | `klog [pod-query] [flags...]` | Follow logs (`-f`) for a matching or `fzf`-selected pod |
| `kexec` | `kexec [pod-query] [cmd...]` | Execute a command (defaults to `/bin/sh`) in a matching or `fzf`-selected pod |
| `kdesc` | `kdesc [pod-query]` | Run `kubectl describe pod` on a matching or `fzf`-selected pod |
| `kpf` | `kpf [pod-query] <local:remote>` | Port-forward `<local:remote>` (or single `<port>`) to a pod |
| `wpod` | `wpod [pod-query]` | Watch pods matching a query string every 2 seconds |
| `kg` / `kgall` | `kubectl get` / `get all` | Inspect resources in current namespace |
| `kgp` / `kgpw` / `kgpa` | `kubectl get pods` (`-o wide`, `-A`) | List pods (standard, wide, or all namespaces) |
| `kgs` / `kgd` / `kgn` | `kubectl get svc / deploy / nodes -o wide` | Inspect services, deployments, or nodes |
| `kge` | `kubectl get events --sort-by=.lastTimestamp` | View cluster events sorted chronologically |
| `kaf` / `kdel` | `kubectl apply -f` / `kubectl delete` | Apply manifests or delete resources |
| `kroll` / `krestart` | `kubectl rollout status / restart deploy` | Track or trigger deployment rollouts |
| `ktop` / `ktopn` | `kubectl top pods` / `kubectl top nodes` | View pod and node resource consumption |

---

## Terminal & Developer Utilities

Defined in [`shellconfig/funcs.sh`](shellconfig/funcs.sh) and [`shellconfig/aliases.sh`](shellconfig/aliases.sh).

### Shell Functions
| Function | Usage | Description |
| :--- | :--- | :--- |
| `cdr` | `cdr` | Jump directly to the root directory of the current Git repository |
| `mkcd` | `mkcd <dir>` | Create a directory (including parents) and `cd` into it |
| `fbr` | `fbr` | Interactive `fzf` Git branch switcher |
| `fkill` | `fkill [signal]` | Interactive `fzf` process finder and killer |
| `whoport` | `whoport <port>` | Show which process is listening on TCP `<port>` via `lsof` |
| `certcheck` | `certcheck <host> [port]` | Inspect TLS certificate subject, issuer, SANs, and expiry dates for a host |
| `jwtdecode` | `jwtdecode <token>` | Decode and pretty-print a JWT header and payload locally using `base64` + `jq` |
| `yaml2json` | `yaml2json [file]` | Convert YAML file or stdin to formatted JSON via `yq` |
| `json2yaml` | `json2yaml [file]` | Convert JSON file or stdin to YAML via `yq` |
| `qfind` | `qfind <pattern>` | Fast file search by name (uses `fd` when available, falls back to `find`) |
| `extract` | `extract <archive>` | Universal archive extractor (`.tar.gz`, `.tar.xz`, `.tar.zst`, `.zip`, `.7z`, etc.) |
| `scppath` | `scppath <file>` | Print full `user@ip:/abs/path` string ready for `scp` |
| `weather` | `weather [city]` | Display terminal weather forecast via `wttr.in` |

---

## Ghostty & Tmux Configuration

### Ghostty ([`rc/config/ghostty/config`](rc/config/ghostty/config))
* **Font**: `MesloLGS NF` (size 13) with Nerd Font glyphs for Powerlevel10k.
* **Focus Protection**: `desktop-notifications = false` so background coding agents never interrupt deep work.
* **Split Keybindings**: `Cmd+D` (split right), `Cmd+Shift+D` (split down), `Cmd+[` / `Cmd+]` (navigate splits), `Cmd+Shift+Enter` (zoom current split).

### Tmux ([`rc/tmux.conf`](rc/tmux.conf))
* **Prefix**: `Ctrl-a` (as well as default `Ctrl-b`)
* **Split Panes (preserves current directory)**: `Prefix + |` (horizontal) and `Prefix + -` (vertical)
* **Navigate Panes**: `Alt + Arrow Keys` (no prefix required)
* **Mouse & Sync Mode**: Toggle mouse with `Prefix + m`; toggle multi-pane broadcast with `Prefix + y`
* **Reload Config**: `Prefix + r` reloads `~/.tmux.conf` live
* **Truecolor & Scrollback**: 24-bit truecolor enabled (`Tc`) with a 50,000-line history buffer

---

## Local & Machine-Specific Customization

To keep this repository clean and safe to share publicly, machine-specific or corporate settings are loaded from untracked local files:

* **`~/.zshrc.local`**: Automatically sourced at the end of `~/.zshrc` if present. Use this for private environment variables, internal aliases, or custom PATH entries.
* **`~/.gitconfig.local`**: Included at the end of `~/.gitconfig`. Run `./setup_git_user.sh` to set your `user.name` and `user.email`, or add corporate `[url]` / `[http]` / credential helper overrides here.
* **`~/.p10k.zsh`**: Customize your prompt appearance anytime by running `p10k configure`.

---

## File & Directory Structure

```
dubodots/
├── agents/              # Global agent instructions (AGENTS.md) & Claude Code settings
├── bin/                 # Helper scripts and utilities added to $PATH
├── completion/          # Shell completion scripts for Zsh & Bash (kubectx, kubens)
├── fonts/               # Monospaced Nerd Fonts (MesloLGS NF, Monaco NF, etc.)
├── rc/                  # Application runtime configs symlinked into $HOME (~/.zshrc, ~/.tmux.conf, etc.)
│   └── config/          # Sub-configurations symlinked into ~/.config/ (ghostty, jj, git, htop)
├── shellconfig/         # Shared shell configuration modules for Zsh and Bash
│   ├── agents.sh        # Agentic workflows (worktrees, jj, harness_init) & Cloud AI FDE helpers
│   ├── aliases.sh       # Cross-platform Git, cloud, network, and navigation aliases
│   ├── aliases_mac.sh   # macOS-specific aliases
│   ├── exports.sh       # PATH, environment variables, and tool bindings
│   ├── funcs.sh         # Developer & cloud utility functions
│   ├── kubernetes.sh    # Kubernetes / kubectl / fzf pod helpers and aliases
│   └── shellrc.sh       # Shared entry point for Bash/Zsh
├── Brewfile             # Core Homebrew CLI formulae for macOS
├── Brewfile-casks-store # Optional macOS GUI applications (Homebrew Casks & Mac App Store)
├── go_apps.sh           # Go developer binaries installer (go install)
├── osx_prefs.sh         # macOS user defaults and productivity tweaks
├── setup.sh             # Unified entry point script (auto-detects OS & architecture)
├── setup_agents.sh      # obra/superpowers & AI coding agent configurator
├── setup_git_user.sh    # Interactive Git identity configuration script (~/.gitconfig.local)
├── setup_links.sh       # Symlink generator for dotfiles, ~/.config, and Ghostty
├── setup_mac.sh         # macOS orchestration pipeline
├── setup_linux.sh       # Linux orchestration pipeline
├── setup_tmux.sh        # Tmux & TPM plugin setup
└── setup_zsh.sh         # Oh My Zsh, Powerlevel10k, and Zsh plugin installer
```


