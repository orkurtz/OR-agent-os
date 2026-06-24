param(
    [string]$Profile = "",
    [string]$NewProfile = "",
    [switch]$All,
    [switch]$Overwrite,
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

function Validate-BaseInstallation {
    if (-not (Test-Path -LiteralPath $BaseDir -PathType Container)) {
        throw "Agent OS base installation not found"
    }
    if (-not (Test-Path -LiteralPath (Join-Path $BaseDir "profiles") -PathType Container)) {
        throw "No profiles directory in base installation"
    }
}

function Validate-ProjectStandards {
    $standardsDir = Join-Path (Join-Path $ProjectDir "agent-os") "standards"
    if (-not (Test-Path -LiteralPath $standardsDir -PathType Container)) {
        throw "No standards directory found at agent-os/standards/. Run project-install first."
    }
}

function Find-StandardsFiles {
    $standardsDir = Join-Path (Join-Path $ProjectDir "agent-os") "standards"
    $files = New-Object System.Collections.Generic.List[string]
    Get-ChildItem -LiteralPath $standardsDir -Recurse -File -Filter "*.md" |
        Where-Object { $_.FullName -notmatch "\\.backups\\" } |
        Sort-Object FullName |
        ForEach-Object {
            $files.Add((Get-RelativePath $standardsDir $_.FullName))
        }
    if ($files.Count -eq 0) {
        throw "No standards to sync. Create standards first using /discover-standards or manually."
    }
    return $files
}

function Get-ExistingProfiles {
    $profilesDir = Join-Path $BaseDir "profiles"
    return @(Get-ChildItem -LiteralPath $profilesDir -Directory | Sort-Object Name | Select-Object -ExpandProperty Name)
}

function Create-NewProfile($Name) {
    if (-not $Name) { throw "Profile name cannot be empty." }
    $profileDir = Join-Path (Join-Path $BaseDir "profiles") $Name
    Ensure-Dir (Join-Path $profileDir "standards")
    Write-Success "Created new profile: $Name"
}

function Select-TargetProfile {
    if ($NewProfile) {
        if (-not (Test-Path -LiteralPath (Join-Path (Join-Path $BaseDir "profiles") $NewProfile) -PathType Container)) {
            Create-NewProfile $NewProfile
        }
        return $NewProfile
    }

    if ($Profile) {
        $profileDir = Join-Path (Join-Path $BaseDir "profiles") $Profile
        if (-not (Test-Path -LiteralPath $profileDir -PathType Container)) {
            $answer = Read-Host "Profile '$Profile' does not exist. Create it? (y/N)"
            if ($answer -match "^[Yy]$") {
                Create-NewProfile $Profile
            } else {
                throw "Cancelled."
            }
        }
        return $Profile
    }

    $profiles = Get-ExistingProfiles
    Write-Host ""
    Write-Status "Available profiles:"
    for ($i = 0; $i -lt $profiles.Count; $i++) {
        Write-Host "  $($i + 1)) $($profiles[$i])"
    }
    $createChoice = $profiles.Count + 1
    Write-Host "  $createChoice) [Create new profile]"

    while ($true) {
        $choice = Read-Host "Select profile (1-$createChoice)"
        if ($choice -match "^\d+$" -and [int]$choice -ge 1 -and [int]$choice -le $createChoice) {
            break
        }
        Write-Host "Invalid choice."
    }

    if ([int]$choice -eq $createChoice) {
        $name = Read-Host "Enter new profile name"
        Create-NewProfile $name
        return $name
    }

    return $profiles[[int]$choice - 1]
}

function Select-Files($Files) {
    if ($All) { return @($Files) }

    Write-Host ""
    Write-Status "Standards available to sync:"
    for ($i = 0; $i -lt $Files.Count; $i++) {
        Write-Host "  $($i + 1)) $($Files[$i])"
    }
    Write-Host ""
    Write-Host "Enter comma-separated numbers, 'all', or press Enter for all."
    $answer = Read-Host "Files to sync"

    if (-not $answer -or $answer -match "^(all|a)$") { return @($Files) }

    $selected = New-Object System.Collections.Generic.List[string]
    foreach ($part in ($answer -split ",")) {
        $trimmed = $part.Trim()
        if ($trimmed -match "^\d+$") {
            $idx = [int]$trimmed - 1
            if ($idx -ge 0 -and $idx -lt $Files.Count) {
                $selected.Add($Files[$idx])
            }
        }
    }
    if ($selected.Count -eq 0) { throw "No files selected." }
    return @($selected)
}

function Backup-ProfileFiles($TargetProfile, $Files) {
    if ($Files.Count -eq 0) { return }
    $profileStandards = Join-Path (Join-Path (Join-Path $BaseDir "profiles") $TargetProfile) "standards"
    $timestamp = Get-Date -Format "yyyy-MM-dd-HHmm"
    $backupDir = Join-Path (Join-Path $profileStandards ".backups") $timestamp
    Ensure-Dir $backupDir

    $count = 0
    foreach ($relative in $Files) {
        $source = Join-Path $profileStandards $relative
        if (Test-Path -LiteralPath $source -PathType Leaf) {
            $dest = Join-Path $backupDir $relative
            Ensure-Dir (Split-Path -Parent $dest)
            Copy-Item -LiteralPath $source -Destination $dest -Force
            $count++
        }
    }
    if ($count -gt 0) {
        Write-Success "Backed up $count file(s) to .backups/$timestamp/"
    }
}

function Resolve-Conflicts($TargetProfile, $SelectedFiles) {
    $profileStandards = Join-Path (Join-Path (Join-Path $BaseDir "profiles") $TargetProfile) "standards"
    $conflicts = @($SelectedFiles | Where-Object { Test-Path -LiteralPath (Join-Path $profileStandards $_) -PathType Leaf })
    if ($conflicts.Count -eq 0) { return @($SelectedFiles) }

    if ($Overwrite) {
        Backup-ProfileFiles $TargetProfile $conflicts
        return @($SelectedFiles)
    }

    Write-Host ""
    Write-WarningMsg "$($conflicts.Count) file(s) already exist in profile '$TargetProfile':"
    foreach ($file in $conflicts) { Write-Host "  - $file" }
    Write-Host ""
    Write-Host "1) Overwrite all (with backup)"
    Write-Host "2) Skip existing files"
    Write-Host "3) Cancel"
    $choice = Read-Host "Choice (1-3)"

    switch ($choice) {
        "1" {
            Backup-ProfileFiles $TargetProfile $conflicts
            return @($SelectedFiles)
        }
        "2" {
            $remaining = @($SelectedFiles | Where-Object { $conflicts -notcontains $_ })
            if ($remaining.Count -eq 0) {
                Write-WarningMsg "No files left to sync after skipping conflicts."
                exit 0
            }
            return $remaining
        }
        default { throw "Cancelled." }
    }
}

function Execute-Sync($TargetProfile, $SelectedFiles) {
    $projectStandards = Join-Path (Join-Path $ProjectDir "agent-os") "standards"
    $profileStandards = Join-Path (Join-Path (Join-Path $BaseDir "profiles") $TargetProfile) "standards"
    Ensure-Dir $profileStandards

    $count = 0
    foreach ($relative in $SelectedFiles) {
        $source = Join-Path $projectStandards $relative
        $dest = Join-Path $profileStandards $relative
        Ensure-Dir (Split-Path -Parent $dest)
        Copy-Item -LiteralPath $source -Destination $dest -Force
        $count++
        Write-VerboseMsg "Synced: $relative"
    }

    Write-Host ""
    Write-Success "Synced $count file(s) to profile '$TargetProfile'"
}

Write-Status "Agent OS Sync to Profile"
Validate-BaseInstallation
Validate-ProjectStandards

$standardsFiles = Find-StandardsFiles
$targetProfile = Select-TargetProfile
$selectedFiles = Select-Files $standardsFiles
$selectedFiles = Resolve-Conflicts $targetProfile $selectedFiles

Write-Host ""
Write-Status "Sync summary:"
Write-Host "  Profile: $targetProfile"
Write-Host "  Files to sync: $($selectedFiles.Count)"

Execute-Sync $targetProfile $selectedFiles
