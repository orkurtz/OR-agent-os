param(
    [string]$Profile = "",
    [switch]$CommandsOnly,
    [switch]$NoStandardsOverwrite,
    [switch]$DryRun,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BaseDir = Split-Path -Parent $ScriptDir
$ProjectDir = (Get-Location).Path

function Write-Status($Message) { Write-Host $Message -ForegroundColor Cyan }
function Write-Success($Message) { Write-Host "OK $Message" -ForegroundColor Green }
function Write-WarningMsg($Message) { Write-Host "WARN $Message" -ForegroundColor Yellow }
function Write-ErrorMsg($Message) { Write-Host "ERROR $Message" -ForegroundColor Red }
function Write-VerboseMsg($Message) { if ($Verbose) { Write-Host "[VERBOSE] $Message" } }

function Ensure-Dir($Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-VerboseMsg "Created directory: $Path"
    }
}

function Get-RelativePath($BasePath, $TargetPath) {
    $baseFull = [System.IO.Path]::GetFullPath($BasePath)
    if (-not $baseFull.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $baseFull += [System.IO.Path]::DirectorySeparatorChar
    }
    $targetFull = [System.IO.Path]::GetFullPath($TargetPath)
    $baseUri = New-Object System.Uri($baseFull)
    $targetUri = New-Object System.Uri($targetFull)
    return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($targetUri).ToString()).Replace('/', [System.IO.Path]::DirectorySeparatorChar)
}

function Get-YamlValue($Path, $Key, $Default) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $Default }
    $pattern = "^\s*$([regex]::Escape($Key)):\s*(.+?)\s*$"
    foreach ($line in Get-Content -LiteralPath $Path) {
        if ($line -match $pattern) { return $Matches[1].Trim() }
    }
    return $Default
}

function Get-ProfileInheritsFrom($ConfigPath, $ProfileName) {
    if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) { return "" }

    $inProfiles = $false
    $inTarget = $false
    $profilePattern = "^\s{2}$([regex]::Escape($ProfileName)):\s*$"

    foreach ($line in Get-Content -LiteralPath $ConfigPath) {
        if ($line -match "^profiles:\s*$") {
            $inProfiles = $true
            $inTarget = $false
            continue
        }
        if ($inProfiles -and $line -match "^[^\s].+:\s*$" -and $line -notmatch "^profiles:") {
            $inProfiles = $false
            $inTarget = $false
        }
        if (-not $inProfiles) { continue }

        if ($line -match $profilePattern) {
            $inTarget = $true
            continue
        }
        if ($inTarget -and $line -match "^\s{2}[A-Za-z0-9_-]+:\s*$") {
            $inTarget = $false
            continue
        }
        if ($inTarget -and $line -match "^\s*inherits_from:\s*(.+?)\s*$") {
            return $Matches[1].Trim()
        }
    }
    return ""
}

function Get-ProfileInheritanceChain($ConfigPath, $ProfileName, $ProfilesDir) {
    $chain = New-Object System.Collections.Generic.List[string]
    $visited = New-Object System.Collections.Generic.HashSet[string]
    $current = $ProfileName

    while ($current) {
        if ($visited.Contains($current)) {
            throw "Circular dependency detected in profile inheritance chain at '$current'."
        }
        [void]$visited.Add($current)

        $profileDir = Join-Path $ProfilesDir $current
        if (-not (Test-Path -LiteralPath $profileDir -PathType Container)) {
            throw "Profile not found: $current"
        }

        $chain.Insert(0, $current)
        $current = Get-ProfileInheritsFrom $ConfigPath $current
    }

    return $chain
}

function Read-ExistingIndexDescriptions($IndexFile) {
    $descriptions = @{}
    if (-not (Test-Path -LiteralPath $IndexFile -PathType Leaf)) { return $descriptions }

    $folder = ""
    $file = ""
    foreach ($line in Get-Content -LiteralPath $IndexFile) {
        if ($line -match "^([A-Za-z0-9_-]+):\s*$") {
            $folder = $Matches[1]
            $file = ""
            continue
        }
        if ($folder -and $line -match "^\s{2}([A-Za-z0-9_-]+):\s*$") {
            $file = $Matches[1]
            continue
        }
        if ($folder -and $file -and $line -match "^\s*description:\s*(.+?)\s*$") {
            $value = $Matches[1].Trim()
            if ($value -and $value -ne "Needs description - run /index-standards") {
                $descriptions["$folder/$file"] = $value
            }
        }
    }
    return $descriptions
}

