# Scoop bucket for Sectile

[Sectile](https://github.com/sebastienferry/sectile) Desktop for Windows,
64-bit, as a [Scoop](https://scoop.sh) app. Scoop installs it in your profile,
without administrator rights, and adds **Sectile** to the Start menu.

```powershell
scoop bucket add sectile https://github.com/sebastienferry/scoop-sectile
scoop install sectile/sectile
```

Without Scoop yet, install it first, in a PowerShell that is not elevated:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

The app bundles its Sectile agent: nothing else needs installing. To upgrade,
quit Sectile, stop its agent, which outlives the window, then update:

```powershell
Stop-Process -Name sectile-agent -ErrorAction SilentlyContinue
scoop update
scoop update sectile
```

Remove it with `scoop uninstall sectile`. Its settings and logs stay in
`%APPDATA%\sectile-desktop`.

## What the manifest does

- It downloads `sectile-desktop-windows-amd64.zip` from the GitHub Release of
  the version it names, and checks it against the checksum that release
  publishes in `SHA256SUMS`.
- Sectile is not signed with a publisher identity, so Windows may warn once
  before opening it.

## How it is kept up to date

`.github/workflows/update.yml` runs every six hours and on demand. It runs
`bin/update-manifest`, which points the manifest at the latest Sectile release
and copies its checksum from `SHA256SUMS`; when that changes the manifest, the
workflow commits it, installs and uninstalls it on a Windows runner with
`bin/check.ps1`, and pushes it to `main`. To publish a release at once, run the
workflow by hand from the **Actions** tab, optionally with a tag.

`.github/workflows/check.yml` runs the same check on every pull request.

Run the update locally with:

```sh
sh bin/update-manifest          # the latest release
sh bin/update-manifest v0.4.1   # a given one
```
