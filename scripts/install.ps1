[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateSet('claude', 'codex', 'gemini', 'all')]
    [string]$Tool = 'all',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot

$Targets = @{
    claude = @{
        Source = Join-Path $RepoRoot 'claude\CLAUDE.md'
        Target = Join-Path $HOME '.claude\CLAUDE.md'
    }
    codex = @{
        Source = Join-Path $RepoRoot 'codex\AGENTS.md'
        Target = Join-Path $HOME '.codex\AGENTS.md'
    }
    gemini = @{
        Source = Join-Path $RepoRoot 'gemini\GEMINI.md'
        Target = Join-Path $HOME '.gemini\GEMINI.md'
    }
}

function Install-PromptFile {
    param(
        [string]$Name,
        [string]$Source,
        [string]$Target
    )

    if (-not (Test-Path $Source)) {
        throw "Source file not found: $Source"
    }

    $targetDir = Split-Path -Parent $Target
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    if (Test-Path $Target) {
        $backup = "$Target.bak"
        Copy-Item -Path $Target -Destination $backup -Force

        if (-not $Force) {
            $answer = Read-Host "$Name target exists. Backup created at $backup. Overwrite $Target? [y/N]"
            if ($answer -notin @('y', 'Y', 'yes', 'YES')) {
                Write-Host "Skipped $Name"
                return
            }
        }
    }

    Copy-Item -Path $Source -Destination $Target -Force
    Write-Host "Installed $Name -> $Target"
}

$selected = if ($Tool -eq 'all') { @('claude', 'codex', 'gemini') } else { @($Tool) }

foreach ($name in $selected) {
    $config = $Targets[$name]
    Install-PromptFile -Name $name -Source $config.Source -Target $config.Target
}