function Validate-BaseInstallation {
    if (-not (Test-Path -LiteralPath $BaseDir -PathType Container)) {
        throw "Agent OS base installation not found"
    }
    if (-not (Test-Path -LiteralPath (Join-Path $BaseDir "config.yml") -PathType Leaf)) {
        throw "Base installation config.yml not found"
    }
}

function Validate-NotInBase {
    if ((Resolve-Path -LiteralPath $ProjectDir).Path -eq (Resolve-Path -LiteralPath $BaseDir).Path) {
        throw "Cannot install Agent OS in the base installation directory. Navigate to your project directory first."
    }
}

function Load-Configuration {
    $configFile = Join-Path $BaseDir "config.yml"
    $defaultProfile = Get-YamlValue $configFile "default_profile" "default"
    if ($Profile) { $effectiveProfile = $Profile } else { $effectiveProfile = $defaultProfile }

    $profilesDir = Join-Path $BaseDir "profiles"
    $chain = Get-ProfileInheritanceChain $configFile $effectiveProfile $profilesDir

    return @{
        EffectiveProfile = $effectiveProfile
        Chain = $chain
    }
}

function Get-ProfileStandardFiles($Chain) {
    $files = New-Object System.Collections.Generic.List[object]
    foreach ($profileName in $Chain) {
        $standardsDir = Join-Path (Join-Path (Join-Path $BaseDir "profiles") $profileName) "standards"
        if (-not (Test-Path -LiteralPath $standardsDir -PathType Container)) { continue }
        Get-ChildItem -LiteralPath $standardsDir -Recurse -File -Filter "*.md" |
            Where-Object { $_.FullName -notmatch "\\.backups\\" } |
            Sort-Object FullName |
            ForEach-Object {
                $relative = Get-RelativePath $standardsDir $_.FullName
                $files.Add([pscustomobject]@{
                    Profile = $profileName
                    Source = $_.FullName
                    Relative = $relative
                })
            }
    }
    return $files
}

function Confirm-StandardsOverwrite($EffectiveProfile) {
    if ($CommandsOnly) { return }
    $existing = Join-Path (Join-Path $ProjectDir "agent-os") "standards"
    if (-not (Test-Path -LiteralPath $existing -PathType Container)) { return }

    Write-WarningMsg "Existing standards folder detected at: $existing"
    if ($NoStandardsOverwrite) {
        throw "Cancelled because -NoStandardsOverwrite was specified."
    }

    $answer = Read-Host "Back up existing standards, then install standards from '$EffectiveProfile'? (y/N)"
    if ($answer -notmatch "^[Yy]$") {
        Write-Host "Installation cancelled."
        exit 0
    }
}

function Backup-ExistingStandards {
    if ($CommandsOnly) { return }
    $standardsDir = Join-Path (Join-Path $ProjectDir "agent-os") "standards"
    if (-not (Test-Path -LiteralPath $standardsDir -PathType Container)) { return }

    $timestamp = Get-Date -Format "yyyy-MM-dd-HHmm"
    $backupDir = Join-Path (Join-Path $standardsDir ".backups") $timestamp
    Ensure-Dir $backupDir

    $count = 0
    Get-ChildItem -LiteralPath $standardsDir -Recurse -File -Filter "*.md" |
        Where-Object { $_.FullName -notmatch "\\.backups\\" } |
        ForEach-Object {
            $relative = Get-RelativePath $standardsDir $_.FullName
            $dest = Join-Path $backupDir $relative
            Ensure-Dir (Split-Path -Parent $dest)
            Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
            $count++
        }

    if ($count -gt 0) {
        Write-Success "Backed up $count existing standards to agent-os/standards/.backups/$timestamp/"
    }
}

function Create-ProjectStructure {
    Write-Status "Creating project structure..."
    Ensure-Dir (Join-Path $ProjectDir "agent-os")
    Ensure-Dir (Join-Path (Join-Path $ProjectDir "agent-os") "standards")
    Ensure-Dir (Join-Path (Join-Path $ProjectDir "agent-os") "product")
    Write-Success "Created agent-os/ directory structure"
}

