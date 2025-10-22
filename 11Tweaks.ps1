# Windows 11 Easy Setup Script
# 
# This script is provided under the public domain.


# TODO:
# -[x] Add Toggle Rounded Corners 
# -[x] Rename Windows Tools Startmenu folder
# -[ ] Apply LocalizedResourceName
# -[x] Add license text



if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run as Administrator."
    exit
}

# Global variable
$USE_WGET = "0"


Write-Host "Welcome to Windows 11 Easy Setup Script!"

#Remove unwanted Appx Packages.

$YESORNO = Read-Host "Do you want to remove Teams?(Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
    Get-AppxPackage -allusers "*Teams*" | Remove-AppxPackage
}
$YESORNO = Read-Host "Do you want to remove Outlook?(Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
    Get-AppxPackage -allusers "*Outlook*" | Remove-AppxPackage
}
$YESORNO = Read-Host "Do you want to remove DevHome?(Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
    Get-AppxPackage -allusers "*DevHome*" | Remove-AppxPackage
}
$YESORNO = Read-Host "Do you want to remove WebExperience?(y/C/n, C will remove from only current user): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N" -and $YESORNO -ne "y" -and $YESORNO -ne "Y") {
    Get-AppxPackage "*WebExperience*" | Remove-AppxPackage
}elseif ($YESORNO -eq "y" -or $YESORNO -eq "Y") {
     Get-AppxPackage -allusers "*WebExperience*" | Remove-AppxPackage
}

# Download essential softwares.

$YESORNO = Read-Host "Do you want to download the real Wget?(Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
    New-Item -Force -Path "C:\Program Files\Wget" -ItemType "Directory"
    Invoke-WebRequest -Uri "https://eternallybored.org/misc/wget/1.21.4/64/wget.exe" -OutFile "C:\Program Files\Wget\wget.exe"
    $PATH_OLD = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path
    $PATH_NEW = $PATH_OLD + ';C:\Program Files\Wget'
    Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $PATH_NEW
    $YESORNO = Read-Host "Do you want to use the real Wget for faster download?(Y/n): "
    if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
        $USE_WGET="1"
    }
} elseif (Test-Path -Path "C:\Program Files\Wget\wget.exe") {
    $YESORNO = Read-Host "Do you want to use the real Wget for faster download?(Y/n): "
    if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
        $USE_WGET="1"
    }
}

$YESORNO = Read-Host "Do you want to download Firefox?(Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
    $YESORNO = Read-Host "日本語版をダウンロードしますか? (Do you want to download Japanese version?(y/N) "
    if ($YESORNO -eq "Y" -or $YESORNO -eq "y") {
        $DLURI = "https://download.mozilla.org/?product=firefox-stub&os=win64&lang=ja"
    } else {
        $DLURI = "https://download.mozilla.org/?product=firefox-stub&os=win64"
    }
    if ($USE_WGET -eq "1") {
        & "C:\Program Files\Wget\wget.exe" -O "$HOME\Downloads\FirefoxSetup.exe" $DLURI
    } else {
        Invoke-WebRequest -UseBasicParsing -Uri $DLURI -OutFile "$HOME\Downloads\FirefoxSetup.exe"
    }
    Start-Process "$HOME\Downloads\FirefoxSetup.exe"
}
$YESORNO = Read-Host "Do you want to install Remove-MSEdge?(Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
    New-Item -Force -Path "C:\Program Files\Remove-Edge" -ItemType "Directory"
    Add-MpPreference -ExclusionPath "C:\Program Files\Remove-Edge\Remove-Edge.exe"
    if ($USE_WGET -eq "1") {
        & "C:\Program Files\Wget\wget.exe" -O "C:\Program Files\Remove-Edge\Remove-Edge.exe" "https://github.com/ShadowWhisperer/Remove-MS-Edge/releases/latest/download/Remove-Edge.exe"
    } else {
        Invoke-Webrequest -Uri "https://github.com/ShadowWhisperer/Remove-MS-Edge/releases/latest/download/Remove-Edge.exe" -OutFile "C:\Program Files\Remove-Edge\Remove-Edge.exe"
    }
    $TSAction = New-ScheduledTaskAction -Execute "C:\Program Files\Remove-Edge\Remove-Edge.exe"
    $TSTrigger = New-ScheduledTaskTrigger -AtStartup
    $TSSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable -RestartCount 5 -RestartInterval (New-TimeSpan -Minutes 1)
    $TSPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
    $TSTask = New-ScheduledTask -Action $TSAction -Principal $TSPrincipal -Trigger $TSTrigger -Settings $TSSettings
    Register-ScheduledTask "Remove-Edge" -InputObject $TSTask
    $YESORNO = Read-Host "Do you want to remove Microsoft Edge now?(Y/n): "
    if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
        Start-ScheduledTask -TaskName "Remove-Edge"
    }
}
$YESORNO = Read-Host "Do you want to install MSEdge Redirect?(Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
    if ($USE_WGET -eq "1") {
        & "C:\Program Files\Wget\wget.exe" -O "$HOME\Downloads\MSEdgeRedirect.exe" "https://github.com/rcmaehl/MSEdgeRedirect/releases/latest/download/MSEdgeRedirect.exe"
    } else {
        Invoke-WebRequest -Uri "https://github.com/rcmaehl/MSEdgeRedirect/releases/latest/download/MSEdgeRedirect.exe" -OutFile "$HOME\Downloads\MSEdgeRedirect.exe"
    }
    Start-Process "$HOME\Downloads\MSEdgeRedirect.exe"
}

