# dalex-zsh-plus

**A single-file zsh bootstrap for macOS, Debian/Ubuntu and AlmaLinux/Rocky/RHEL — with an interactive install menu.**

[English](#english) · [中文](#中文)

---

## English

`install.sh` sets up zsh + [oh-my-zsh](https://ohmyz.sh) and lets you pick exactly which
extras you want from a checkbox menu. Nothing heavy is installed unless you tick it.

Always installed: **zsh**, **git**, **oh-my-zsh** (plus its built-in plugins, which need no download).

| # | Component | Default |
|---|-----------|---------|
| 1 | `zsh-autosuggestions` — suggest commands from history as you type | **on** |
| 2 | `zsh-syntax-highlighting` — colour commands while typing | **on** |
| 3 | `zsh-completions` — extra completion definitions | **on** |
| 4 | `zsh-history-substring-search` — up/down search history by prefix | off |
| 5 | `you-should-use` — remind you when an alias exists | off |
| 6 | `starship` prompt + a ready-made `starship.toml` | off |
| 7 | Extra CLI tools — fzf, ripgrep, bat, eza, zoxide, fd, tmux, vim, jq, tree | off |
| 8 | `nvm` — Node version manager | off |
| 9 | `SDKMAN!` — JVM toolchain manager | off |

### Quick install

Interactive menu (recommended — `bash -c "$(curl …)"` keeps your terminal on stdin):

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dalexhu/dalex-zsh-plus/main/install.sh)"
```

Unattended, default selection (the three plugins above):

```bash
curl -fsSL https://raw.githubusercontent.com/dalexhu/dalex-zsh-plus/main/install.sh | bash -s -- --yes
```

Unattended, everything:

```bash
curl -fsSL https://raw.githubusercontent.com/dalexhu/dalex-zsh-plus/main/install.sh | bash -s -- --all --yes
```

Unattended, plugins + starship prompt + CLI tools:

```bash
curl -fsSL https://raw.githubusercontent.com/dalexhu/dalex-zsh-plus/main/install.sh | bash -s -- --with starship,extras --yes
```

`wget` instead of `curl`:

```bash
wget -qO- https://raw.githubusercontent.com/dalexhu/dalex-zsh-plus/main/install.sh | bash -s -- --yes
```

Prefer to read before you run (always a good idea for `curl | bash`):

```bash
curl -fsSLO https://raw.githubusercontent.com/dalexhu/dalex-zsh-plus/main/install.sh && less install.sh && bash install.sh
```

### Options

```
--with <a,b,...>     Turn components on   (keys: autosuggestions, syntax, completions,
                     history-search, you-should-use, starship, extras, nvm, sdkman)
--without <a,b,...>  Turn components off
--all                Select everything
--none               Select nothing beyond zsh + oh-my-zsh
--no-menu            Skip the menu, use the current selection
--no-chsh            Do not change the login shell to zsh
--force              Overwrite ~/.zshrc and starship.toml (a timestamped backup is kept)
-y, --yes            Non-interactive: skip the menu and every prompt
-h, --help           Full help
```

### What you get in `~/.zshrc`

- A generated, clearly marked config — your own tweaks go in `~/.zshrc.local`, which is
  sourced at the end and survives every re-run.
- The plugin list matches exactly what you selected, with `zsh-syntax-highlighting` last.
- Missing plugin directories are filtered out at startup, so a partial install still opens a shell.
- 50 000 lines of shared, de-duplicated history; prefix search on ↑/↓.
- Debian aliases fixed up automatically (`bat`→`batcat`, `fd`→`fdfind`).

### Behaviour

- **Idempotent.** Re-running updates oh-my-zsh and its plugins via `git pull`, and rewrites
  `~/.zshrc` only when the content actually changes.
- **Never clobbers silently.** Anything it overwrites is backed up as `*.bak.YYYYMMDDHHMMSS`.
  An existing `~/.zshrc` that this script did not write is left untouched unless you pass `--force`.
- **Distro aware.** Packages missing from a repo are skipped with a warning instead of aborting;
  RHEL-family hosts get EPEL enabled first, and `curl`/`wget` are only installed when absent
  (so `curl-minimal` conflicts can't break the transaction).
- **Non-root friendly.** Uses `sudo` when needed; on macOS it offers to install Homebrew and
  carries on without it if you decline.

Verified on Ubuntu 22.04 / 24.04 / 26.04, Debian 12 / 13, AlmaLinux 9 / 10 and
macOS 15 (Apple silicon). Requires `bash` 3.2+, `curl`, and network access to github.com.

`eza` only exists in the repos of Ubuntu 24.04+ / Debian 13+; on older releases it is
skipped with a warning and `ll` falls back to plain `ls`.

> Tip: starship's icons need a [Nerd Font](https://www.nerdfonts.com) in your terminal.

---

## 中文

`install.sh` 一键搭好 zsh + [oh-my-zsh](https://ohmyz.sh),并用一个复选菜单让你自己勾选要装什么。
不勾就不装,不会默认塞一堆东西。

固定安装:**zsh**、**git**、**oh-my-zsh**(以及无需下载的内置插件)。

| 序号 | 组件 | 默认 |
|---|------|------|
| 1 | `zsh-autosuggestions` —— 根据历史自动补全建议 | **选中** |
| 2 | `zsh-syntax-highlighting` —— 命令语法高亮 | **选中** |
| 3 | `zsh-completions` —— 额外补全定义 | **选中** |
| 4 | `zsh-history-substring-search` —— 上下键按前缀搜索历史 | 不选 |
| 5 | `you-should-use` —— 提醒你已有 alias 可用 | 不选 |
| 6 | `starship` 提示符 + 现成的 `starship.toml` | 不选 |
| 7 | 常用 CLI 工具 —— fzf、ripgrep、bat、eza、zoxide、fd、tmux、vim、jq、tree | 不选 |
| 8 | `nvm` —— Node 版本管理器 | 不选 |
| 9 | `SDKMAN!` —— JVM 工具链管理器 | 不选 |

### 一行命令安装

交互菜单(推荐;`bash -c "$(curl …)"` 写法能保住终端标准输入,菜单才能用):

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dalexhu/dalex-zsh-plus/main/install.sh)"
```

全自动,默认选中的三个插件:

```bash
curl -fsSL https://raw.githubusercontent.com/dalexhu/dalex-zsh-plus/main/install.sh | bash -s -- --yes
```

全自动,全都要:

```bash
curl -fsSL https://raw.githubusercontent.com/dalexhu/dalex-zsh-plus/main/install.sh | bash -s -- --all --yes
```

全自动,插件 + starship 提示符 + CLI 工具:

```bash
curl -fsSL https://raw.githubusercontent.com/dalexhu/dalex-zsh-plus/main/install.sh | bash -s -- --with starship,extras --yes
```

用 `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/dalexhu/dalex-zsh-plus/main/install.sh | bash -s -- --yes
```

先看再跑(`curl | bash` 前的好习惯):

```bash
curl -fsSLO https://raw.githubusercontent.com/dalexhu/dalex-zsh-plus/main/install.sh && less install.sh && bash install.sh
```

### 选项

```
--with <a,b,...>     打开组件(键名:autosuggestions、syntax、completions、
                     history-search、you-should-use、starship、extras、nvm、sdkman)
--without <a,b,...>  关闭组件
--all                全选
--none               只装 zsh + oh-my-zsh
--no-menu            跳过菜单,直接用当前选择
--no-chsh            不修改登录 shell
--force              覆盖 ~/.zshrc 和 starship.toml(仍会留时间戳备份)
-y, --yes            非交互,跳过菜单和所有确认
-h, --help           完整帮助
```

### 生成的 `~/.zshrc`

- 顶部有明确标记;个人配置写进 `~/.zshrc.local`,末尾自动 source,重装不丢。
- 插件列表与你的勾选完全一致,`zsh-syntax-highlighting` 始终排最后。
- 启动时会剔除目录不存在的插件,部分安装失败也能正常进 shell。
- 历史 50000 条、去重、跨会话共享;↑/↓ 为前缀搜索。
- Debian 上自动把 `bat`→`batcat`、`fd`→`fdfind` 映射好。

### 行为说明

- **幂等**:重复执行时 oh-my-zsh 与插件走 `git pull`;`~/.zshrc` 内容不变就不重写。
- **不静默覆盖**:凡是覆盖都会生成 `*.bak.YYYYMMDDHHMMSS` 备份;不是本脚本写的
  `~/.zshrc` 默认不动,要覆盖得显式加 `--force`。
- **适配发行版**:仓库里没有的包只 warn 跳过不中断;RHEL 系会先启用 EPEL,
  `curl`/`wget` 仅在缺失时才装(避免 `curl-minimal` 冲突导致整个事务失败)。
- **非 root 友好**:需要时自动用 `sudo`;macOS 无 Homebrew 时会询问是否安装,拒绝也能继续。

已在 Ubuntu 22.04 / 24.04 / 26.04、Debian 12 / 13、AlmaLinux 9 / 10 与
macOS 15(Apple 芯片)上验证。依赖:`bash` 3.2+、`curl`、可访问 github.com。

`eza` 只在 Ubuntu 24.04+ / Debian 13+ 的仓库里有;更老的版本会 warn 跳过,`ll` 退回普通 `ls`。

> 提示:starship 的图标需要终端使用 [Nerd Font](https://www.nerdfonts.com)。

---

## License

MIT
