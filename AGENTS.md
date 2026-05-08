# Agent Installation Entry

If a user gives you this repository and says something like “install this prompt”, “configure this”, or “set up this repo”, do not guess.

Read `INSTALL.md` first, then guide the user through the install flow.

Required behavior:

1. Identify the user's OS and shell.
2. Identify which supported CLI tools are installed or relevant: Claude Code, Codex/OpenAI CLI, Gemini CLI.
3. Ask which tool(s) to install for if unclear.
4. Ask which install mode to use:
   - Merge install: preserve existing global prompt content and manage this repo's prompt inside a `cli-prompts` marker block.
   - Overwrite install: back up the existing file, then replace it with this repo's full prompt file.
5. Do not overwrite an existing config unless the user explicitly chooses overwrite install.
6. After installation, report the install mode, written files, and backup files.

Supported source files:

- Claude Code: `claude/CLAUDE.md` -> `~/.claude/CLAUDE.md`
- Codex/OpenAI CLI: `codex/AGENTS.md` -> `~/.codex/AGENTS.md`
- Gemini CLI: `gemini/GEMINI.md` -> `~/.gemini/GEMINI.md`
