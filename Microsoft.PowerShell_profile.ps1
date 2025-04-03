# Nikkolas Jackson's PowerShell Profile
# Version 1.03
# Last Modified: 03/04/2025

Import-Module LaMoldy
Import-Module PSReadLine

$canConnectToGithub = Test-Connection github.com -Count 1 -Quiet -TimeoutSeconds 1

# Terminal Icons
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
}
Import-Module -Name Terminal-Icons

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}


# Powershell Icons and Airplane theme
$theme_directory = "C:\Users\Nikko\AppData\Local\Programs\oh-my-posh\themes"
$theme_file = "takuya.omp.json" # Must include .omp.json at the end
oh-my-posh --init --shell pwsh --config "$theme_directory\$theme_file" | Invoke-Expression

# PSReadLine
if ($host.Name -eq 'ConsoleHost') {
    Import-Module PSReadLine
}

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows


Clear-Host
