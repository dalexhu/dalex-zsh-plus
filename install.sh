#!/usr/bin/env bash
#
# dalex-zsh-plus — zsh environment bootstrap with an interactive install menu
#
# Supports: macOS (Homebrew), Debian/Ubuntu (apt), AlmaLinux/Rocky/RHEL/CentOS/Fedora (dnf/yum)
# Always installs: zsh + oh-my-zsh. Everything else is opt-in through the menu or flags.
#
# Default selection: zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions.
#
# Usage:  ./install.sh [options]        run ./install.sh --help for details
#
# Kept bash 3.2 compatible (stock /bin/bash on macOS): no associative arrays.

set -euo pipefail

VERSION="1.2.0"

# ---------------------------------------------------------------------------
# selectable components — key | default | label | description
# ---------------------------------------------------------------------------
ITEM_KEY=(); ITEM_SEL=(); ITEM_LABEL=(); ITEM_DESC=()

add_item() {
  ITEM_KEY+=("$1"); ITEM_SEL+=("$2"); ITEM_LABEL+=("$3"); ITEM_DESC+=("$4")
}

add_item autosuggestions  1 "zsh-autosuggestions"          "suggest commands from history as you type"
add_item syntax           1 "zsh-syntax-highlighting"      "colour commands while typing (must load last)"
add_item completions      1 "zsh-completions"              "extra completion definitions"
add_item history-search   0 "zsh-history-substring-search" "up/down search history by prefix"
add_item you-should-use   0 "you-should-use"               "remind you when an alias exists"
add_item starship         0 "starship prompt"              "cross-shell prompt with a ready-made config"
add_item extras           0 "extra CLI tools"              "fzf ripgrep bat eza zoxide fd tmux vim jq tree"
add_item nvm              0 "nvm"                          "Node version manager (~/.nvm)"
add_item sdkman           0 "SDKMAN!"                      "JVM toolchain manager (~/.sdkman)"

