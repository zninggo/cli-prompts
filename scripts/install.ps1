[CmdletBinding()]
param(
    [ValidateSet('claude', 'codex', 'gemini', 'all')]
    [string]$Tool = 'all',

    [ValidateSet('merge', 'overwrite')]
    [string]$Mode = 'merge',

    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot

$HomeDir = if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }

$Targets = @{
    claude = @{
        Source = Join-Path $RepoRoot 'claude\CLAUDE.md'
        Target = Join-Path $HomeDir '.claude\CLAUDE.md'
    }
    codex = @{
        Source = Join-Path $RepoRoot 'codex\AGENTS.md'
        Target = Join-Path $HomeDir '.codex\AGENTS.md'
    }
    gemini = @{
        Source = Join-Path $RepoRoot 'gemini\GEMINI.md'
        Target = Join-Path $HomeDir '.gemini\GEMINI.md'
    }
}

function Backup-TargetFile {
    param(
        [string]$Target
    )

    $backup = "$Target.bak"
    Copy-Item -Path $Target -Destination $backup -Force
    return $backup
}

function Write-ManagedPromptFile {
    param(
        [string]$Name,
        [string]$Source,
        [string]$Target
    )

    $beginMarker = "<!-- BEGIN cli-prompts:$Name -->"
    $endMarker = "<!-- END cli-prompts:$Name -->"
    $rawSourceContent = Get-Content -Path $Source -Raw
    $sourceContent = if ($null -eq $rawSourceContent) { '' } else { [string]$rawSourceContent }
    $managedBlock = "$beginMarker`n$sourceContent`n$endMarker`n"

    Set-Content -Path $Target -Value $managedBlock -NoNewline
}

function Merge-PromptFile {
    param(
        [string]$Name,
        [string]$Source,
        [string]$Target
    )

    $beginMarker = "<!-- BEGIN cli-prompts:$Name -->"
    $endMarker = "<!-- END cli-prompts:$Name -->"
    $rawSourceContent = Get-Content -Path $Source -Raw
    $rawTargetContent = Get-Content -Path $Target -Raw
    $sourceContent = if ($null -eq $rawSourceContent) { '' } else { [string]$rawSourceContent }
    $targetContent = if ($null -eq $rawTargetContent) { '' } else { [string]$rawTargetContent }
    $managedBlock = "$beginMarker`n$sourceContent`n$endMarker"
    $hasBeginMarker = $targetContent.Contains($beginMarker)
    $hasEndMarker = $targetContent.Contains($endMarker)

    if ($hasBeginMarker -and (-not $hasEndMarker)) {
        throw "Managed block end marker not found in $Target"
    }

    if ((-not $hasBeginMarker) -and $hasEndMarker) {
        throw "Managed block begin marker not found in $Target"
    }

    $pattern = "(?s)\r?\n?" + [regex]::Escape($beginMarker) + ".*?" + [regex]::Escape($endMarker)

    if ($hasBeginMarker) {
        $mergedContent = [regex]::Replace($targetContent, $pattern, "`n$managedBlock")
    }
    else {
        $separator = if ([string]::IsNullOrEmpty($targetContent) -or $targetContent.EndsWith("`n")) { "`n" } else { "`n`n" }
        $mergedContent = "$targetContent$separator$managedBlock`n"
    }

    Set-Content -Path $Target -Value $mergedContent -NoNewline
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

    if (-not (Test-Path $Target)) {
        if ($Mode -eq 'merge') {
            Write-ManagedPromptFile -Name $Name -Source $Source -Target $Target
        }
        else {
            Copy-Item -Path $Source -Destination $Target -Force
        }

        Write-Host "Installed $Name -> $Target"
        return
    }

    $backup = Backup-TargetFile -Target $Target

    if ($Mode -eq 'overwrite') {
        if (-not $Force) {
            $answer = Read-Host "$Name target exists. Backup created at $backup. Overwrite $Target? [y/N]"
            if ($answer -notin @('y', 'Y', 'yes', 'YES')) {
                Write-Host "Skipped $Name"
                return
            }
        }

        Copy-Item -Path $Source -Destination $Target -Force
        Write-Host "Overwrote $Name -> $Target"
        return
    }

    Merge-PromptFile -Name $Name -Source $Source -Target $Target
    Write-Host "Merged $Name -> $Target"
    Write-Host "Backup: $backup"
}

$selected = if ($Tool -eq 'all') { @('claude', 'codex', 'gemini') } else { @($Tool) }

foreach ($name in $selected) {
    $config = $Targets[$name]
    Install-PromptFile -Name $name -Source $config.Source -Target $config.Target
}
