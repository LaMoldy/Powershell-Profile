# Aliases
New-Alias -Name vim -Value nvim
New-Alias -Name config-nvim -Value ConfigNvim
New-Alias -Name config-profile -Value ConfigProfile

# Profile Utilities
Function reload { & $PROFILE } # Reloads the profile

Function ConfigProfile {
    Set-Location $env:POWERSHELL_CONFIG # Must have this set as environment variable on the computer
    nvim .
}


# Misc Utilities
Function ConfigNvim {
    Set-Location $env:NVIM_CONFIG # Must have this set as environment variable on the computer
    nvim .
}

Function get-ip {
    $IP = (
        Get-NetIPConfiguration |
        Where-Object {
            $_.IPv4DefaultGateway -ne $null -and
            $_.NetAdapter.Status -ne "Disconnected"
        }
    ).IPv4Address.IPAddress
    Write-Host "IP: $IP"
}


# Development Utilities
Function sve ($project) { # Starts a python virtual environment in the project specified
    If ($args -eq "-h") {
        Write-Host "Usage: sve <python project>`n`nStarts a python virtual environment in the project specified under:`n$HOME\personal folder"
        Return
    }
    $project_path = "$HOME/personal/$project"
    If (Test-Path -Path $project_path) {
        cd "$HOME/personal/$project"
        python -m pipenv shell
    }
    Else {
        Write-Host "There was an error starting the virtual environment."
        Write-Host "Make sure the project exists and is spelled correctly."
        Write-Host "Use sve -h for a more detailed description."
    }
}


# Git Utilities
Function gwip { # Git work in progress
    $current_date_time = Get-Date -Format "ddd MMM dd HH:mm:ss EST yyyy".ToString().Replace(".", "")
    git add .
    git commit -m "$current_date_time"
}

function test-format {
    $date = Get-Date -Format "ddd MMM dd HH:mm:ss EST yyyy"
    Write-Host $date.ToString().Replace(".", "")
}

Function gcom # Commits all changes with a message
{
    git add .
    git commit -m "$args"
}

Function gcomp # Commits and pushes all changes with a message
{
    git add .
    git commit -m "$args"
    git push
}


# Unix Utilities
Function ll { Get-ChildItem -Path $pwd -File } # Lists all files in the current directory
Function which ($command) { Get-Command $command | Select-Object -ExpandProperty Definition } # Gets the path of a command
Function touch ($file) { "" | Out-File $file -Encoding ASCII } # Creates a new file
Function pgrep ($name) { Get-Process $name } # Gets a process by name
Function pkill ($name) { Get-Process $name -ErrorAction SilentlyContinue | Stop-Process } # Kills a process by name

Function grep ($regex, $dir) { # Searches for a pattern in a directory
    If ($dir) {
        Get-ChildItem -Path $dir | Select-String -Pattern $regex
        Return
    }
    $input | Select-String -Pattern $regex
}

Function rf ($dir) {
    if ($null -ne $dir) {
        if (Test-Path $dir) {
            Remove-Item -Path $dir -Recurse -Force
            Write-Host "The directory `"$dir`" has been deleted"
        }
        else {
            Write-Host "Directory: `"$dir`" does not exists"
        }
    }
    else {
        Write-Host "No directory provided"
    }
}
