# 安装指南

这个文件面向用户和 LLM/CLI agent。把仓库地址交给任意 agent 时，可以让它先读取本文件，再根据当前环境配置对应工具的全局提示词。

## 给 LLM/CLI Agent 的一句话

请读取这个仓库的 `INSTALL.md`，识别我的操作系统和已安装的 AI CLI 工具，然后选择合适模式帮我配置全局提示词；写入任何已有配置文件前必须备份并征求确认。

## 支持的工具

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
4. 如果目标文件已存在，先复制为 `.bak` 备份。
5. 将源文件复制到目标位置。
6. 告诉用户修改了哪些文件、备份在哪里。

## 模式二：自动脚本配置

### Windows PowerShell

```powershell
.\scripts\install.ps1 -Tool all
```

只安装 Claude Code：

```powershell
.\scripts\install.ps1 -Tool claude
```

覆盖已有文件且不交互确认：

```powershell
.\scripts\install.ps1 -Tool all -Force
```

### macOS / Linux

```bash
./scripts/install.sh --tool all
```

只安装 Claude Code：

```bash
./scripts/install.sh --tool claude
```

覆盖已有文件且不交互确认：

```bash
./scripts/install.sh --tool all --force
```

## 安全边界

安装脚本只做这些事：

- 复制本仓库中的提示词文件。
- 创建目标目录。
- 覆盖前创建 `.bak` 备份。

安装脚本不会做这些事：

- 不读取或上传 token、API key、cookie、SSH key。
- 不修改 MCP、hook、proxy、登录态或认证配置。
- 不执行 git push、远程发布、删除仓库等高影响操作。
- 不自动合并用户已有规则，只会整体复制对应文件。

## 推荐 agent 行为

如果你是正在执行配置的 LLM/CLI agent：

1. 先确认用户要配置哪些工具。
2. 检查当前 OS 和 shell。
3. 如果用户要求自动配置，优先使用对应脚本。
4. 如果目标文件已存在且用户没有允许覆盖，必须先展示目标路径并询问。
5. 完成后列出写入文件和备份文件。