ITEM_COUNT=${#ITEM_KEY[@]}

item_index() {  # item_index <key> -> echoes index, or returns 1
  local i=0
  while [ $i -lt $ITEM_COUNT ]; do
    if [ "${ITEM_KEY[$i]}" = "$1" ]; then
      echo $i; return 0
    fi
    i=$((i + 1))
  done
  return 1
}

set_item() {  # set_item <key> <0|1>
  local idx
  idx="$(item_index "$1")" || { echo "unknown component: $1" >&2; exit 1; }
  ITEM_SEL[$idx]="$2"
}

selected() {  # selected <key>
  local idx
  idx="$(item_index "$1")" || return 1
  [ "${ITEM_SEL[$idx]}" = "1" ]
}

set_all() {  # set_all <0|1>
  local i=0
  while [ $i -lt $ITEM_COUNT ]; do
    ITEM_SEL[$i]="$1"
    i=$((i + 1))
  done
}

# ---------------------------------------------------------------------------
# options
# ---------------------------------------------------------------------------
DO_CHSH=1
FORCE=0              # overwrite ~/.zshrc / starship.toml without asking
ASSUME_YES=0         # non-interactive: skip the menu, use current selection
SHOW_MENU=1

usage() {
  cat <<'USAGE'
dalex-zsh-plus — zsh + oh-my-zsh bootstrap with an install menu (macOS / Debian / AlmaLinux)

Usage: ./install.sh [options]

Always installed: zsh, git, oh-my-zsh (+ oh-my-zsh built-in plugins, no download).
Everything else is chosen in the interactive menu; flags below preselect it.

Components (default ON marked *):
  * autosuggestions   zsh-autosuggestions
  * syntax            zsh-syntax-highlighting
  * completions       zsh-completions
    history-search    zsh-history-substring-search
    you-should-use    you-should-use
    starship          starship prompt + a ready-made starship.toml
    extras            fzf ripgrep bat eza zoxide fd tmux vim jq tree
    nvm               Node version manager
    sdkman            SDKMAN!

Selection flags:
  --with <a,b,...>    Turn components on   (e.g. --with starship,extras)
  --without <a,b,...> Turn components off  (e.g. --without completions)
  --all               Select every component
  --none              Deselect every component
  --defaults          Reset to the default selection

Other options:
  --no-menu        Skip the interactive menu, use the current selection
  --no-chsh        Do not change the login shell to zsh
  --force          Overwrite ~/.zshrc and starship.toml (a timestamped backup is kept)
  -y, --yes        Non-interactive: skip the menu and every prompt
  -h, --help       Show this help
  --version        Show version

Examples:
  ./install.sh                              # menu, 3 plugins preselected
  ./install.sh -y                           # unattended, default 3 plugins
  ./install.sh --all -y                     # unattended, everything
  ./install.sh --with starship,extras -y    # unattended, plugins + prompt + CLI tools

The script is idempotent: re-running updates oh-my-zsh and its plugins, and rewrites
~/.zshrc only when its content actually changes (with a backup).
USAGE
}

apply_list() {  # apply_list <0|1> <comma/space separated keys>
  local value="$1" list="$2" k
  list="$(echo "$list" | tr ',' ' ')"
  for k in $list; do
    set_item "$k" "$value"
  done
}

while [ $# -gt 0 ]; do
  case "$1" in
    --with)        [ $# -ge 2 ] || { echo "--with needs a value" >&2; exit 1; }; apply_list 1 "$2"; shift ;;
    --with=*)      apply_list 1 "${1#*=}" ;;
    --without)     [ $# -ge 2 ] || { echo "--without needs a value" >&2; exit 1; }; apply_list 0 "$2"; shift ;;
    --without=*)   apply_list 0 "${1#*=}" ;;
    --all)         set_all 1 ;;
    --none)        set_all 0 ;;
    --defaults)    : ;;  # selection already holds the defaults
    # backwards-compatible aliases from v1.0.0
    --with-nvm)    set_item nvm 1 ;;
    --with-sdkman) set_item sdkman 1 ;;
    --with-starship) set_item starship 1 ;;
    --no-starship) set_item starship 0 ;;
    --with-extras) set_item extras 1 ;;
    --no-extras)   set_item extras 0 ;;
    --no-menu)     SHOW_MENU=0 ;;
    --no-chsh)     DO_CHSH=0 ;;
    --force)       FORCE=1 ;;
    -y|--yes)      ASSUME_YES=1; SHOW_MENU=0 ;;
    -h|--help)     usage; exit 0 ;;
    --version)     echo "dalex-zsh-plus $VERSION"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

# ---------------------------------------------------------------------------
# logging
# ---------------------------------------------------------------------------
if [ -t 1 ]; then
  C_RESET='\033[0m'; C_INFO='\033[1;34m'; C_OK='\033[1;32m'
  C_WARN='\033[1;33m'; C_ERR='\033[1;31m'; C_STEP='\033[1;36m'; C_DIM='\033[2m'
else
  C_RESET=''; C_INFO=''; C_OK=''; C_WARN=''; C_ERR=''; C_STEP=''; C_DIM=''
fi

log()  { printf "${C_INFO}==>${C_RESET} %s\n" "$*"; }
step() { printf "\n${C_STEP}### %s${C_RESET}\n" "$*"; }
ok()   { printf "${C_OK} ok ${C_RESET} %s\n" "$*"; }
warn() { printf "${C_WARN}warn${C_RESET} %s\n" "$*"; }
die()  { printf "${C_ERR}fail${C_RESET} %s\n" "$*" >&2; exit 1; }

confirm() {
  [ "$ASSUME_YES" -eq 1 ] && return 0
  [ -t 0 ] || return 1
  printf "%s [y/N] " "$1"
  read -r reply
  case "$reply" in [yY]*) return 0 ;; *) return 1 ;; esac
}

has() { command -v "$1" >/dev/null 2>&1; }

# content comparison without cmp/diff — minimal images ship neither
files_equal() {
  [ -f "$1" ] && [ -f "$2" ] && [ "$(cat "$1")" = "$(cat "$2")" ]
}