#$YESORNO = Read-Host "Do you want to disable the window rounded corners?(Y/n): "
#if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
#    Write-Host "Win11 Toggle Rounded Corners will downloaded. Please install it. The rounded corners are disabled."
#    Invoke-WebRequest -Uri "https://github.com/rich-ayr/win11-toggle-rounded-corners/releases/download/v1.2/win11-toggle-rounded-corners-setup.exe" -OutFile "$HOME\Downloads\win11-toggle-rounded-corners-setup.exe"
#    Start-Process "$HOME\Downloads\win11-toggle-rounded-corners-setup.exe"
#}

# Registory tweaks
$YESORNO = Read-Host "Do you want to disable Web search on taskbar?(Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
    New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force
    New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -PropertyType "DWORD" -Value 1 -Name "DisableSearchBoxSuggestions" -Force
}
$YESORNO = Read-Host "Do you want to get back the Windows 10-style Control Center?(Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Center" -Force
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Center" -PropertyType "DWORD" -Value 1 -Name "UseLiteLayout" -Force
}

# Move Startmenu folders
$YESORNO = Read-Host "Do you want to get back the Windows Tools folder in start menu?(Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
    $DESTACCESS="WindowsAccessories"
    $DESTSYSTOOL="SystemTools"
    $DESTADMTOOL="Administrative Tools"
    $YESORNO = Read-Host "フォルダ名に日本語を使用しますか? (Do you want to use Japanese for the destination folder name?) (y/N)"
    if ($YESORNO -eq "y" -or $YESORNO -eq "Y") {
        $DESTACCESS="WindowsWindowsアクセサリ"
        $DESTSYSTOOL="Windowsシステムツール"
        $DESTADMTOOL="Windows管理ツール"
    }
    New-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTACCESS" -ItemType "Directory" -Force
    New-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL" -ItemType "Directory" -Force
    New-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTADMTOOL" -ItemType "Directory" -Force
    # System Folder
    Move-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories\*" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTACCESS" -Force
    Move-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\System Tools\*" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL" -Force
    Move-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Administrative Tools\*" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTADMTOOL" -Force
    # User Folder
    Move-Item -Path "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Accessories\" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTACCESS" -Force
    Move-Item -Path "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\System Tools\*" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL" -Force
    Move-Item -Path "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Administrative Tools\*" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTADMTOOL" -Force
}

# Install ExplorerPatcher
$YESORNO = Read-Host "Do you want to Install ExplorerPatcher?(Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
    Add-MpPreference -ExclusionPath "C:\Program Files\ExplorerPatcher"
    Add-MpPreference -ExclusionPath "$env:APPDATA\ExplorerPatcher"
    Add-MpPreference -ExclusionPath "C:\Windows\dxgi.dll"
    Add-MpPreference -ExclusionPath "C:\Windows\SystemApps\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy"
    Add-MpPreference -ExclusionPath "C:\Windows\SystemApps\ShellExperienceHost_cw5n1h2txyewy"
    if ($USE_WGET -eq "1") {
        & "C:\Program Files\Wget\wget.exe" -O "$HOME\Downloads\ep_setup.exe" "https://github.com/valinet/ExplorerPatcher/releases/latest/download/ep_setup.exe"
    } else {
        Invoke-WebRequest -Uri "https://github.com/valinet/ExplorerPatcher/releases/latest/download/ep_setup.exe" -OutFile "$HOME\Downloads\ep_setup.exe"
    }
    Start-Process "$HOME\Downloads\ep_setup.exe"
}