<#
.SYNOPSIS
    Compiles each mission's scripts into a single Lua file under compiled/ for a single DO SCRIPT FILE upload.

.DESCRIPTION
    Reads the "## Script Load Order" code block in mission/<name>/README.md and concatenates the listed files,
    in order, into compiled/<name>.lua. Each file runs inside its own function so its top-level locals stay
    private, and inside pcall so one failing file doesn't stop the rest from loading - the same behavior as
    separate DO SCRIPT FILE triggers. *.model.lua files are type definitions only and are never included.

    Every .lua file in the repo must be compiled into every mission, except *.model.lua files and files inside
    other missions' directories. A mission fails to compile if its load order is missing any of them.

.EXAMPLE
    ./compile.ps1                 # compile every mission
    ./compile.ps1 kodiak_mist     # compile one mission
#>
param(
    [string[]]$Mission
)

$ErrorActionPreference = "Stop"

$repoRoot = $PSScriptRoot.TrimEnd('\', '/')
$missionRoot = Join-Path $repoRoot "mission"
$outputDir = Join-Path $repoRoot "compiled"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# Returns the paths listed in the first code block under the "## Script Load Order" heading.
function Get-LoadOrder([string]$readmePath) {
    $paths = @()
    $inSection = $false
    $inBlock = $false
    foreach ($line in Get-Content -LiteralPath $readmePath) {
        if ($line -match '^##\s') {
            if ($inSection) { break }
            $inSection = $line -match '^##\s+Script Load Order\s*$'
            continue
        }
        if (-not $inSection) { continue }
        if ($line -match '^\s*```') {
            if ($inBlock) { break }
            $inBlock = $true
            continue
        }
        if ($inBlock -and $line -match '"([^"]+)"') {
            # README paths are written as escaped Lua strings ("C:\\Users\\...")
            $paths += $Matches[1] -replace '\\\\', '\'
        }
    }
    return , $paths
}

# Resolves a load order entry to a full path inside the repo. Relative entries are relative to the repo root.
function Resolve-SourcePath([string]$path) {
    if (-not [System.IO.Path]::IsPathRooted($path)) {
        $path = Join-Path $repoRoot $path
    }
    $fullPath = [System.IO.Path]::GetFullPath($path)
    if (-not $fullPath.StartsWith($repoRoot + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "is outside the repo ($repoRoot)"
    }
    return $fullPath
}

# Returns every non-model .lua file in the repo as a repo-relative path, skipping git-ignored files like compiled/.
function Get-ScriptFiles {
    $files = git -C $repoRoot -c core.quotepath=off ls-files --cached --others --exclude-standard
    if ($LASTEXITCODE -ne 0) {
        throw "git ls-files failed, cannot check the load order for unlisted files"
    }
    # -match is case-insensitive, so .LUA files are caught too. --cached still lists tracked files deleted from disk.
    return @($files | Where-Object {
            $_ -match '\.lua$' -and $_ -notmatch '\.model\.lua$' -and
            (Test-Path -LiteralPath (Join-Path $repoRoot $_) -PathType Leaf)
        })
}

# True when a repo-relative path is inside a mission directory other than $missionName.
function Test-OtherMission([string]$relativePath, [string]$missionName) {
    return $relativePath -match '^mission/[^/]+/' -and
    -not $relativePath.StartsWith("mission/$missionName/", [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-GitVersion {
    try {
        $commit = git -C $repoRoot rev-parse --short HEAD 2>$null
        if (-not $commit) { return "unknown" }
        $dirty = git -C $repoRoot status --porcelain 2>$null
        if ($dirty) { return "$commit (uncommitted changes)" }
        return $commit
    }
    catch {
        return "unknown"
    }
}

function Build-Mission([System.IO.DirectoryInfo]$missionDir) {
    $name = $missionDir.Name
    $readmePath = Join-Path $missionDir.FullName "README.md"
    if (-not (Test-Path -LiteralPath $readmePath)) {
        Write-Warning "${name}: no README.md, skipping"
        return $true
    }

    $loadOrder = Get-LoadOrder $readmePath
    if ($loadOrder.Count -eq 0) {
        Write-Warning "${name}: README.md has no '## Script Load Order' code block, skipping"
        return $true
    }

    $sources = @()
    $listed = @{}
    $failed = $false
    foreach ($entry in $loadOrder) {
        if ($entry -match '\.model\.lua$') {
            Write-Warning "${name}: skipping type definition file $entry"
            continue
        }
        try {
            $fullPath = Resolve-SourcePath $entry
        }
        catch {
            Write-Host "${name}: $entry $($_.Exception.Message)" -ForegroundColor Red
            $failed = $true
            continue
        }
        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
            Write-Host "${name}: missing file $entry" -ForegroundColor Red
            $failed = $true
            continue
        }
        $relativePath = $fullPath.Substring($repoRoot.Length + 1) -replace '\\', '/'
        if ($relativePath -notmatch '\.lua$') {
            Write-Host "${name}: $relativePath is not a .lua file" -ForegroundColor Red
            $failed = $true
            continue
        }
        if (Test-OtherMission $relativePath $name) {
            Write-Host "${name}: $relativePath belongs to another mission" -ForegroundColor Red
            $failed = $true
            continue
        }
        if ($listed.ContainsKey($relativePath.ToLowerInvariant())) {
            Write-Host "${name}: $relativePath is in the load order more than once" -ForegroundColor Red
            $failed = $true
            continue
        }
        $listed[$relativePath.ToLowerInvariant()] = $true
        $sources += [pscustomobject]@{
            FullPath     = $fullPath
            RelativePath = $relativePath
        }
    }

    foreach ($file in $scriptFiles) {
        if (-not (Test-OtherMission $file $name) -and -not $listed.ContainsKey($file.ToLowerInvariant())) {
            Write-Host "${name}: $file is not in the load order" -ForegroundColor Red
            $failed = $true
        }
    }

    if ($failed) {
        Write-Host "${name}: not compiled" -ForegroundColor Red
        return $false
    }

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("-- Compiled by compile.ps1 from mission/$name/README.md - DO NOT EDIT, changes will be overwritten.")
    $lines.Add("-- Compiled: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
    $lines.Add("-- Commit: $(Get-GitVersion)")
    $lines.Add("--")
    $lines.Add("-- Load order:")
    foreach ($source in $sources) {
        $lines.Add("--   $($source.RelativePath)")
    }

    foreach ($source in $sources) {
        # ReadAllText strips a UTF-8 BOM, which Lua 5.1 can't parse
        $content = [System.IO.File]::ReadAllText($source.FullPath) -replace "`r`n", "`n"
        if ($content -match '(?m)^\s*config\.env\s*=\s*"dev"') {
            Write-Warning "${name}: $($source.RelativePath) sets config.env = `"dev`""
        }

        $lines.Add("")
        $lines.Add("-- " + ("=" * 100))
        $lines.Add("-- $($source.RelativePath)")
        $lines.Add("-- " + ("=" * 100))
        $lines.Add("do")
        $lines.Add("    local ok, err = pcall(function(...)")
        # Offset between compiled and source line numbers, so errors in dcs.log can be traced back to the source file
        $lineOffset = $lines.Count
        foreach ($line in $content.TrimEnd("`n").Split("`n")) {
            $lines.Add($line)
        }
        $lines.Add("    end)")
        $lines.Add("    if not ok then")
        $lines.Add("        env.error(`"[MagnusDCSScripting Compiled]: $($source.RelativePath) failed to load (source line = compiled line - $lineOffset): `" .. tostring(err))")
        $lines.Add("    end")
        $lines.Add("end")
    }

    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
    $outputPath = Join-Path $outputDir "$name.lua"
    [System.IO.File]::WriteAllText($outputPath, ($lines -join "`n") + "`n", $utf8NoBom)
    Write-Host "${name}: compiled $($sources.Count) files -> compiled/$name.lua" -ForegroundColor Green
    return $true
}

if ($Mission) {
    $missionDirs = foreach ($missionName in $Mission) {
        $missionPath = Join-Path $missionRoot $missionName
        if (-not (Test-Path -LiteralPath $missionPath -PathType Container)) {
            Write-Host "No mission directory mission/$missionName" -ForegroundColor Red
            exit 1
        }
        Get-Item -LiteralPath $missionPath
    }
}
else {
    $missionDirs = Get-ChildItem -LiteralPath $missionRoot -Directory
}

$scriptFiles = Get-ScriptFiles

$allSucceeded = $true
foreach ($missionDir in $missionDirs) {
    if (-not (Build-Mission $missionDir)) {
        $allSucceeded = $false
    }
}

if (-not $allSucceeded) {
    exit 1
}