# ---------------------------------------------------------------------------
# interactive menu
# ---------------------------------------------------------------------------
print_menu() {
  local i=0 mark
  printf "\n${C_STEP}### Select what to install${C_RESET}\n"
  printf "${C_DIM}    always installed: zsh, git, oh-my-zsh + built-in plugins${C_RESET}\n\n"
  while [ $i -lt $ITEM_COUNT ]; do
    if [ "${ITEM_SEL[$i]}" = "1" ]; then mark="x"; else mark=" "; fi
    printf "  %2d) [%s] %-30s ${C_DIM}%s${C_RESET}\n" \
      $((i + 1)) "$mark" "${ITEM_LABEL[$i]}" "${ITEM_DESC[$i]}"
    i=$((i + 1))
  done
  printf "\n${C_DIM}  numbers toggle (e.g. \"4 6 7\")   a=all   n=none   d=defaults   q=quit${C_RESET}\n"
}

run_menu() {
  [ "$SHOW_MENU" -eq 1 ] || return 0
  if [ ! -t 0 ]; then
    warn "not a terminal; using the current selection"
    return 0
  fi
  local input tok idx
  while :; do
    print_menu
    printf "\nEnter to install, or toggle: "
    read -r input || input=""
    case "$input" in
      "")   return 0 ;;
      q|Q)  echo "aborted"; exit 0 ;;
      a|A)  set_all 1 ;;
      n|N)  set_all 0 ;;
      d|D)  set_all 0; set_item autosuggestions 1; set_item syntax 1; set_item completions 1 ;;
      *)
        for tok in $input; do
          case "$tok" in
            ''|*[!0-9]*) warn "ignored: $tok"; continue ;;
          esac
          idx=$((tok - 1))
          if [ $idx -lt 0 ] || [ $idx -ge $ITEM_COUNT ]; then
            warn "out of range: $tok"
            continue
          fi
          if [ "${ITEM_SEL[$idx]}" = "1" ]; then ITEM_SEL[$idx]=0; else ITEM_SEL[$idx]=1; fi
        done ;;
    esac
  done
}

print_plan() {
  local i=0 chosen=""
  while [ $i -lt $ITEM_COUNT ]; do
    if [ "${ITEM_SEL[$i]}" = "1" ]; then chosen="$chosen ${ITEM_LABEL[$i]},"; fi
    i=$((i + 1))
  done
  chosen="${chosen%,}"
  if [ -n "$chosen" ]; then
    log "selected:$chosen"
  else
    log "selected: nothing beyond zsh + oh-my-zsh"
  fi
}

# ---------------------------------------------------------------------------
# platform detection
# ---------------------------------------------------------------------------
OS=""          # macos | debian | rhel
PKG=""         # brew | apt | dnf | yum | none
SUDO=""
ZSH_DIR=""
ZSH_CUSTOM_DIR=""
ZSHRC_PREEXISTED=0   # set in main() before anything can create ~/.zshrc
ZSHRC_SKIPPED=0      # set when an unmanaged ~/.zshrc was left alone

detect_platform() {
  case "$(uname -s)" in
    Darwin)
      OS="macos"; PKG="brew"
      ;;
    Linux)
      [ -r /etc/os-release ] || die "cannot read /etc/os-release; unsupported Linux"
      # shellcheck disable=SC1091
      . /etc/os-release
      case " ${ID:-} ${ID_LIKE:-} " in
        *debian*|*ubuntu*) OS="debian"; PKG="apt" ;;
        *rhel*|*fedora*|*centos*|*almalinux*|*rocky*) OS="rhel" ;;
        *) die "unsupported distribution: ${ID:-unknown}" ;;
      esac
      if [ "$OS" = "rhel" ]; then
        if has dnf; then PKG="dnf"; elif has yum; then PKG="yum"; else die "neither dnf nor yum found"; fi
      fi
      ;;
    *) die "unsupported OS: $(uname -s)" ;;
  esac

  if [ "$(id -u)" -ne 0 ] && [ "$OS" != "macos" ]; then
    has sudo || die "sudo is required (or run as root)"
    SUDO="sudo"
  fi
  ok "platform: $OS (package manager: $PKG)"
}

