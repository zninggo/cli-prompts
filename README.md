# CLI Prompts

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
  claude/      Claude Code 全局提示词
  codex/       Codex / OpenAI CLI 风格规则
  gemini/      Gemini CLI 风格规则
  shared/      多工具通用原则
  templates/   可复制改造的模板
```

## 使用方式

按需复制对应文件到各工具的全局配置位置，或把 `shared/` 中的规则合并进已有配置。

示例：

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

1. `shared/`：跨 CLI 通用原则。
2. 工具目录：每个 CLI 的专属规则。
3. `templates/`：给他人复用的脱敏模板。
