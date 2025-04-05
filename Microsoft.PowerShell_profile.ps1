# Nikkolas Jackson's PowerShell Profile
# Version 1.03
# Last Modified: 03/04/2025

$debug = $false

if ($debug) {
    Write-Host "#######################################" -ForegroundColor Red
    Write-Host "#           Debug mode enabled        #" -ForegroundColor Red
    Write-Host "#          ONLY FOR DEVELOPMENT       #" -ForegroundColor Red
    Write-Host "#######################################" -ForegroundColor Red
}


#  _    _           _       _         _____            __ _ _
# | |  | |         | |     | |       |  __ \          / _(_) |
# | |  | |_ __   __| | __ _| |_ ___  | |__) | __ ___ | |_ _| | ___
# | |  | | '_ \ / _` |/ _` | __/ _ \ |  ___/ '__/ _ \|  _| | |/ _ \
# | |__| | |_) | (_| | (_| | ||  __/ | |   | | | (_) | | | | |  __/
#  \____/| .__/ \__,_|\__,_|\__\___| |_|   |_|  \___/|_| |_|_|\___|
#        | |
#        |_|


$updateInterval = 7
$timeFilePath = "$env:USERPROFILE\Documents\PowerShell\LastExecutionTime.txt"
$canConnectToGithub = Test-Connection github.com -Count 1 -Quiet -TimeoutSeconds 1

# Check for Profile Updates
function Update-Profile {
    if (-not $canConnectToGithub) {
        Write-Host "Skipping profile update check due to Github.com not responding" -ForegroundColor Yellow
        return
    }

    try {
        $url = "https://raw.githubusercontent.com/LaMoldy/powershell-profile/main/Microsoft.PowerShell_profile.ps1"
        $oldhash = Get-FileHash $PROFILE
        Invoke-RestMethod $url -OutFile "$env:temp/Microsoft.PowerShell_profile.ps1"
        $newhash = Get-FileHash "$env:temp/Microsoft.PowerShell_profile.ps1"
        if ($newhash.Hash -ne $oldhash.Hash) {
            Copy-Item -Path "$env:temp/Microsoft.PowerShell_profile.ps1" -Destination $PROFILE -Force
            Write-Host "Profile has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
        } else {
            Write-Host "Profile is up to date." -ForegroundColor Green
        }
    } catch {
        Write-Error "Unable to check for `$profile updates: $_"
    } finally {
        Remove-Item "$env:temp/Microsoft.PowerShell_profile.ps1" -ErrorAction SilentlyContinue
    }
}

# Check for powershell updates
function Update-PowerShell {
    if (-not $canConnectToGithub) {
        Write-Host "Skipping PowerShell update check due to Github.com not responding" -ForegroundColor Yellow
        return
    }
    try {
        Write-Host "Checking for PowerShell updates..." -ForegroundColor Cyan
        $updateNeeded = $false
        $currentVersion = $PSVersionTable.PSVersion.ToString()
        $gitHubApiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
        $latestReleaseInfo = Invoke-RestMethod -Uri $gitHubApiUrl
        $latestVersion = $latestReleaseInfo.tag_name.Trim('v')
        if ($currentVersion -lt $latestVersion) {
            $updateNeeded = $true
        }

        if ($updateNeeded) {
            Write-Host "Updating PowerShell..." -ForegroundColor Yellow
            Start-Process powershell.exe -ArgumentList "-NoProfile -Command winget upgrade Microsoft.PowerShell --accept-source-agreements --accept-package-agreements" -Wait -NoNewWindow
            Write-Host "PowerShell has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
        } else {
            Write-Host "Your PowerShell is up to date." -ForegroundColor Green
        }
    } catch {
        Write-Error "Failed to update PowerShell. Error: $_"
    }
}

# Check if not in debug mode AND (updateInterval is -1 OR file doesn't exist OR time difference is greater than the update interval)
if (-not $debug -and `
    ($updateInterval -eq -1 -or -not (Test-Path $timeFilePath) -or `
    ((Get-Date) - [datetime]::ParseExact((Get-Content -Path $timeFilePath), 'yyyy-MM-dd', $null)).TotalDays -gt $updateInterval)) {
    Update-Profile
    Update-PowerShell
    $currentTime = Get-Date -Format 'yyyy-MM-dd'
    $currentTime | Out-File -FilePath $timeFilePath
} elseif (-not $debug) {
    Write-Warning "Profile update skipped. Last update check was within the last $updateInterval day(s)."
} else {
    Write-Warning "Skipping profile update check in debug mode"
}

#  __  __           _       _
# |  \/  |         | |     | |
# | \  / | ___   __| |_   _| | ___  ___
# | |\/| |/ _ \ / _` | | | | |/ _ \/ __|
# | |  | | (_) | (_| | |_| | |  __/\__ \
# |_|  |_|\___/ \__,_|\__,_|_|\___||___/

function Test-CommandExists ($command) {
    $exists = $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
    return $exists
}

# Terminal Icons
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
}
Import-Module -Name Terminal-Icons

# Chocolatey
if (-not (Test-CommandExists choco)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile" # Enables tab-completions to function for `choco`
}

# Oh-My-Posh (Airplane Theme and Icons)
if (-not (Test-CommandExists oh-my-posh)) {
    choco install -y oh-my-posh
}
$theme_directory = "C:\Users\Nikko\AppData\Local\Programs\oh-my-posh\themes"
$theme_file = "takuya.omp.json" # Must include .omp.json at the end
oh-my-posh --init --shell pwsh --config "$theme_directory\$theme_file" | Invoke-Expression