pkg_refresh() {
  case "$PKG" in
    apt)  $SUDO apt-get update -qq || true ;;
    brew) brew update >/dev/null 2>&1 || true ;;
    *)    : ;;
  esac
}

# install packages one by one, tolerating names missing from the repo
pkg_install() {
  local p
  for p in "$@"; do
    case "$PKG" in
      apt)  if DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y -qq "$p" >/dev/null 2>&1; then
              ok "installed $p"; else warn "skipped $p (not available)"; fi ;;
      dnf)  if $SUDO dnf install -y "$p" >/dev/null 2>&1; then
              ok "installed $p"; else warn "skipped $p (not available)"; fi ;;
      yum)  if $SUDO yum install -y "$p" >/dev/null 2>&1; then
              ok "installed $p"; else warn "skipped $p (not available)"; fi ;;
      brew) if brew list --formula "$p" >/dev/null 2>&1; then
              ok "$p already installed"
            elif brew install "$p" >/dev/null 2>&1; then
              ok "installed $p"
            else
              warn "skipped $p (not available)"
            fi ;;
      *)    warn "no package manager; skipped $p" ;;
    esac
  done
}

# ---------------------------------------------------------------------------
# steps
# ---------------------------------------------------------------------------
ensure_homebrew() {
  [ "$OS" = "macos" ] || return 0
  # Homebrew is usually installed but not yet on PATH here (ssh, curl | bash, or a
  # ~/.zprofile without shellenv), so look in its standard prefixes before giving up.
  local p
  if ! has brew; then
    for p in /opt/homebrew/bin/brew /usr/local/bin/brew; do
      if [ -x "$p" ]; then
        eval "$("$p" shellenv)"
        break
      fi
    done
  fi
  if has brew; then
    ok "homebrew present: $(command -v brew)"
    return 0
  fi
  warn "Homebrew is not installed."
  if confirm "Install Homebrew now? (requires your password)"; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/brew/HEAD/install.sh)"
    local p
    for p in /opt/homebrew/bin/brew /usr/local/bin/brew; do
      if [ -x "$p" ]; then
        eval "$("$p" shellenv)"
      fi
    done
    has brew || die "Homebrew installation did not complete"
  else
    warn "continuing without Homebrew; package installation will be skipped"
    PKG="none"
  fi
}

install_base_packages() {
  step "Base packages"
  if [ "$PKG" = "none" ]; then
    warn "no package manager available; skipping"
  else
    pkg_refresh
    case "$OS" in
      macos)  # macOS ships both; only pull them from brew when actually missing
              has zsh || pkg_install zsh
              git --version >/dev/null 2>&1 || pkg_install git ;;
      debian) pkg_install zsh git curl wget ca-certificates procps file ;;
      rhel)   pkg_install zsh
              # RHEL ships curl-minimal / wget2; only pull the full package when missing,
              # otherwise dnf aborts the whole transaction on the conflict.
              if ! has curl; then pkg_install curl; fi
              if ! has wget; then pkg_install wget; fi
              # git-core is the lean git package on the RHEL family
              if ! has git; then pkg_install git-core; fi
              if ! has git; then pkg_install git; fi ;;
    esac
  fi
  has zsh || die "zsh is not installed and could not be installed automatically"
  has git || die "git is not installed and could not be installed automatically"
  ok "zsh: $(zsh --version)"
}

install_extra_tools() {
  selected extras || return 0
  step "Extra CLI tools (optional, failures are non-fatal)"
  if [ "$PKG" = "none" ]; then
    warn "no package manager available; skipping"
    return 0
  fi
  case "$OS" in
    macos)  pkg_install fzf ripgrep bat eza zoxide fd tmux vim jq tree ;;
    debian) pkg_install fzf ripgrep bat eza zoxide fd-find tmux vim jq tree ;;
    rhel)
      # fzf / ripgrep / bat / zoxide / fd live in EPEL, not in the RHEL base repos
      if ! $SUDO "$PKG" repolist enabled 2>/dev/null | grep -qi '^epel'; then
        pkg_install epel-release
      fi
      pkg_install fzf ripgrep bat eza zoxide fd-find tmux vim-enhanced jq tree
      ;;
  esac
}

