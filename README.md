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
  `zsh-completions` is put on `fpath` before `compinit` instead of in the plugin list, which is
  the only way its completions actually register under oh-my-zsh.
- Homebrew's `shellenv` is applied when Homebrew is present (`/opt/homebrew`, `/usr/local`,
  Linuxbrew), so brew-installed tools are on PATH even without a `~/.zprofile`.
- Missing plugin directories are filtered out at startup, so a partial install still opens a shell.
- 50 000 lines of shared, de-duplicated history; prefix search on ↑/↓.
- Debian aliases fixed up automatically (`bat`→`batcat`, `fd`→`fdfind`).

### Behaviour

- **Idempotent.** Re-running updates oh-my-zsh and its plugins via `git pull`, and rewrites
  `~/.zshrc` only when the content actually changes.
- **Never clobbers silently.** Anything it overwrites is backed up as `*.bak.YYYYMMDDHHMMSS`.
  An existing `~/.zshrc` that this script did not write is left untouched unless you say so:
  interactively it asks; with `--yes` it needs `--force`. When it is left alone the run ends
  with a warning and exit code 1, because the plugins are installed but not enabled.
- **Distro aware.** Packages missing from a repo are skipped with a warning instead of aborting;
  RHEL-family hosts get EPEL enabled first, and `curl`/`wget` are only installed when absent
  (so `curl-minimal` conflicts can't break the transaction).
- **Non-root friendly.** Uses `sudo` when needed; on macOS it offers to install Homebrew and
  carries on without it if you decline. A Homebrew that is installed but not yet on PATH
  (ssh sessions, `curl | bash`) is found in its standard prefix. macOS's own zsh and git are
  used as they are, and the login shell is switched to `/bin/zsh`, which `/etc/shells` already
  lists, so `chsh` needs no root.

Verified on Ubuntu 22.04 / 24.04 / 26.04, Debian 12 / 13, AlmaLinux 9 / 10 and
macOS 15 / 26 (Apple silicon). Requires `bash` 3.2+, `curl`, and network access to github.com.

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
  `zsh-completions` 不走插件列表,而是在 `compinit` 之前加进 `fpath` —— 在 oh-my-zsh 下
  只有这样它的补全才真正注册得上。
- 检测到 Homebrew(`/opt/homebrew`、`/usr/local`、Linuxbrew)时自动执行 `shellenv`,
  没有 `~/.zprofile` 也能用到 brew 装的工具。
- 启动时会剔除目录不存在的插件,部分安装失败也能正常进 shell。
- 历史 50000 条、去重、跨会话共享;↑/↓ 为前缀搜索。
- Debian 上自动把 `bat`→`batcat`、`fd`→`fdfind` 映射好。

### 行为说明

- **幂等**:重复执行时 oh-my-zsh 与插件走 `git pull`;`~/.zshrc` 内容不变就不重写。
- **不静默覆盖**:凡是覆盖都会生成 `*.bak.YYYYMMDDHHMMSS` 备份;不是本脚本写的
  `~/.zshrc` 不会擅自动:交互模式下会问你,`--yes` 模式下必须加 `--force`。
  如果最终没动,脚本会以警告收尾并返回退出码 1,因为插件装了但没启用。
- **适配发行版**:仓库里没有的包只 warn 跳过不中断;RHEL 系会先启用 EPEL,
  `curl`/`wget` 仅在缺失时才装(避免 `curl-minimal` 冲突导致整个事务失败)。
- **非 root 友好**:需要时自动用 `sudo`;macOS 无 Homebrew 时会询问是否安装,拒绝也能继续。
  Homebrew 装了但还不在 PATH 里(ssh 会话、`curl | bash`)也能在标准目录找到。
  macOS 自带的 zsh 和 git 直接用,登录 shell 切到 `/etc/shells` 已收录的 `/bin/zsh`,
  `chsh` 不需要 root。

已在 Ubuntu 22.04 / 24.04 / 26.04、Debian 12 / 13、AlmaLinux 9 / 10 与
macOS 15 / 26(Apple 芯片)上验证。依赖:`bash` 3.2+、`curl`、可访问 github.com。

`eza` 只在 Ubuntu 24.04+ / Debian 13+ 的仓库里有;更老的版本会 warn 跳过,`ll` 退回普通 `ls`。

> 提示:starship 的图标需要终端使用 [Nerd Font](https://www.nerdfonts.com)。

---

## Disclaimer / 免责声明

**English.** This is a personal utility, shared in case it is useful to someone else, and
provided **as is, without warranty of any kind, express or implied**. The author accepts no
liability for any loss or damage arising from its use.

It is not affiliated with, endorsed by, sponsored by or supported by the Zsh project, Oh My
Zsh, Starship, SDKMAN!, nvm, Homebrew, Apple, Red Hat, Canonical, the Debian or AlmaLinux
projects, the authors of any plugin or tool it installs, or any other project or vendor named
in this repository. All product names, logos and trademarks are the property of their
respective owners, and are used here only to identify the software the script installs or
configures.

The script installs software on the machine it runs on: it invokes the system package manager
with sudo, downloads and executes installer scripts published by the upstream projects listed
above, clones plugin repositories from GitHub, writes `~/.zshrc` and `~/.config/starship.toml`,
and can change the login shell. Each of those components is covered by its own license and is
obtained directly from its own publisher; this repository redistributes none of them. Nothing
in this repository is legal advice.

**中文。** 这是个人自用工具,公开出来只是想着或许对别人也有用,
**按原样提供,不附带任何明示或默示的担保**。作者对因使用本项目而产生的任何损失或损害
不承担责任。

本项目与 Zsh 项目、Oh My Zsh、Starship、SDKMAN!、nvm、Homebrew、Apple、Red Hat、Canonical、
Debian 与 AlmaLinux 项目、它所安装的任何插件或工具的作者,以及本仓库中提及的任何其他项目
或厂商,**均无关联,未获其背书、赞助或支持**。所有产品名称、标识与商标均归其各自所有者所有,
在此仅用于指明本脚本所安装或配置的软件对象。

本脚本会在其运行的机器上安装软件:以 sudo 调用系统包管理器、下载并执行上述上游项目发布的
安装脚本、从 GitHub 克隆插件仓库、写入 `~/.zshrc` 与 `~/.config/starship.toml`,
并可能修改登录 shell。其中每个组件都受其自身许可约束,且均直接从其各自发布方获取;
本仓库不分发其中任何一项。本仓库中的任何内容均不构成法律意见。

---

## License

MIT
