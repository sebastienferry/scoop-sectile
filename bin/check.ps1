# Install the committed manifest with Scoop, check what it installed, and
# uninstall it. Run from the root of this repository on Windows.
#
# `scoop bucket add` clones the repository, so it sees committed files only:
# commit a changed manifest before running this.
$ErrorActionPreference = 'Stop'

function Invoke-Checked([scriptblock] $Command) {
    & $Command
    if ($LASTEXITCODE) { throw "failed ($LASTEXITCODE): $Command" }
}

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    # The runners are elevated, which Scoop refuses unless told otherwise.
    Invoke-Expression "& {$(Invoke-RestMethod https://get.scoop.sh)} -RunAsAdmin"
    $env:PATH = "$env:USERPROFILE\scoop\shims;$env:PATH"
}

$version = (Get-Content bucket/sectile.json -Raw | ConvertFrom-Json).version
# scoop bucket add takes a Git URL, and a bare Windows path is not one.
$bucket = 'file:///' + ($PWD.Path -replace '\\', '/')
Invoke-Checked { scoop bucket add sectile $bucket }
Invoke-Checked { scoop install sectile/sectile }

$app = Join-Path (scoop prefix sectile) ''
if (-not (Test-Path (Join-Path $app 'Sectile.exe'))) { throw "Sectile.exe is not in $app" }
$agent = & (Join-Path $app 'resources\sectile-agent.exe') --version
if ($agent -notmatch "\bv$([regex]::Escape($version))\b") {
    throw "the bundled agent reports '$agent', not v$version"
}
$shortcut = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Scoop Apps\Sectile.lnk'
if (-not (Test-Path $shortcut)) { throw "no Start menu shortcut at $shortcut" }
Write-Output "sectile $version installs: $agent"

Invoke-Checked { scoop uninstall sectile }
Invoke-Checked { scoop bucket rm sectile }