install_oh_my_zsh() {
  step "oh-my-zsh"
  ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
  if [ -d "$ZSH_DIR/.git" ]; then
    ok "oh-my-zsh already present, updating"
    git -C "$ZSH_DIR" pull --ff-only --quiet || warn "oh-my-zsh update failed (keeping current copy)"
  elif [ -d "$ZSH_DIR" ]; then
    warn "$ZSH_DIR exists but is not a git checkout; leaving it alone"
  else
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
      || die "oh-my-zsh installation failed"
    ok "oh-my-zsh installed at $ZSH_DIR"
  fi
  ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$ZSH_DIR/custom}"
  mkdir -p "$ZSH_CUSTOM_DIR/plugins" "$ZSH_CUSTOM_DIR/themes"
}

# clone_plugin <name> <repo-url>
clone_plugin() {
  local name="$1" url="$2" dest="$ZSH_CUSTOM_DIR/plugins/$1"
  if [ -d "$dest/.git" ]; then
    if git -C "$dest" pull --ff-only --quiet 2>/dev/null; then ok "updated $name"; else warn "could not update $name"; fi
  elif [ -d "$dest" ]; then
    warn "$dest exists but is not a git checkout; skipping"
  elif git clone --depth=1 --quiet "$url" "$dest"; then
    ok "installed $name"
  else
    warn "failed to clone $name"
  fi
}

install_zsh_plugins() {
  if ! selected autosuggestions && ! selected syntax && ! selected completions \
     && ! selected history-search && ! selected you-should-use; then
    return 0
  fi
  step "oh-my-zsh custom plugins"
  if selected autosuggestions; then
    clone_plugin zsh-autosuggestions          https://github.com/zsh-users/zsh-autosuggestions.git
  fi
  if selected syntax; then
    clone_plugin zsh-syntax-highlighting      https://github.com/zsh-users/zsh-syntax-highlighting.git
  fi
  if selected completions; then
    clone_plugin zsh-completions              https://github.com/zsh-users/zsh-completions.git
  fi
  if selected history-search; then
    clone_plugin zsh-history-substring-search https://github.com/zsh-users/zsh-history-substring-search.git
  fi
  if selected you-should-use; then
    clone_plugin you-should-use               https://github.com/MichaelAquilina/zsh-you-should-use.git
  fi
}

install_starship() {
  selected starship || return 0
  step "starship prompt"
  if has starship; then
    ok "starship already installed: $(starship --version | head -1)"
  elif [ "$OS" = "macos" ]; then
    pkg_install starship
    if ! has starship; then
      warn "starship install failed; keeping the oh-my-zsh theme"
      set_item starship 0
      return 0
    fi
  else
    if curl -fsSL https://starship.rs/install.sh | $SUDO sh -s -- --yes >/dev/null 2>&1; then
      ok "starship installed to /usr/local/bin"
    else
      warn "starship install failed; keeping the oh-my-zsh theme"
      set_item starship 0
      return 0
    fi
  fi

  local cfg="$HOME/.config/starship.toml"
  mkdir -p "$HOME/.config"
  if [ -f "$cfg" ] && [ "$FORCE" -eq 0 ]; then
    ok "keeping existing $cfg (use --force to replace)"
    return 0
  fi
  local tmp="$cfg.dalex.tmp.$$"
  write_starship_config "$tmp"
  if files_equal "$cfg" "$tmp"; then
    rm -f "$tmp"
    ok "$cfg already up to date"
    return 0
  fi
  if [ -f "$cfg" ]; then
    cp "$cfg" "$cfg.bak.$(date +%Y%m%d%H%M%S)"
  fi
  mv "$tmp" "$cfg"
  ok "wrote $cfg"
}

