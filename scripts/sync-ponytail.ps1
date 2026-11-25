# Copy ponytail skills, hooks, the Cursor rule, and LICENSE from upstream.
# Does not edit those files. Refreshes plugins/ponytail/UPSTREAM.json.
# Usage: pwsh -File scripts/sync-ponytail.ps1 [-Ref main]

param(
    [string]$Ref = "main"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$plugin = Join-Path $repoRoot "plugins\ponytail"
$manifestPath = Join-Path $plugin ".cursor-plugin\plugin.json"
$remote = "https://github.com/DietrichGebert/ponytail.git"
$tmp = Join-Path $env:TEMP ("ponytail-upstream-" + [guid]::NewGuid().ToString("n"))

if (-not (Test-Path $manifestPath)) {
    throw "Missing $manifestPath"
}

# Use the process proxy, or the current user's Windows proxy. Do not write git config.
$proxy = $env:HTTPS_PROXY
if (-not $proxy) { $proxy = $env:https_proxy }
if (-not $proxy) {
    $inet = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -ErrorAction SilentlyContinue
    if ($inet.ProxyEnable -eq 1 -and $inet.ProxyServer) {
        $proxy = [string]$inet.ProxyServer
        if ($proxy -notmatch "://") { $proxy = "http://$proxy" }
    }
}
$gitArgs = @()
if ($proxy) { $gitArgs = @("-c", "http.proxy=$proxy", "-c", "https.proxy=$proxy") }

& git @gitArgs clone --depth 1 --branch $Ref $remote $tmp
if ($LASTEXITCODE -ne 0) { throw "git clone failed" }

try {
    $sha = (git -C $tmp rev-parse HEAD).Trim()
    $pkg = Get-Content (Join-Path $tmp "package.json") -Raw | ConvertFrom-Json
    $version = [string]$pkg.version
    if (-not $sha -or -not $version) { throw "upstream commit or version is empty" }

    foreach ($rel in @("skills", "hooks", ".cursor", "LICENSE")) {
        $path = Join-Path $plugin $rel
        if (Test-Path $path) { Remove-Item -Recurse -Force $path }
    }

    Copy-Item (Join-Path $tmp "skills") (Join-Path $plugin "skills") -Recurse -Force
    Copy-Item (Join-Path $tmp "hooks") (Join-Path $plugin "hooks") -Recurse -Force
    New-Item -ItemType Directory -Force -Path (Join-Path $plugin ".cursor\rules") | Out-Null
    Copy-Item (Join-Path $tmp ".cursor\rules\*") (Join-Path $plugin ".cursor\rules") -Force
    Copy-Item (Join-Path $tmp "LICENSE") (Join-Path $plugin "LICENSE") -Force

    $license = Get-Content (Join-Path $plugin "LICENSE") -Raw
    if ($license -notmatch "MIT License" -or $license -notmatch "DietrichGebert") {
        throw "upstream LICENSE is not the expected MIT notice"
    }

    $skillDirs = Get-ChildItem (Join-Path $plugin "skills") -Directory
    if ($skillDirs.Count -lt 1) { throw "upstream skills directory is empty" }
    foreach ($dir in $skillDirs) {
        if (-not (Test-Path (Join-Path $dir.FullName "SKILL.md"))) {
            throw "missing SKILL.md in $($dir.Name)"
        }
    }

    $manifest = Get-Content $manifestPath -Raw
    $updated = [regex]::Replace($manifest, '("version"\s*:\s*")[^"]*"', '${1}' + $version + '"', 1)
    if ($updated -eq $manifest) { throw "plugin.json has no version field" }
    Set-Content -Path $manifestPath -Value $updated -Encoding utf8NoBOM

    $record = [ordered]@{
        repository = "https://github.com/DietrichGebert/ponytail"
        commit     = $sha
        ref        = $Ref
        version    = $version
        license    = "MIT"
        paths      = @("skills", "hooks", ".cursor/rules", "LICENSE")
    }
    $record | ConvertTo-Json | Set-Content (Join-Path $plugin "UPSTREAM.json") -Encoding utf8NoBOM

    Write-Output "synced ponytail $version ($sha)"
}
finally {
    if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
}
