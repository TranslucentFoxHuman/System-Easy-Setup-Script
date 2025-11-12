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
    $YESORNO = Read-Host "Do you want to download Japanese version?(y/N) "
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
    $DESTADMTOOL="AdministrativeTools"
    $YESORNO = Read-Host "Do you want to use Japanese for the destination folder name? (y/N)"
    if ($YESORNO -eq "y" -or $YESORNO -eq "Y") {
        $DESTACCESS="WindowsWindowsアクセサリ"
        $DESTSYSTOOL="Windowsシステムツール"
        $DESTADMTOOL="Windows管理ツール"
    }
    #Accessories
    New-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTACCESS" -ItemType "Directory" -Force
    
    #System Tools
    New-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL" -ItemType "Directory" -Force
    New-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL\desktop.ini" -ItemType "File" -Force
    [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("W0xvY2FsaXplZEZpbGVOYW1lc10NClRhc2sgTWFuYWdlci5sbms9QCVTeXN0ZW1Sb290JVxzeXN0ZW0zMlxUYXNrbWdyLmV4ZSwtMzI0MjANCkNvbW1hbmQgUHJvbXB0Lmxuaz1AJVN5c3RlbVJvb3QlXHN5c3RlbTMyXHNoZWxsMzIuZGxsLC0yMjAyMg0KUnVuLmxuaz1AJVN5c3RlbVJvb3QlXHN5c3RlbTMyXHNoZWxsMzIuZGxsLC0xMjcxMA0KQ29udHJvbCBQYW5lbC5sbms9QCVTeXN0ZW1Sb290JVxzeXN0ZW0zMlxzaGVsbDMyLmRsbCwtMTI3MTINCg==")) | Out-File "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL\desktop.ini"
    Move-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories\*.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTACCESS" -Force
    Move-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\System Tools\*.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL" -Force
    $fobj = Get-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL"
    $fobj.Attributes = "System"
    $fobj = Get-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL/desktop.ini"
    $fobj.Attributes = "System", "Hidden"
    
    # Administrative tools
    New-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTADMTOOL" -ItemType "Directory" -Force
    New-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTADMTOOL\desktop.ini" -ItemType "File" -Force
    [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("W0xvY2FsaXplZEZpbGVOYW1lc10NCmlTQ1NJIEluaXRpYXRvci5sbms9QCVTeXN0ZW1Sb290JVxzeXN0ZW0zMlxpc2NzaWNwbC5kbGwsLTUwMDENCk9EQkMgRGF0YSBTb3VyY2VzICgzMi1iaXQpLmxuaz1AJVN5c3RlbVJvb3QlXHN5c3dvdzY0XG9kYmNpbnQuZGxsLC0xNjkzDQpPREJDIERhdGEgU291cmNlcyAoNjQtYml0KS5sbms9QCVTeXN0ZW1Sb290JVxzeXN0ZW0zMlxvZGJjaW50LmRsbCwtMTY5NA0KTWVtb3J5IERpYWdub3N0aWNzIFRvb2wubG5rPUAlU3lzdGVtUm9vdCVcc3lzdGVtMzJcTWRTY2hlZC5leGUsLTQwMDENCkV2ZW50IFZpZXdlci5sbms9QCVTeXN0ZW1Sb290JVxzeXN0ZW0zMlxtaWd1aXJlc291cmNlLmRsbCwtMTAxDQpDb21wdXRlciBNYW5hZ2VtZW50Lmxuaz1AJVN5c3RlbVJvb3QlXHN5c3RlbTMyXG15Y29tcHV0LmRsbCwtMzAwDQpDb21wb25lbnQgU2VydmljZXMubG5rPUAlc3lzdGVtcm9vdCVcc3lzdGVtMzJcY29tcmVzLmRsbCwtMzQxMA0Kc2VydmljZXMubG5rPUAlc3lzdGVtcm9vdCVcc3lzdGVtMzJcZmlsZW1nbXQuZGxsLC0yMjA0DQpTeXN0ZW0gQ29uZmlndXJhdGlvbi5sbms9QCVzeXN0ZW1yb290JVxzeXN0ZW0zMlxtc2NvbmZpZy5leGUsLTUwMDYNClN5c3RlbSBJbmZvcm1hdGlvbi5sbms9QCVzeXN0ZW1yb290JVxzeXN0ZW0zMlxtc2luZm8zMi5leGUsLTEwMA0KV2luZG93cyBEZWZlbmRlciBGaXJld2FsbCB3aXRoIEFkdmFuY2VkIFNlY3VyaXR5Lmxuaz1AJVN5c3RlbVJvb3QlXFN5c3RlbTMyXEF1dGhGV0dQLmRsbCwtMjANClRhc2sgU2NoZWR1bGVyLmxuaz1AJVN5c3RlbVJvb3QlXHN5c3RlbTMyXG1pZ3VpcmVzb3VyY2UuZGxsLC0yMDENCkRpc2sgQ2xlYW51cC5sbms9QCVTeXN0ZW1Sb290JVxzeXN0ZW0zMlxzaGVsbDMyLmRsbCwtMjIwMjYNCmRmcmd1aS5sbms9QCVzeXN0ZW1yb290JVxzeXN0ZW0zMlxkZnJndWkuZXhlLC0xMDMNClBlcmZvcm1hbmNlIE1vbml0b3IubG5rPUAlU3lzdGVtUm9vdCVcc3lzdGVtMzJcd2RjLmRsbCwtMTAwMjENClJlc291cmNlIE1vbml0b3IubG5rPUAlU3lzdGVtUm9vdCVcc3lzdGVtMzJcd2RjLmRsbCwtMTAwMzANClJlZ2lzdHJ5IEVkaXRvci5sbms9QCVTeXN0ZW1Sb290JVxyZWdlZGl0LmV4ZSwtMTYNClNlY3VyaXR5IENvbmZpZ3VyYXRpb24gTWFuYWdlbWVudC5sbms9QCVTeXN0ZW1Sb290JVxzeXN0ZW0zMlx3c2VjZWRpdC5kbGwsLTcxOA0KUHJpbnQgTWFuYWdlbWVudC5sbms9QCVzeXN0ZW1yb290JVxzeXN0ZW0zMlxwbWNzbmFwLmRsbCwtNzAwDQpSZWNvdmVyeURyaXZlLmxuaz1AJXN5c3RlbXJvb3QlXHN5c3RlbTMyXFJlY292ZXJ5RHJpdmUuZXhlLC01MDANCg==")) | Out-File "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTADMTOOL\desktop.ini"
    Move-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Administrative Tools\*.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTADMTOOL" -Force
    Move-Item -Path "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Administrative Tools\*.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTADMTOOL" -Force
    $fobj = Get-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTADMTOOL"
    $fobj.Attributes = "System"
    $fobj = Get-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTADMTOOL\desktop.ini"
    $fobj.Attributes = "System", "Hidden"
    
    # System Folder
    # User Folder
    Move-Item -Path "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Accessories\" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTACCESS" -Force
    Move-Item -Path "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\System Tools\*" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL" -Force
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