install_nvm() {
  selected nvm || return 0
  step "nvm"
  if [ -s "$HOME/.nvm/nvm.sh" ]; then
    ok "nvm already installed"
    return 0
  fi
  if PROFILE=/dev/null bash -c "curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash" >/dev/null 2>&1; then
    ok "nvm installed (~/.nvm)"
  else
    warn "nvm installation failed"
  fi
}

install_sdkman() {
  selected sdkman || return 0
  step "SDKMAN!"
  if [ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    ok "SDKMAN! already installed"
    return 0
  fi
  # the SDKMAN! installer aborts without zip/unzip, which minimal images lack
  if ! has unzip || ! has zip; then
    pkg_install zip unzip
  fi
  if ! has unzip; then
    warn "SDKMAN! needs unzip; install it and re-run with --with sdkman"
    return 0
  fi
  if curl -fsSL "https://get.sdkman.io?rcupdate=false" | bash >/dev/null 2>&1; then
    ok "SDKMAN! installed (~/.sdkman)"
  else
    warn "SDKMAN! installation failed"
  fi
}

write_zshrc() {
  step "~/.zshrc"
  local rc="$HOME/.zshrc"
  # Anything created during this run (e.g. the oh-my-zsh template) is ours to replace.
  if [ -f "$rc" ] && [ "$FORCE" -eq 0 ] && [ "$ZSHRC_PREEXISTED" -eq 1 ] \
     && ! grep -q 'dalex-zsh-plus' "$rc" 2>/dev/null; then
    warn "existing ~/.zshrc was not written by dalex-zsh-plus"
    local replace=0
    if [ "$ASSUME_YES" -eq 0 ] && [ -t 0 ]; then
      printf "     Replace it? A timestamped backup is kept; put your own lines in ~/.zshrc.local. [y/N] "
      local reply; read -r reply
      case "$reply" in [yY]*) replace=1 ;; esac
    fi
    if [ "$replace" -eq 0 ]; then
      warn "leaving ~/.zshrc untouched; the selected plugins are installed but NOT enabled (re-run with --force)"
      ZSHRC_SKIPPED=1
      return 0
    fi
  fi
  local tmp="$rc.dalex.tmp.$$"
  write_zshrc_content "$tmp"
  if [ -f "$rc" ] && files_equal "$rc" "$tmp"; then
    rm -f "$tmp"
    ok "~/.zshrc already up to date"
    return 0
  fi
  if [ -f "$rc" ]; then
    cp "$rc" "$rc.bak.$(date +%Y%m%d%H%M%S)"
    ok "backed up existing ~/.zshrc"
  fi
  mv "$tmp" "$rc"
  ok "wrote $rc"
}

set_default_shell() {
  [ "$DO_CHSH" -eq 1 ] || return 0
  step "Default shell"
  local zsh_path sudo_cmd="$SUDO"
  zsh_path="$(command -v zsh)"
  case "${SHELL:-}" in
    */zsh) ok "login shell is already zsh"; return 0 ;;
  esac
  # Prefer a zsh that /etc/shells already lists (on macOS that is /bin/zsh, not the
  # Homebrew one) so chsh does not need root at all.
  if ! grep -qx "$zsh_path" /etc/shells 2>/dev/null && [ -x /bin/zsh ] && grep -qx /bin/zsh /etc/shells 2>/dev/null; then
    zsh_path=/bin/zsh
  fi
  if ! grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
    [ -z "$sudo_cmd" ] && [ "$(id -u)" -ne 0 ] && has sudo && sudo_cmd="sudo"
    echo "$zsh_path" | $sudo_cmd tee -a /etc/shells >/dev/null 2>&1 || warn "could not register $zsh_path in /etc/shells"
  fi
  if chsh -s "$zsh_path" >/dev/null 2>&1; then
    ok "login shell set to $zsh_path (takes effect on next login)"
  elif [ -n "$SUDO" ] && $SUDO chsh -s "$zsh_path" "$(id -un)" >/dev/null 2>&1; then
    ok "login shell set to $zsh_path (takes effect on next login)"
  else
    warn "could not change the login shell; run manually: chsh -s $zsh_path"
  fi
}

