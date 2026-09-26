# Console Dotfiles (`dubodots`)

A modular, cross-platform collection of dotfiles, shell scripts, and terminal configurations designed for **cloud developers and terminal power users** on macOS and Linux. Built with shell scripting best practices, user-space isolation, Apple Silicon (ARM64) and Intel compatibility, and non-destructive installation patterns.

## Features & Design Principles

* **Cloud-Native & Kubernetes Ready**: Pre-configured with `kubectl`, `kubectx` (`kx`), `kubens` (`kn`), `k9s`, `stern`, `helm`, `jq`, `yq`, and interactive `fzf`-powered pod selection (`klog`, `kexec`, `kdesc`, `kpf`, `wpod`).
* **Fast Terminal Workflow**: Includes Powerlevel10k with instant prompt, `fzf` fuzzy finding, `ripgrep` (`rg`), `fd`, `bat`, `htop`, `watch`, `direnv`, and lazy-loaded `nvm` for near-instant shell startup.
* **Cross-Platform & Architecture Aware**: Automatically resolves Homebrew paths (`/opt/homebrew` on Apple Silicon vs `/usr/local` on Intel macOS / Linux) and detects macOS vs Debian/Ubuntu/RHEL/Fedora Linux.
* **Enterprise & Managed Environment Safe**: Preserves system-provided `/bin/zsh`, `/etc/zshrc`, `/usr/local/git`, and `/usr/local/go` precedence, installs Oh My Zsh and plugins directly via `git clone` without `curl | sh` execution, and avoids storing plaintext Git credentials.
* **Local Customization Hooks**: Supports untracked `~/.zshrc.local` and `~/.gitconfig.local` files so machine-specific or work-specific settings never pollute the repository.
* **Least-Privilege & Idempotent**: Installs custom Nerd Fonts into user directories (`~/Library/Fonts` or `~/.local/share/fonts`) without requiring root access, and safely re-links dotfiles anytime via `./setup_links.sh`.
* **Touch ID for Sudo (macOS)**: Integrates Touch ID authentication using `/etc/pam.d/sudo_local` when supported by `/etc/pam.d/sudo`, preserving system compatibility across OS upgrades.

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
| `./setup.sh` | Full end-to-end setup for macOS or Linux |
| `./setup_links.sh` | Creates/updates symlinks in `~` and `~/.config/` and configures terminal fonts (iTerm2 & Ghostty) |
| `./setup_zsh.sh` | Installs/updates Oh My Zsh, Powerlevel10k, and Zsh plugins |
| `./setup_tmux.sh` | Installs/updates Tmux Plugin Manager (`tpm`) and Tmux plugins |
| `./setup_git_user.sh` | Configures your Git `user.name` and `user.email` in `~/.gitconfig.local` |
| `./go_apps.sh` | Installs Go developer utilities (`2fa`, `benchstat`, `yaegi`) via `go install` |

---

## Cloud & Kubernetes Workflow

Defined in [`shellconfig/kubernetes.sh`](shellconfig/kubernetes.sh) and [`shellconfig/aliases.sh`](shellconfig/aliases.sh).

### Context & Namespace Switching
| Alias / Command | Description |
| :--- | :--- |
| `k` | `kubectl` (with full Zsh autocompletion) |
| `kx` | `kubectx` — interactively switch Kubernetes clusters/contexts |
| `kn` | `kubens` — interactively switch Kubernetes namespaces |
| `k9` | Launch `k9s` terminal UI |
| `h` | `helm` (with full Zsh autocompletion) |

### Interactive Pod Helpers (`fzf`-Enabled)
All pod helper functions accept an optional pod name substring. **If called with no arguments, they open an interactive `fzf` selector** showing live pod status in the current namespace:

| Function | Usage | Description |
| :--- | :--- | :--- |
| `klog` | `klog [pod-query] [kubectl-logs-flags...]` | Follow logs (`-f`) for a matching or `fzf`-selected pod |
| `kexec` | `kexec [pod-query] [command...]` | Execute a command (defaults to `/bin/sh`) in a matching or `fzf`-selected pod |
| `kdesc` | `kdesc [pod-query]` | Run `kubectl describe pod` on a matching or `fzf`-selected pod |
| `kpf` | `kpf [pod-query] <local:remote>` | Port-forward `<local:remote>` (or single `<port>`) to a pod |
| `wpod` | `wpod [pod-query]` | Watch pods matching a query string every 2 seconds |