function Install-Standards($Chain) {
    if ($CommandsOnly) {
        Write-Status "Skipping standards (-CommandsOnly)"
        return
    }

    Write-Status "Installing standards..."
    $projectStandards = Join-Path (Join-Path $ProjectDir "agent-os") "standards"
    $sources = @{}
    foreach ($item in Get-ProfileStandardFiles $Chain) {
        $dest = Join-Path $projectStandards $item.Relative
        Ensure-Dir (Split-Path -Parent $dest)
        Copy-Item -LiteralPath $item.Source -Destination $dest -Force
        $sources[$item.Relative] = $item.Profile
    }

    if ($sources.Count -eq 0) {
        Write-Success "No standards to install (profile is empty)"
        return
    }

    foreach ($relative in ($sources.Keys | Sort-Object)) {
        if ($Chain.Count -gt 1) {
            Write-Host "  $relative (from $($sources[$relative]))"
        } else {
            Write-Host "  $relative"
        }
    }
    Write-Success "Installed $($sources.Count) standards files"
}

function Create-Index {
    Write-Status "Updating standards index..."

    $standardsDir = Join-Path (Join-Path $ProjectDir "agent-os") "standards"
    $indexFile = Join-Path $standardsDir "index.yml"
    $descriptions = Read-ExistingIndexDescriptions $indexFile
    $lines = New-Object System.Collections.Generic.List[string]
    $entryCount = 0
    $newCount = 0

    $lines.Add("# Agent OS Standards Index")
    $lines.Add("")

    $rootFiles = Get-ChildItem -LiteralPath $standardsDir -File -Filter "*.md" -ErrorAction SilentlyContinue | Sort-Object Name
    if ($rootFiles.Count -gt 0) {
        $lines.Add("root:")
        foreach ($fileInfo in $rootFiles) {
            $name = [System.IO.Path]::GetFileNameWithoutExtension($fileInfo.Name)
            $key = "root/$name"
            $desc = $descriptions[$key]
            if (-not $desc) {
                $desc = "Needs description - run /index-standards"
                $newCount++
            }
            $lines.Add("  ${name}:")
            $lines.Add("    description: $desc")
            $entryCount++
        }
        $lines.Add("")
    }

    $folders = Get-ChildItem -LiteralPath $standardsDir -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne ".backups" } |
        Sort-Object Name

    foreach ($folder in $folders) {
        $mdFiles = Get-ChildItem -LiteralPath $folder.FullName -Recurse -File -Filter "*.md" |
            Where-Object { $_.FullName -notmatch "\\.backups\\" } |
            Sort-Object FullName
        if ($mdFiles.Count -eq 0) { continue }

        $lines.Add("$($folder.Name):")
        foreach ($fileInfo in $mdFiles) {
            $name = [System.IO.Path]::GetFileNameWithoutExtension($fileInfo.Name)
            $key = "$($folder.Name)/$name"
            $desc = $descriptions[$key]
            if (-not $desc) {
                $desc = "Needs description - run /index-standards"
                $newCount++
            }
            $lines.Add("  ${name}:")
            $lines.Add("    description: $desc")
            $entryCount++
        }
        $lines.Add("")
    }

    Set-Content -LiteralPath $indexFile -Value $lines -Encoding UTF8
    if ($newCount -gt 0) {
        Write-Success "Updated index.yml ($entryCount entries, $newCount new)"
    } else {
        Write-Success "Updated index.yml ($entryCount entries)"
    }
}

function Install-Commands {
    Write-Status "Installing commands..."

    $source = Join-Path (Join-Path $BaseDir "commands") "agent-os"
    $dest = Join-Path (Join-Path (Join-Path (Join-Path $ProjectDir ".claude") "commands") "agent-os") ""
    if (-not (Test-Path -LiteralPath $source -PathType Container)) {
        Write-WarningMsg "No commands found in base installation"
        return
    }

    Ensure-Dir $dest
    $count = 0
    Get-ChildItem -LiteralPath $source -File -Filter "*.md" | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $dest $_.Name) -Force
        $count++
    }
    Write-Success "Installed $count commands to .claude/commands/agent-os/"
}