# ---------------------------------------------------------------------------
# generated file contents
# ---------------------------------------------------------------------------

# oh-my-zsh plugin list for the generated ~/.zshrc: built-ins first, then the
# selected custom plugins, with zsh-syntax-highlighting always last.
zshrc_plugin_list() {
  echo git
  echo sudo
  echo extract
  echo history
  echo colored-man-pages
  echo command-not-found
  echo docker
  echo docker-compose
  selected autosuggestions && echo zsh-autosuggestions
  selected history-search  && echo zsh-history-substring-search
  selected you-should-use  && echo you-should-use
  selected syntax          && echo zsh-syntax-highlighting
  return 0
}

write_zshrc_content() {
  local out="$1" p
  cat > "$out" <<'ZSHRC_HEAD'
# ===========================================================================
# Managed by dalex-zsh-plus — regenerate with: ./install.sh --force
# Put your own tweaks in ~/.zshrc.local (sourced near the end of this file).
# ===========================================================================

export ZSH="$HOME/.oh-my-zsh"

# Prompt: starship takes over when installed, otherwise this theme is used.
ZSH_THEME="robbyrussell"

# --- plugins ---------------------------------------------------------------
# zsh-syntax-highlighting must stay last.
ZSHRC_HEAD

  {
    echo "plugins=("
    zshrc_plugin_list | while IFS= read -r p; do
      echo "  $p"
    done
    echo ")"
  } >> "$out"

  cat >> "$out" <<'ZSHRC_TAIL'

# Drop plugins whose directory is missing so a partial install still starts.
_dz_plugins=()
for _dz_p in $plugins; do
  if [[ -d "$ZSH/plugins/$_dz_p" || -d "${ZSH_CUSTOM:-$ZSH/custom}/plugins/$_dz_p" ]]; then
    _dz_plugins+=("$_dz_p")
  fi
done
plugins=($_dz_plugins)
unset _dz_plugins _dz_p

# zsh-completions has to be on fpath before compinit runs, and oh-my-zsh runs
# compinit before it loads plugins — so it goes here, not in the plugins list.
_dz_comp="${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-completions/src"
[[ -d "$_dz_comp" ]] && fpath+=("$_dz_comp")
unset _dz_comp

source $ZSH/oh-my-zsh.sh

# --- history ---------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS
setopt SHARE_HISTORY INC_APPEND_HISTORY EXTENDED_HISTORY

# --- key bindings ----------------------------------------------------------
if [[ -n ${functions[history-substring-search-up]} ]]; then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# --- environment -----------------------------------------------------------
export LANG=${LANG:-en_US.UTF-8}
export EDITOR=${EDITOR:-vim}
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# Homebrew is not on the default PATH on Apple silicon (or Linuxbrew); put it there
# before anything below probes for eza, zoxide, starship, fzf.
for _dz_brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  if [[ -x $_dz_brew ]]; then eval "$($_dz_brew shellenv)"; break; fi
done
unset _dz_brew

# --- aliases ---------------------------------------------------------------
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias zshconfig='${EDITOR} ~/.zshrc'
alias zshreload='source ~/.zshrc'

command -v eza    >/dev/null 2>&1 && alias ll='eza -alh --group-directories-first'
command -v batcat >/dev/null 2>&1 && alias bat='batcat'          # Debian package name
command -v fdfind >/dev/null 2>&1 && alias fd='fdfind'           # Debian package name

# --- prompt ----------------------------------------------------------------
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# --- extra tools -----------------------------------------------------------
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f /usr/share/fzf/shell/key-bindings.zsh ] && source /usr/share/fzf/shell/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh

# --- version managers ------------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# --- local overrides -------------------------------------------------------
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
ZSHRC_TAIL
}