### Common `kubectl` & Cloud Aliases
| Alias | Command | Description |
| :--- | :--- | :--- |
| `kg` / `kgall` | `kubectl get` / `kubectl get all` | Inspect resources in current namespace |
| `kgp` / `kgpw` / `kgpa` | `kubectl get pods` (`-o wide`, `-A`) | List pods (standard, wide, or all namespaces) |
| `kgs` / `kgd` / `kgn` | `kubectl get svc / deploy / nodes -o wide` | Inspect services, deployments, or nodes |
| `kge` | `kubectl get events --sort-by=.lastTimestamp` | View cluster events sorted chronologically |
| `kaf` / `kdel` | `kubectl apply -f` / `kubectl delete` | Apply manifests or delete resources |
| `kroll` / `krestart` | `kubectl rollout status / restart deploy` | Track or trigger deployment rollouts |
| `ktop` / `ktopn` | `kubectl top pods` / `kubectl top nodes` | View pod and node resource consumption |
| `gadc` | `gcloud auth application-default login` | Refresh Google Cloud Application Default Credentials |
| `gproj` | `gcloud config set project` | Switch active GCP project |
| `gctx` | `gcloud config configurations list` | List `gcloud` CLI configurations |
| `tf` | `terraform` | Terraform shorthand |

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

### Navigation, Git & Network Aliases
* **Directory Navigation**: `..`, `...`, `....`, `-`, `l`, `la`, `ll`, `lt` (`tree -L 2 -C`)
* **Git**: `g` (`git`), `gst` (`git status -sb`), `gco` (`git checkout`), `gcb` (`git checkout -b`), `gd` (`git diff`), `gds` (`git diff --staged`), `glg` (`git log --oneline --graph --decorate -n 20`), `gp` (`git push`), `gpl` (`git pull --rebase`), `gundo` (`git reset --soft HEAD~1`)
* **Interactive Git (`forgit`)**: `ga` (`git add`), `gd` (interactive diff), `glo` (interactive log), `gi` (`.gitignore` generator)
* **Networking**: `ports` (list all listening TCP ports), `myip` (fetch public IP), ` flushdns` (macOS DNS cache reset)
* **JSON / YAML / Cat**: `j` (`jq`), `y` (`yq`), `cat` (`bat`)

---

## Tmux Configuration

Configured in [`rc/tmux.conf`](rc/tmux.conf) with [`rc/blue.tmuxtheme`](rc/blue.tmuxtheme) and Tmux Plugin Manager (`tpm`):

* **Prefix**: `Ctrl-a` (as well as default `Ctrl-b`)
* **Split Panes (preserves current directory)**:
  * `Prefix + |` — Split horizontally
  * `Prefix + -` — Split vertically
* **Navigate Panes**: `Alt + Arrow Keys` (no prefix required)
* **Mouse Mode**: Toggle with `Prefix + m` (`on` by default)
* **Synchronize Panes**: Toggle multi-pane broadcast input with `Prefix + y`
* **Reload Config**: `Prefix + r` reloads `~/.tmux.conf` live
* **Truecolor & Scrollback**: 24-bit truecolor enabled (`Tc`) with a 50,000-line history buffer

---

## Local & Machine-Specific Customization

To keep this repository clean and safe to share publicly, machine-specific or corporate settings are loaded from untracked local files:

* **`~/.zshrc.local`**: Automatically sourced at the end of `~/.zshrc` if present. Use this for private environment variables, internal aliases, or custom PATH entries.
* **`~/.gitconfig.local`**: Included at the end of `~/.gitconfig`. Run `./setup_git_user.sh` to set your `user.name` and `user.email`, or add corporate `[url]` / `[http]` / credential helper overrides here.
* **`~/.p10k.zsh`**: Customize your prompt appearance anytime by running `p10k configure` (writes directly to `~/.p10k.zsh` without modifying the tracked default in `rc/p10k.zsh` if replaced locally).

---

## File & Directory Structure

```
dubodots/
├── bin/                 # Helper scripts and utilities added to $PATH
├── completion/          # Shell completion scripts for Zsh & Bash (kubectx, kubens)
├── fonts/               # Monospaced Nerd Fonts (MesloLGS NF, Monaco NF, etc.)
├── rc/                  # Application runtime configs symlinked into $HOME (~/.zshrc, ~/.tmux.conf, etc.)
│   └── config/          # Sub-configurations symlinked into ~/.config/ (git, htop, iterm2)
├── shellconfig/         # Shared shell configuration modules for Zsh and Bash
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
├── setup_git_user.sh    # Interactive Git identity configuration script (~/.gitconfig.local)
├── setup_links.sh       # Symlink generator for dotfiles, ~/.config, and terminal fonts
├── setup_mac.sh         # macOS orchestration pipeline
├── setup_linux.sh       # Linux orchestration pipeline
├── setup_tmux.sh        # Tmux & TPM plugin setup
└── setup_zsh.sh         # Oh My Zsh, Powerlevel10k, and Zsh plugin installer
```