# PSReadLine
if (-not (Get-Module -ListAvailable -Name PSReadLine)) {
    if ($PSVersionTable.PSVersion.Major -eq 5 -and $PSVersionTable.PSVersion.Minor -eq 1) {
        Install-Module -Name PowerShellGet -Force # Need this if runnint powershell 5.1
    }
    Install-Module -Name PSReadLine -Repository PSGallery -Scope CurrentUser -AllowPrerelease -Force
}
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

# Fastfetch
if (-not (Test-CommandExists fastfetch)) {
    choco install -y fastfetch
    fastfetch --gen-config
    $url = "https://raw.githubusercontent.com/LaMoldy/powershell-profile/main/config-template.jsonc"
    Invoke-RestMethod $url -OutFile "$env:temp/config.jsonc"
    Copy-Item -Path "$env:temp/config.jsonc" -Destination "$HOME/.config/fastfetch" -Force
    Remove-Item "$env:temp/config.jsonc" -ErrorAction SilentlyContinue
}
function StartFastFetch {
    Write-Host "`n"
    fastfetch
    Write-Host "`n"
}
StartFastFetch

#  _    _ _   _ _ _ _           ______                _   _
# | |  | | | (_) (_) |         |  ____|              | | (_)
# | |  | | |_ _| |_| |_ _   _  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___
# | |  | | __| | | | __| | | | |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
# | |__| | |_| | | | |_| |_| | | |  | |_| | | | | (__| |_| | (_) | | | \__ \
#  \____/ \__|_|_|_|\__|\__, | |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
#                        __/ |
#                       |___/

# Profile Utilities
function reload { & $PROFILE } # Reloads the profile

function elevate {
    $isAdmin = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent() `
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if ($isAdmin) {
        Write-Host "Already running as admin" -ForegroundColor Green
    } else {
        Write-Host "Not running as Administrator. Launching elevated shell" -ForegroundColor Yellow

        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "powershell.exe"
        $psi.Verb = "runas"
        $psi.UseShellExecute = $true
        $psi.Arguments = "-NoExit -Command `"Write-Host 'Elevated session started.' -ForegroundColor Cyan`""

        try {
            [System.Diagnostics.Process]::Start($psi) | Out-Null
        } catch {
            Write-Warning "User canceled the UAC prompt or elevation failed."
        }
    }
}

function ConfigProfile {
    Set-Location $env:POWERSHELL_CONFIG # Must have this set as environment variable on the computer
    nvim .
}


# Misc Utilities
function ConfigNvim {
    Set-Location $env:NVIM_CONFIG # Must have this set as environment variable on the computer
    nvim .
}

function get-ip {
    $IP = (
        Get-NetIPConfiguration |
        Where-Object {
            $null -ne $_.IPv4DefaultGateway -and
            $_.NetAdapter.Status -ne "Disconnected"
        }
    ).IPv4Address.IPAddress
    Write-Host "IP: $IP"
}


# Development Utilities
function sve ($project) { # Starts a python virtual environment in the project specified
    if ($args -eq "-h") {
        Write-Host "Usage: sve <python project>`n`nStarts a python virtual environment in the project specified under:`n$HOME\personal folder"
        return
    }
    $project_path = "$HOME/personal/$project"
    if (Test-Path -Path $project_path) {
        Set-Location "$HOME/personal/$project"
        python -m pipenv shell
    } else {
        Write-Host "There was an error starting the virtual environment."
        Write-Host "Make sure the project exists and is spelled correctly."
        Write-Host "Use sve -h for a more detailed description."
    }
}


# Git Utilities
function gwip { # Git work in progress
    $current_date_time = Get-Date -Format "ddd MMM dd HH:mm:ss EST yyyy".ToString().Replace(".", "")
    git add .
    git commit -m "$current_date_time"
}

function gcom { # Commits all changes with a message
    git add .
    git commit -m "$args"
}

function gcomp { # Commits and pushes all changes with a message
    git add .
    git commit -m "$args"
    git push
}

# Unix Utilities
function ll { Get-ChildItem -Path $pwd -File } # Lists all files in the current directory
function which ($command) { Get-Command $command | Select-Object -ExpandProperty Definition } # Gets the path of a command
function touch ($file) { "" | Out-File $file -Encoding ASCII } # Creates a new file
function pgrep ($name) { Get-Process $name } # Gets a process by name
function pkill ($name) { Get-Process $name -ErrorAction SilentlyContinue | Stop-Process } # Kills a process by name

function grep ($regex, $dir) { # Searches for a pattern in a directory
    if ($dir) {
        Get-ChildItem -Path $dir | Select-String -Pattern $regex
        return
    }
    $input | Select-String -Pattern $regex
}

function rf ($dir) {
    if ($null -ne $dir) {
        if (Test-Path $dir) {
            Remove-Item -Path $dir -Recurse -Force
            Write-Host "The directory `"$dir`" has been deleted"
        } else {
            Write-Host "Directory: `"$dir`" does not exists"
        }
    } else {
        Write-Host "No directory provided"
    }
}

#           _ _
#     /\   | (_)
#    /  \  | |_  __ _ ___  ___  ___
#   / /\ \ | | |/ _` / __|/ _ \/ __|
#  / ____ \| | | (_| \__ \  __/\__ \
# /_/    \_\_|_|\__,_|___/\___||___/
#

New-Alias -Name vim -Value nvim
New-Alias -Name config-nvim -Value ConfigNvim