write_starship_config() {
  cat > "$1" <<'STARSHIP_EOF'
# Starship configuration for full-stack development environment

"$schema" = 'https://starship.rs/config-schema.json'
add_newline = true

[character]
success_symbol = '[➜](bold green)'
error_symbol = '[✗](bold red)'
vicmd_symbol = '[V](bold blue)'

[package]
disabled = true

[git_status]
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
untracked = "?"
stashed = "≡"
modified = "!"
staged = "+"
renamed = "»"
deleted = "✘"
style = "bold red"

[git_branch]
symbol = " "
style = "bold purple"
format = "on [$symbol$branch]($style) "
only_attached = false
ignore_branches = []

[directory]
truncation_length = 3
truncation_symbol = "…/"
style = "bold blue"
format = "[$path]($style)[$read_only]($read_only_style) "

[hostname]
ssh_only = true
format = "on [$hostname](bold red) "
disabled = false

[username]
style_user = "bold yellow"
style_root = "bold red"
format = "[$user]($style) "
show_always = false

[cmd_duration]
min_time = 2000
format = "took [$duration](bold yellow) "
style = "bold yellow"

[line_break]
disabled = false

[java]
symbol = "☕ "
style = "red dimmed"
format = "via [$symbol($version)]($style) "
disabled = false

[nodejs]
symbol = "⬢ "
style = "bold green"
format = "via [$symbol($version)]($style) "
disabled = false
not_capable_style = "bold red"

[python]
symbol = "🐍 "
style = "bold yellow"
format = "via [$symbol$pyenv_prefix($version)]($style) "
pyenv_version_name = true
pyenv_prefix = "pyenv "
python_binary = ["python", "python3", "python2"]
disabled = false

[rust]
symbol = "⚙️ "
style = "bold red"
format = "via [$symbol($version)]($style) "
disabled = false

[golang]
symbol = "🐹 "
style = "bold cyan"
format = "via [$symbol($version)]($style) "
disabled = false

[docker_context]
symbol = "🐳 "
style = "bold blue"
format = "via [$symbol$context]($style) "
only_with_files = true
disabled = false

[kubernetes]
symbol = "☸ "
style = "bold blue"
format = "on [$symbol$context( ($namespace))]($style) "
disabled = false

[aws]
symbol = "☁️ "
style = "bold yellow"
format = "on [$symbol$profile(($region))]($style) "
disabled = false

[terraform]
symbol = "💠"
style = "bold blue"
format = "via [$symbol$workspace]($style) "
disabled = false

[nix_shell]
symbol = "❄️ "
style = "bold blue"
format = "via [$symbol$state( ($name))]($style) "
disabled = false

[conda]
symbol = "🅒 "
style = "bold green"
format = "via [$symbol$environment]($style) "
ignore_base = false
disabled = false

[memory_usage]
symbol = " "
style = "bold white"
format = "via $symbol[${ram_pct}]($style) "
threshold = 75
disabled = false

[time]
disabled = false
format = '🕙[\[ $time \]]($style) '
time_format = "%T"
style = "bold white"
STARSHIP_EOF
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
main() {
  printf "${C_STEP}dalex-zsh-plus %s${C_RESET}\n" "$VERSION"
  if [ -f "$HOME/.zshrc" ]; then
    ZSHRC_PREEXISTED=1
  fi

  run_menu
  print_plan

  detect_platform
  ensure_homebrew
  has curl || die "curl is required but not installed"

  install_base_packages
  install_extra_tools
  install_oh_my_zsh
  install_zsh_plugins
  install_starship
  install_nvm
  install_sdkman
  write_zshrc
  set_default_shell

  step "Done"
  if [ "$ZSHRC_SKIPPED" -eq 1 ]; then
    warn "~/.zshrc was NOT updated, so nothing selected above is active in your shell."
    warn "re-run with --force to let dalex-zsh-plus manage ~/.zshrc (your file is backed up first)"
    exit 1
  fi
  ok "start a new shell, or run: exec zsh"
  if selected starship; then
    log "starship needs a Nerd Font in your terminal for the icons to render"
  fi
}

main "$@"
