# 安装指南

这个文件面向用户和 LLM/CLI agent。把仓库地址交给任意 agent 时，可以让它先读取本文件，再根据当前环境配置对应工具的全局提示词。

## 给 LLM/CLI Agent 的一句话

请读取这个仓库的 `INSTALL.md`，识别我的操作系统和已安装的 AI CLI 工具，然后先询问我要安装哪些工具、使用合并安装还是覆盖安装；确认后再配置全局提示词。写入任何已有配置文件前必须备份。

## LLM 引导安装流程

如果用户把本仓库地址交给你，并要求你帮他安装全局提示词，请按下面流程执行。即使用户只说“安装这个提示词”“配置这个仓库”“帮我设置一下”，也按本流程执行，不要直接覆盖任何已有配置：

1. 读取本文件和用户当前环境，不要直接覆盖任何已有配置。
2. 识别操作系统：Windows 使用 PowerShell 脚本；macOS/Linux 使用 Bash 脚本。
3. 尝试识别已安装工具：Claude Code、Codex/OpenAI CLI、Gemini CLI。
4. 询问用户要安装哪些工具：已检测到的工具、指定某一个工具，或全部。
5. 询问用户安装模式：
   - 推荐：合并安装。保留用户已有配置，把本仓库提示词写入 `cli-prompts` 标记区块。
   - 覆盖安装。先备份，再用本仓库完整提示词替换目标文件。
6. 用户确认后再执行对应脚本。
7. 完成后列出安装模式、写入文件、备份文件。

## 支持的工具

下面的源文件都是**完整可直接安装版本**，安装时不需要合并 `shared/` 或 `templates/`。

| 工具 | 源文件 | 默认目标位置 |
| --- | --- | --- |
| Claude Code | `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| Codex / OpenAI CLI | `codex/AGENTS.md` | `~/.codex/AGENTS.md` |
| Gemini CLI | `gemini/GEMINI.md` | `~/.gemini/GEMINI.md` |

## 模式一：说明式配置

适合希望先确认内容、不想直接运行脚本的用户。

1. 识别目标工具：Claude Code、Codex、Gemini，或全部。
2. 读取对应源文件。
3. 检查目标目录是否存在，不存在则创建。
4. 如果目标文件不存在，将源文件复制到目标位置。
5. 如果目标文件已存在，先复制为 `.bak` 备份，再选择安装模式：
   - 合并安装：把源文件内容写入 `<!-- BEGIN cli-prompts:工具名 -->` 和 `<!-- END cli-prompts:工具名 -->` 标记之间，保留用户原有内容。
   - 覆盖安装：用源文件整体替换目标文件。
6. 告诉用户修改了哪些文件、备份在哪里。

## 模式二：自动脚本配置

### Windows PowerShell

```powershell
.\scripts\install.ps1 -Tool all
```

### Windows cmd.exe

```cmd
scripts\install.cmd -Tool all
```

`install.cmd` 会自动优先调用 `pwsh`，没有 PowerShell 7 时回退到 Windows PowerShell。

默认使用合并安装，保留用户已有内容，并维护一个可重复更新的 `cli-prompts` 标记区块。

只安装 Claude Code：

```powershell
.\scripts\install.ps1 -Tool claude
```

显式合并安装：

```powershell
.\scripts\install.ps1 -Tool all -Mode merge
```

覆盖安装，覆盖前会备份并交互确认：

```powershell
.\scripts\install.ps1 -Tool all -Mode overwrite
```

```cmd
scripts\install.cmd -Tool all -Mode overwrite
```

覆盖安装且不交互确认：

```powershell
.\scripts\install.ps1 -Tool all -Mode overwrite -Force
```

```cmd
scripts\install.cmd -Tool all -Mode overwrite -Force
```

### macOS / Linux

```bash
./scripts/install.sh --tool all
```

默认使用合并安装，保留用户已有内容，并维护一个可重复更新的 `cli-prompts` 标记区块。

只安装 Claude Code：

```bash
./scripts/install.sh --tool claude
```

显式合并安装：

```bash
./scripts/install.sh --tool all --mode merge
```

覆盖安装，覆盖前会备份并交互确认：

```bash
./scripts/install.sh --tool all --mode overwrite
```

覆盖安装且不交互确认：

```bash
./scripts/install.sh --tool all --mode overwrite --force
```

## 安全边界

安装脚本只做这些事：

- 复制或合并本仓库中的提示词文件。
- 创建目标目录。
- 修改已有目标文件前创建 `.bak` 备份。
- 合并安装时只维护 `cli-prompts` 标记区块，保留标记区块之外的用户原有内容。

安装脚本不会做这些事：

- 不读取或上传 token、API key、cookie、SSH key。
- 不修改 MCP、hook、proxy、登录态或认证配置。
- 不执行 git push、远程发布、删除仓库等高影响操作。
- 不读取或合并 `shared/`、`templates/`。
- 不智能改写用户已有规则；合并安装只追加或更新脚本管理的标记区块。

## 推荐 agent 行为

如果你是正在执行配置的 LLM/CLI agent：

1. 先确认用户要配置哪些工具。
2. 检查当前 OS 和 shell。
3. 先询问安装模式：合并安装或覆盖安装，不要替用户默默选择。
4. 如果用户要求自动配置，优先使用对应脚本。
5. 推荐合并安装；只有用户明确要求覆盖时才使用覆盖安装。
6. 完成后列出安装模式、写入文件和备份文件。