function Create-ProductReadme {
    Write-Status "Creating product context guide..."
    $productReadme = Join-Path (Join-Path (Join-Path $ProjectDir "agent-os") "product") "README.md"
    if (Test-Path -LiteralPath $productReadme -PathType Leaf) {
        Write-Success "Product context guide already exists"
        return
    }

    $content = @(
        "# Agent OS Product Context",
        "",
        "This folder stores durable project context for developers and agents.",
        "",
        "Recommended first-time workflow:",
        "",
        '1. `/understand-project` creates `project-brief.md`',
        '2. `/create-tech-stack` creates `tech-stack.md`',
        '3. `/discover-standards` creates project standards in `agent-os/standards/`',
        '4. `/plan-product` creates or updates `mission.md` and `roadmap.md`',
        '5. `/continue-roadmap` transitions the next roadmap phase into a shaped spec',
        '6. `/shape-spec` creates saved specs for meaningful implementation work',
        '7. `/spec-changelog` maintains `agent-os/specs/CHANGELOG.md`',
        '8. `/review-project` creates a project readiness review',
        "",
        "Expected files:",
        "",
        '- `project-brief.md` - how the project works and where to start',
        '- `mission.md` - product purpose, audience, and constraints',
        '- `roadmap.md` - high-level product direction',
        '- `tech-stack.md` - factual technologies and what each is used for',
        '- `project-review.md` - project health, risks, and recommended next actions'
    )
    Set-Content -LiteralPath $productReadme -Value $content -Encoding UTF8
    Write-Success "Created agent-os/product/README.md"
}

function Show-DryRun($EffectiveProfile, $Chain) {
    Write-Host ""
    Write-Status "Agent OS Project Installation (dry run)"
    Write-Host "Project directory: $ProjectDir"
    Write-Host "Profile: $EffectiveProfile"
    Write-Host "Commands only: $CommandsOnly"
    Write-Host "No standards overwrite: $NoStandardsOverwrite"
    Write-Host ""
    Write-Host "Profile inheritance chain:"
    foreach ($profileName in $Chain) { Write-Host "  - $profileName" }
    Write-Host ""
    Write-Host "Standards that would be installed:"
    if ($CommandsOnly) {
        Write-Host "  (skipped because -CommandsOnly was set)"
    } else {
        $files = Get-ProfileStandardFiles $Chain
        if ($files.Count -eq 0) {
            Write-Host "  (none)"
        } else {
            foreach ($item in $files) { Write-Host "  $($item.Relative) (from $($item.Profile))" }
        }
    }
    Write-Host ""
    Write-Host "Commands that would be installed to .claude/commands/agent-os/:"
    $commandsSource = Join-Path (Join-Path $BaseDir "commands") "agent-os"
    if (Test-Path -LiteralPath $commandsSource -PathType Container) {
        Get-ChildItem -LiteralPath $commandsSource -File -Filter "*.md" | Sort-Object Name | ForEach-Object {
            Write-Host "  $($_.Name)"
        }
    } else {
        Write-Host "  (commands directory not found)"
    }
    Write-Host ""
    Write-Host "Product guide that would be created:"
    Write-Host "  agent-os/product/README.md"
    Write-Host ""
    Write-Host "No files were changed."
}

Write-Status "Agent OS Project Installation"
Validate-NotInBase
Validate-BaseInstallation
$config = Load-Configuration

if ($DryRun) {
    Show-DryRun $config.EffectiveProfile $config.Chain
    exit 0
}

Write-Host ""
Write-Status "Configuration:"
Write-Host "  Profile: $($config.EffectiveProfile)"
Write-Host "  Commands only: $CommandsOnly"
Write-Host "  No standards overwrite: $NoStandardsOverwrite"

Confirm-StandardsOverwrite $config.EffectiveProfile
Create-ProjectStructure
Backup-ExistingStandards
Install-Standards $config.Chain
Create-Index
Create-ProductReadme
Install-Commands

Write-Host ""
Write-Success "Agent OS installed successfully!"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Run /understand-project to create a project brief"
Write-Host "  2. Run /create-tech-stack to extract the factual tech stack"
Write-Host "  3. Run /discover-standards to extract patterns from your codebase"
Write-Host "  4. Run /plan-product if mission or roadmap docs are missing"
Write-Host "  5. Run /continue-roadmap to transition the next roadmap phase into a spec"
Write-Host "  6. Run /shape-spec in plan mode for meaningful work"
Write-Host "  7. Run /spec-changelog to maintain spec history"
Write-Host "  8. Run /review-project to audit readiness and gaps"
