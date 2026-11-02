# dotfiles

Personal macOS dev environment: zsh, neovim, tmux, alacritty, git.

## Layout

| Path | Symlinked to | Notes |
|---|---|---|
| `zsh/.zshrc` | `~/.zshrc` | Defensive — every PATH/source is guarded by `_have`/`_path_*` helpers so missing tools don't break the shell |
| `zsh/.zshenv`, `.zprofile`, `.p10k.zsh` | `~/.<file>` | |
| `git/hooks/pre-commit` | `core.hooksPath` of this repo | Refuses commits that look like keys (this repo is public) |
| `nvim/` | `~/.config/nvim` | Lua config, lazy.nvim |
| `alacritty/` | `~/.config/alacritty` | |
| `tmux/tmux.conf` | `~/.tmux.conf` | TPM-managed plugins |
| `git/.gitconfig` | `~/.gitconfig` | Uses `includeIf` for per-workspace overrides |
| `Brewfile` | — | Source of truth for installed CLI tools |
| `install.sh` | — | Idempotent bootstrap: brew → symlinks → TPM → fnm → bun → lazy.nvim sync |
| `doctor.sh` | — | Verifies install state; non-zero exit if anything missing |

## Conventions

- **Bootstrap is idempotent.** `install.sh` backs up existing files to `~/.dotfiles-backup-<ts>/` before symlinking, and skips work that's already done.
- **`.zshrc` must stay defensive.** New tools/plugins must be wrapped in existence checks (`_have foo && ...` or `[[ -d ... ]] && ...`) so the file is usable on a fresh machine without everything installed yet.
- **Heavy/optional installs are opt-in.** See `ask_yn` in `install.sh` (currently used for `openjdk@17`).
- **No secrets. This repo is public.** Credentials go through `osxkeychain` / `gh auth`, or live outside the repo with `chmod 600`: personal API keys in `~/.config/secrets.env` (sourced by `.zshrc`), per-project ones in `~/.config/<client>/<project>.env`, loaded on `cd` into the project and unset on leaving it (`_PROJECT_ENVS` map in `.zshrc`). `install.sh` lists the ones missing on a new machine and `doctor.sh` checks existence and mode, never content. The pre-commit hook blocks anything that looks like a key.

## Common tasks

- After editing `install.sh` or shell config: run `./doctor.sh` to confirm nothing regressed.
- Adding a CLI tool: add to `Brewfile`, add a `check_bin` line in `doctor.sh`.
- Adding a new symlink: add a `backup_and_link` call in `install.sh` and a matching `check_symlink` in `doctor.sh`.

## Out of scope

- Linux support (`install.sh` exits early on non-Darwin).
- Work-specific `.gitconfig` blocks live in `~/Documents/<workspace>/.gitconfig`, loaded via `includeIf` — not tracked here.
