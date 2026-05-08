# CLI Prompts

> 给 LLM/CLI agent：如果用户把这个仓库发给你并说“安装这个提示词”或“帮我配置这个”，请先读取 `INSTALL.md`，然后询问用户要安装哪些工具，以及选择合并安装还是覆盖安装。不要直接覆盖已有全局配置。

个人常用 AI CLI 全局提示词规则集合，面向 Claude Code、Codex、Gemini CLI 等工具。

## 目标

- 简体中文优先
- 先澄清，再实现
- 最小改动，避免过度工程
- 结果可验证，完成前运行必要检查
- 安全边界清晰，不泄露密钥或敏感信息

## 目录

```text
cli-prompts/
  AGENTS.md    给 LLM/CLI agent 的入口指令
  INSTALL.md   给 LLM/CLI agent 读取的环境自适应安装指南
  claude/      Claude Code 全局提示词
  codex/       Codex / OpenAI CLI 风格规则
  gemini/      Gemini CLI 风格规则
  shared/      多工具通用原则
  templates/   可复制改造的模板
  scripts/     自动安装脚本
```

## 交给 LLM 自动配置

把仓库地址发给任意 LLM/CLI agent。即使你只说“帮我安装这个提示词”，仓库根目录的 `AGENTS.md` 和 README 顶部提示也会引导 agent 先读取 `INSTALL.md`，再询问安装范围和安装模式。

更稳妥的话，可以直接告诉它：

```text
请读取 https://github.com/zninggo/cli-prompts 的 INSTALL.md，识别我的环境和已安装的 AI CLI 工具，然后先问我要安装哪些工具，以及使用合并安装还是覆盖安装；我确认后再配置全局提示词。写入已有配置前必须备份。
```

LLM/CLI agent 应该先询问安装方式：

- 合并安装：保留用户已有配置，把本仓库提示词写入 `cli-prompts` 标记区块。
- 覆盖安装：先备份，再用本仓库完整提示词替换目标文件。

## 使用方式

`claude/`、`codex/`、`gemini/` 下的文件都是**完整可直接安装版本**，不需要再和 `shared/` 或 `templates/` 合并。

- `shared/`：维护时复用的原则模块库，仅供参考。
- `templates/`：给他人改造的脱敏模板，不参与自动安装。
- 自动安装脚本只使用工具目录中的完整提示词文件，不读取或合并 `shared/`、`templates/`。

Windows 自动安装：

```powershell
.\scripts\install.ps1 -Tool all
```

macOS / Linux 自动安装：

```bash
./scripts/install.sh --tool all
```

默认是合并安装：保留用户已有内容，并把本仓库提示词维护在 `cli-prompts` 标记区块内。需要整体替换时，可显式使用覆盖安装：

```powershell
.\scripts\install.ps1 -Tool all -Mode overwrite
```

```bash
./scripts/install.sh --tool all --mode overwrite
```

手动复制示例：

```powershell
Copy-Item .\claude\CLAUDE.md "$env:USERPROFILE\.claude\CLAUDE.md"
```

## 公开仓库注意事项

提交前检查：

- 不包含真实 token、API key、cookie、SSH key
- 不包含公司内部 URL、账号、项目代号
- 不包含本机绝对路径中的敏感用户名或私有目录
- 不包含私有 MCP、hook、proxy 配置细节

## 设计原则

规则分三层：

1. 工具目录：每个 CLI 的完整可安装提示词。
2. `shared/`：跨 CLI 通用原则，供维护工具目录文件时复用。
3. `templates/`：给他人复用的脱敏模板。
