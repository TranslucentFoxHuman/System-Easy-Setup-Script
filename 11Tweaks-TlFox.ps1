# Windows 11 Easy Setup Script
# Copyright (C) 2026 TlFoxhuman
# This script is provided under the MIT License. For more information, please see LICESE file.

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run as Administrator."
    exit
}

# Global variable
$USE_WGET = "0"
$CURL_EXEC="C:\Program Files\curl\bin\curl.exe"


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

$YESORNO = Read-Host "Do you want to download the real curl?(Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
	New-Item -Force -Path "$env:TEMP\curl" -ItemType "Directory"
	Invoke-Webrequest -Uri "https://curl.se/windows/latest.cgi?p=win64-mingw.zip" -OutFile "$HOME\Downloads\curl.zip"
	Expand-Archive "$HOME\Downloads\curl.zip" -DestinationPath "$env:TEMP\curl"
	Rename-Item (Get-ChildItem -Directory "$env:TEMP\curl\curl*" | Select-Object -First 1) "curl"
	Copy-Item -Path "$env:TEMP\curl\curl" -Destination "C:\Program Files\" -Force -Recurse
	Remove-Item -Path "$env:TEMP\curl" -Recurse -Force
	$PATH_OLD = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path
    $PATH_NEW = $PATH_OLD + ';C:\Program Files\curl\bin'
    Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $PATH_NEW
    $YESORNO = Read-Host "Do you want to disable `"curl`" alias of Invoke-WebRequest? This sets the ExecutionPolicy to `"RemoteSigned`" if the current Executionpolicy is `"Allsigned`", `"Restricted`", `"Default`" or `"Undefined`". (Y/n)"
    if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
        $policy = Get-ExecutionPolicy -Scope LocalMachine
        if ($policy -eq 'Restricted' -or $policy -eq 'Undefined' -or $policy -eq 'AllSigned' -or $policy -eq 'Default') {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
        }
        if (Test-Path -Path "$PSHOME\Microsoft.PowerShell_profile.ps1") {
            $psprofile = Get-Content -Path "$PSHOME\Microsoft.PowerShell_profile.ps1"
            $found_rmcurl="0"
            foreach ($line in $psprofile) {
                if ($line -match "Remove-Item alias:curl") {
                    $found_rmcurl="1"
                    break
                }
            }
            if ($found_rmcurl -ne "1") {
                Add-Content -Path "$PSHOME\Microsoft.PowerShell_profile.ps1" -Value "Remove-Item alias:curl"
                Remove-Item alias:curl
            }
        } else {
            Add-Content -Path "$PSHOME\Microsoft.PowerShell_profile.ps1" -Value "Remove-Item alias:curl"
            Remove-Item alias:curl
        }
    }

    $YESORNO = Read-Host "Do you want to use the real curl for faster download?(Y/n): "
    if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
        $USE_WGET="1"
    }
} elseif (Test-Path -Path "C:\Program Files\curl\bin\curl.exe") {
    $YESORNO = Read-Host "Do you want to use the real curl for faster download?(Y/n): "
    if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
        $USE_WGET="1"
    }
}

$YESORNO = Read-Host "Do you want to use winget to download the latest version if available?(Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
    $USE_WINGET = "1"
}

$YESORNO = Read-Host "Do you want to Download LibreWolf?(Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
    if ($USE_WINGET -ne "1") {
        Write-Host "LibreWolf 147.0.3-2 will downloaded. Please run LibreWolf WinUpdater after installing this."
    }
    $LIBREWOLF_URL="https://codeberg.org/api/packages/librewolf/generic/librewolf/147.0.3-2/librewolf-147.0.3-2-windows-x86_64-setup.exe"
    $LIBREWOLF_EXE="librewolf-147.0.3-2-windows-x86_64-setup.exe"
    if ($USE_WINGET -eq "1") {
        & winget install LibreWolf.LibreWolf --source winget
        if ($USE_WGET -eq "1") {
            & $CURL_EXEC -L -o "$env:Temp\librewolf-winupd.zip" "https://codeberg.org/ltguillaume/librewolf-winupdater/releases/download/1.12.1/LibreWolf-WinUpdater_1.12.1.zip"
        } else {
            Invoke-WebRequest -UseBasicParsing -Uri "https://codeberg.org/ltguillaume/librewolf-winupdater/releases/download/1.12.1/LibreWolf-WinUpdater_1.12.1.zip" -OutFile "$env:Temp\librewolf-winupd.zip"
        }
        New-Item -Force -Path "$env:TEMP\librewolf-winupd" -ItemType Directory
        Expand-Archive "$env:Temp\librewolf-winupd.zip" -DestinationPath "$env:Temp\librewolf-winupd"
        Copy-Item -Path "$env:Temp\librewolf-winupd\*" -Destination "C:\Program Files\LibreWolf" -Force -Recurse
        $WSCShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WSCShell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\LibreWolf\LibreWolf WinUpdater.lnk")
        $Shortcut.TargetPath = "C:\Program Files\LibreWolf\LibreWolf-WinUpdater.exe"
        $Shortcut.Save()
        Remove-Item -Path "$env:Temp\librewolf-winupd.zip" -Force -Recurse
        Remove-Item -Path "$env:Temp\librewolf-winupd" -Force -Recurse
    } elseif ($USE_WGET -eq "1") {
        & $CURL_EXEC -L -o "$HOME\Downloads\$LIBREWOLF_EXE" "$LIBREWOLF_URL"
        Start-Process "$HOME\Downloads\$LIBREWOLF_EXE"
    } else {
        Invoke-WebRequest -UseBasicParsing -Uri "$LIBREWOLF_URL" -OutFile "$HOME\Downloads\$LIBREWOLF_EXE"
        Start-Process "$HOME\Downloads\$LIBREWOLF_EXE"
    }
    
}

$YESORNO = Read-Host "Do you want to install Remove-MSEdge?(Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
    New-Item -Force -Path "C:\Program Files\Remove-Edge" -ItemType "Directory"
    Add-MpPreference -ExclusionPath "C:\Program Files\Remove-Edge\Remove-Edge.exe"
    if ($USE_WGET -eq "1") {
        & $CURL_EXEC -L -o "C:\Program Files\Remove-Edge\Remove-Edge.exe" "https://github.com/ShadowWhisperer/Remove-MS-Edge/releases/latest/download/Remove-Edge.exe"
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
        & $CURL_EXEC -L -o "$HOME\Downloads\MSEdgeRedirect.exe" "https://github.com/rcmaehl/MSEdgeRedirect/releases/latest/download/MSEdgeRedirect.exe"
    } else {
        Invoke-WebRequest -Uri "https://github.com/rcmaehl/MSEdgeRedirect/releases/latest/download/MSEdgeRedirect.exe" -OutFile "$HOME\Downloads\MSEdgeRedirect.exe"
    }
    Start-Process "$HOME\Downloads\MSEdgeRedirect.exe"
}
$YESORNO = Read-Host "Do you want to install 7-Zip? (Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
    if ($USE_WINGET -eq "1") {
        & winget install 7zip.7zip --source winget
    } elseif ($USE_WGET -eq "1") {
        & $CURL_EXEC -L -o "$HOME\Downloads\7z2501-x64.exe" "https://7-zip.org/a/7z2501-x64.exe"
        Start-Process "$HOME\Downloads\7z2501-x64.exe"
    } else {
        Invoke-WebRequest -Uri "https://7-zip.org/a/7z2501-x64.exe" -OutFile "$HOME\Downloads\7z2501-x64.exe"
        Start-Process "$HOME\Downloads\7z2501-x64.exe"
    } 
}

$YESORNO = Read-Host "Do you want to install AIM Tookit? (It's successor of ImDisk Toolkit.)(Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
    if ($USE_WGET -eq "1") {
        & $CURL_EXEC -L -o "$HOME\Downloads\AIMtk.zip" "https://twds.dl.sourceforge.net/project/aim-toolkit/20251223/AIMtk.zip?viasf=1"
    } else {
        Invoke-WebRequest -Uri "https://twds.dl.sourceforge.net/project/aim-toolkit/20251223/AIMtk.zip?viasf=1" -OutFile "$HOME\Downloads\AIMtk.zip"
    }
    Expand-Archive "$HOME\Downloads\AIMtk.zip" -DestinationPath "$HOME\Downloads\AIMtk"
    Start-Process "$HOME\Downloads\AIMtk\AIMtk20251223\install.bat"
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
$YESORNO = Read-Host "Do you want to disable fast startup(Y/n)?"
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
	Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name HiberbootEnabled -Value 0
}

# Move Startmenu folders
$YESORNO = Read-Host "Do you want to get back the Administrative Tools folder in start menu?(Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
    $DESTACCESS="WindowsAccessories"
    $DESTSYSTOOL="SystemTools"
    $DESTADMTOOL="AdministrativeTools"
    # $YESORNO = Read-Host "Do you want to use Japanese for the destination folder name? (y/N)"
    if ((Get-UICulture).Name -eq "ja-JP") { # Detect system language.
        $DESTACCESS="Windowsアクセサリ"
        $DESTSYSTOOL="Windowsシステムツール"
        $DESTADMTOOL="Windows管理ツール"
    }
    #Accessories
    New-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTACCESS" -ItemType "Directory" -Force
    Copy-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories\*" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTACCESS" -Force -Recurse
    Copy-Item -Path "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Accessories\*.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTACCESS" -Force -Recurse
    Remove-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories\" -Force -Recurse
    Remove-Item -Path "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Accessories\" -Force -Recurse
    Remove-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTACCESS\desktop.ini" -Force
    New-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTACCESS\desktop.ini" -ItemType "File" -Force
    [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("W0xvY2FsaXplZEZpbGVOYW1lc10NCldpbmRvd3MgTWVkaWEgUGxheWVyIExlZ2FjeS5sbms9QCVzeXN0ZW1yb290JVxzeXN3b3c2NFx3bXBsb2MuZGxsLC0xMDINClN0ZXBzIFJlY29yZGVyLmxuaz1AJVN5c3RlbVJvb3QlXHN5c3RlbTMyXHBzci5leGUsLTE3MDENClJlbW90ZSBEZXNrdG9wIENvbm5lY3Rpb24ubG5rPUAlU3lzdGVtUm9vdCVcc3lzdGVtMzJcbXN0c2MuZXhlLC00MDAwDQo=")) | Out-File "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTACCESS\desktop.ini" -Force
    $fobj = Get-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTACCESS"
    $fobj.Attributes = "System"
    $fobj = Get-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTACCESS\desktop.ini"
    $fobj.Attributes = "System", "Hidden"
    
    #System Tools
    New-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL" -ItemType "Directory" -Force
    Copy-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\System Tools\*.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL" -Force -Recurse
    Copy-Item -Path "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\System Tools\*" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL" -Force -Recurse
    Remove-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\System Tools\" -Force -Recurse
    Remove-Item -Path "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\System Tools\" -Force -Recurse
    Remove-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL\desktop.ini" -Force
    New-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL\desktop.ini" -ItemType "File" -Force
    [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("W0xvY2FsaXplZEZpbGVOYW1lc10NClRhc2sgTWFuYWdlci5sbms9QCVTeXN0ZW1Sb290JVxzeXN0ZW0zMlxUYXNrbWdyLmV4ZSwtMzI0MjANCkNvbW1hbmQgUHJvbXB0Lmxuaz1AJVN5c3RlbVJvb3QlXHN5c3RlbTMyXHNoZWxsMzIuZGxsLC0yMjAyMg0KUnVuLmxuaz1AJVN5c3RlbVJvb3QlXHN5c3RlbTMyXHNoZWxsMzIuZGxsLC0xMjcxMA0KQ29udHJvbCBQYW5lbC5sbms9QCVTeXN0ZW1Sb290JVxzeXN0ZW0zMlxzaGVsbDMyLmRsbCwtMTI3MTINCg==")) | Out-File "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL\desktop.ini" -Force
    #Delete System Tools items from Default user profile. Why are they stored in user's start menu folder?
    Remove-Item "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\System Tools\*"
    $fobj = Get-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL"
    $fobj.Attributes = "System"
    $fobj = Get-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL/desktop.ini"
    $fobj.Attributes = "System", "Hidden"
    
    # Administrative tools
    New-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTADMTOOL" -ItemType "Directory" -Force
    Copy-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Administrative Tools\*.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTADMTOOL" -Force -Recurse
    Copy-Item -Path "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Administrative Tools\*.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTADMTOOL" -Force -Recurse
    Remove-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Administrative Tools\" -Force -Recurse
    Remove-Item -Path "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Administrative Tools\" -Force -Recurse
    Remove-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTADMTOOL\desktop.ini" -Force
    New-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTADMTOOL\desktop.ini" -ItemType "File" -Force
    [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("W0xvY2FsaXplZEZpbGVOYW1lc10NCmlTQ1NJIEluaXRpYXRvci5sbms9QCVTeXN0ZW1Sb290JVxzeXN0ZW0zMlxpc2NzaWNwbC5kbGwsLTUwMDENCk9EQkMgRGF0YSBTb3VyY2VzICgzMi1iaXQpLmxuaz1AJVN5c3RlbVJvb3QlXHN5c3dvdzY0XG9kYmNpbnQuZGxsLC0xNjkzDQpPREJDIERhdGEgU291cmNlcyAoNjQtYml0KS5sbms9QCVTeXN0ZW1Sb290JVxzeXN0ZW0zMlxvZGJjaW50LmRsbCwtMTY5NA0KTWVtb3J5IERpYWdub3N0aWNzIFRvb2wubG5rPUAlU3lzdGVtUm9vdCVcc3lzdGVtMzJcTWRTY2hlZC5leGUsLTQwMDENCkV2ZW50IFZpZXdlci5sbms9QCVTeXN0ZW1Sb290JVxzeXN0ZW0zMlxtaWd1aXJlc291cmNlLmRsbCwtMTAxDQpDb21wdXRlciBNYW5hZ2VtZW50Lmxuaz1AJVN5c3RlbVJvb3QlXHN5c3RlbTMyXG15Y29tcHV0LmRsbCwtMzAwDQpDb21wb25lbnQgU2VydmljZXMubG5rPUAlc3lzdGVtcm9vdCVcc3lzdGVtMzJcY29tcmVzLmRsbCwtMzQxMA0Kc2VydmljZXMubG5rPUAlc3lzdGVtcm9vdCVcc3lzdGVtMzJcZmlsZW1nbXQuZGxsLC0yMjA0DQpTeXN0ZW0gQ29uZmlndXJhdGlvbi5sbms9QCVzeXN0ZW1yb290JVxzeXN0ZW0zMlxtc2NvbmZpZy5leGUsLTUwMDYNClN5c3RlbSBJbmZvcm1hdGlvbi5sbms9QCVzeXN0ZW1yb290JVxzeXN0ZW0zMlxtc2luZm8zMi5leGUsLTEwMA0KV2luZG93cyBEZWZlbmRlciBGaXJld2FsbCB3aXRoIEFkdmFuY2VkIFNlY3VyaXR5Lmxuaz1AJVN5c3RlbVJvb3QlXFN5c3RlbTMyXEF1dGhGV0dQLmRsbCwtMjANClRhc2sgU2NoZWR1bGVyLmxuaz1AJVN5c3RlbVJvb3QlXHN5c3RlbTMyXG1pZ3VpcmVzb3VyY2UuZGxsLC0yMDENCkRpc2sgQ2xlYW51cC5sbms9QCVTeXN0ZW1Sb290JVxzeXN0ZW0zMlxzaGVsbDMyLmRsbCwtMjIwMjYNCmRmcmd1aS5sbms9QCVzeXN0ZW1yb290JVxzeXN0ZW0zMlxkZnJndWkuZXhlLC0xMDMNClBlcmZvcm1hbmNlIE1vbml0b3IubG5rPUAlU3lzdGVtUm9vdCVcc3lzdGVtMzJcd2RjLmRsbCwtMTAwMjENClJlc291cmNlIE1vbml0b3IubG5rPUAlU3lzdGVtUm9vdCVcc3lzdGVtMzJcd2RjLmRsbCwtMTAwMzANClJlZ2lzdHJ5IEVkaXRvci5sbms9QCVTeXN0ZW1Sb290JVxyZWdlZGl0LmV4ZSwtMTYNClNlY3VyaXR5IENvbmZpZ3VyYXRpb24gTWFuYWdlbWVudC5sbms9QCVTeXN0ZW1Sb290JVxzeXN0ZW0zMlx3c2VjZWRpdC5kbGwsLTcxOA0KUHJpbnQgTWFuYWdlbWVudC5sbms9QCVzeXN0ZW1yb290JVxzeXN0ZW0zMlxwbWNzbmFwLmRsbCwtNzAwDQpSZWNvdmVyeURyaXZlLmxuaz1AJXN5c3RlbXJvb3QlXHN5c3RlbTMyXFJlY292ZXJ5RHJpdmUuZXhlLC01MDANCg==")) | Out-File "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTADMTOOL\desktop.ini" -Force
    $fobj = Get-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTADMTOOL"
    $fobj.Attributes = "System"
    $fobj = Get-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTADMTOOL\desktop.ini"
    $fobj.Attributes = "System", "Hidden"
}

$YESORNO = Read-Host "Do you want to create a start-up task to get back the Administrative Tools folder in start menu?(Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
    New-Item -Path "C:\Program Files\11Tweaks" -ItemType "Directory" -Force
    Remove-Item -Path "C:\Program Files\11Tweaks\RestoreToolsFolder.ps1" -Force
    [IO.File]::WriteAllBytes("C:\Program Files\11Tweaks\RestoreToolsFolder.ps1",[Convert]::FromBase64String("77u/CiMgU3RhbmRhbG9uZSBXaW5kb3dzIEFkbWluaXN0cmF0aXZlIFRvb2xzIEZvbGRlciByZXN0b3JlaW5nIHRvb2wuCiRERVNUQUNDRVNTPSJXaW5kb3dzQWNjZXNzb3JpZXMiCiRERVNUU1lTVE9PTD0iU3lzdGVtVG9vbHMiCiRERVNUQURNVE9PTD0iQWRtaW5pc3RyYXRpdmVUb29scyIKaWYgKChHZXQtVUlDdWx0dXJlKS5OYW1lIC1lcSAiamEtSlAiKSB7ICMgRGV0ZWN0IHN5c3RlbSBsYW5ndWFnZS4KICAgICRERVNUQUNDRVNTPSJXaW5kb3dz44Ki44Kv44K744K144OqIgogICAgJERFU1RTWVNUT09MPSJXaW5kb3dz44K344K544OG44Og44OE44O844OrIgogICAgJERFU1RBRE1UT09MPSJXaW5kb3dz566h55CG44OE44O844OrIgp9CiNBY2Nlc3NvcmllcwpOZXctSXRlbSAtUGF0aCAiQzpcUHJvZ3JhbURhdGFcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1wkREVTVEFDQ0VTUyIgLUl0ZW1UeXBlICJEaXJlY3RvcnkiIC1Gb3JjZQpDb3B5LUl0ZW0gLVBhdGggIkM6XFByb2dyYW1EYXRhXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcQWNjZXNzb3JpZXNcKiIgLURlc3RpbmF0aW9uICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXCRERVNUQUNDRVNTIiAtRm9yY2UgLVJlY3Vyc2UKQ29weS1JdGVtIC1QYXRoICIkSE9NRVxBcHBEYXRhXFJvYW1pbmdcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1xBY2Nlc3Nvcmllc1wqLmxuayIgLURlc3RpbmF0aW9uICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXCRERVNUQUNDRVNTIiAtRm9yY2UgLVJlY3Vyc2UKUmVtb3ZlLUl0ZW0gLVBhdGggIkM6XFByb2dyYW1EYXRhXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcQWNjZXNzb3JpZXNcIiAtRm9yY2UgLVJlY3Vyc2UKUmVtb3ZlLUl0ZW0gLVBhdGggIiRIT01FXEFwcERhdGFcUm9hbWluZ1xNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXEFjY2Vzc29yaWVzXCIgLUZvcmNlIC1SZWN1cnNlClJlbW92ZS1JdGVtIC1QYXRoICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXCRERVNUQUNDRVNTXGRlc2t0b3AuaW5pIiAtRm9yY2UKTmV3LUl0ZW0gLVBhdGggIkM6XFByb2dyYW1EYXRhXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcJERFU1RBQ0NFU1NcZGVza3RvcC5pbmkiIC1JdGVtVHlwZSAiRmlsZSIgLUZvcmNlCltTeXN0ZW0uVGV4dC5FbmNvZGluZ106OlVURjguR2V0U3RyaW5nKFtDb252ZXJ0XTo6RnJvbUJhc2U2NFN0cmluZygiVzB4dlkyRnNhWHBsWkVacGJHVk9ZVzFsYzEwTkNsZHBibVJ2ZDNNZ1RXVmthV0VnVUd4aGVXVnlJRXhsWjJGamVTNXNibXM5UUNWemVYTjBaVzF5YjI5MEpWeHplWE4zYjNjMk5GeDNiWEJzYjJNdVpHeHNMQzB4TURJTkNsTjBaWEJ6SUZKbFkyOXlaR1Z5TG14dWF6MUFKVk41YzNSbGJWSnZiM1FsWEhONWMzUmxiVE15WEhCemNpNWxlR1VzTFRFM01ERU5DbEpsYlc5MFpTQkVaWE5yZEc5d0lFTnZibTVsWTNScGIyNHViRzVyUFVBbFUzbHpkR1Z0VW05dmRDVmNjM2x6ZEdWdE16SmNiWE4wYzJNdVpYaGxMQzAwTURBd0RRbz0iKSkgfCBPdXQtRmlsZSAiQzpcUHJvZ3JhbURhdGFcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1wkREVTVEFDQ0VTU1xkZXNrdG9wLmluaSIgLUZvcmNlCiRmb2JqID0gR2V0LUl0ZW0gIkM6XFByb2dyYW1EYXRhXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcJERFU1RBQ0NFU1MiCiRmb2JqLkF0dHJpYnV0ZXMgPSAiU3lzdGVtIgokZm9iaiA9IEdldC1JdGVtICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXCRERVNUQUNDRVNTXGRlc2t0b3AuaW5pIgokZm9iai5BdHRyaWJ1dGVzID0gIlN5c3RlbSIsICJIaWRkZW4iCgojU3lzdGVtIFRvb2xzCk5ldy1JdGVtIC1QYXRoICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXCRERVNUU1lTVE9PTCIgLUl0ZW1UeXBlICJEaXJlY3RvcnkiIC1Gb3JjZQpDb3B5LUl0ZW0gLVBhdGggIkM6XFByb2dyYW1EYXRhXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcU3lzdGVtIFRvb2xzXCoubG5rIiAtRGVzdGluYXRpb24gIkM6XFByb2dyYW1EYXRhXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcJERFU1RTWVNUT09MIiAtRm9yY2UgLVJlY3Vyc2UKQ29weS1JdGVtIC1QYXRoICIkSE9NRVxBcHBEYXRhXFJvYW1pbmdcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1xTeXN0ZW0gVG9vbHNcKiIgLURlc3RpbmF0aW9uICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXCRERVNUU1lTVE9PTCIgLUZvcmNlIC1SZWN1cnNlClJlbW92ZS1JdGVtIC1QYXRoICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXFN5c3RlbSBUb29sc1wiIC1Gb3JjZSAtUmVjdXJzZQpSZW1vdmUtSXRlbSAtUGF0aCAiJEhPTUVcQXBwRGF0YVxSb2FtaW5nXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcU3lzdGVtIFRvb2xzXCIgLUZvcmNlIC1SZWN1cnNlClJlbW92ZS1JdGVtIC1QYXRoICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXCRERVNUU1lTVE9PTFxkZXNrdG9wLmluaSIgLUZvcmNlCk5ldy1JdGVtIC1QYXRoICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXCRERVNUU1lTVE9PTFxkZXNrdG9wLmluaSIgLUl0ZW1UeXBlICJGaWxlIiAtRm9yY2UKW1N5c3RlbS5UZXh0LkVuY29kaW5nXTo6VVRGOC5HZXRTdHJpbmcoW0NvbnZlcnRdOjpGcm9tQmFzZTY0U3RyaW5nKCJXMHh2WTJGc2FYcGxaRVpwYkdWT1lXMWxjMTBOQ2xSaGMyc2dUV0Z1WVdkbGNpNXNibXM5UUNWVGVYTjBaVzFTYjI5MEpWeHplWE4wWlcwek1seFVZWE5yYldkeUxtVjRaU3d0TXpJME1qQU5Da052YlcxaGJtUWdVSEp2YlhCMExteHVhejFBSlZONWMzUmxiVkp2YjNRbFhITjVjM1JsYlRNeVhITm9aV3hzTXpJdVpHeHNMQzB5TWpBeU1nMEtVblZ1TG14dWF6MUFKVk41YzNSbGJWSnZiM1FsWEhONWMzUmxiVE15WEhOb1pXeHNNekl1Wkd4c0xDMHhNamN4TUEwS1EyOXVkSEp2YkNCUVlXNWxiQzVzYm1zOVFDVlRlWE4wWlcxU2IyOTBKVnh6ZVhOMFpXMHpNbHh6YUdWc2JETXlMbVJzYkN3dE1USTNNVElOQ2c9PSIpKSB8IE91dC1GaWxlICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXCRERVNUU1lTVE9PTFxkZXNrdG9wLmluaSIgLUZvcmNlCiNEZWxldGUgU3lzdGVtIFRvb2xzIGl0ZW1zIGZyb20gRGVmYXVsdCB1c2VyIHByb2ZpbGUuIFdoeSBhcmUgdGhleSBzdG9yZWQgaW4gdXNlcidzIHN0YXJ0IG1lbnUgZm9sZGVyPwpSZW1vdmUtSXRlbSAiQzpcVXNlcnNcRGVmYXVsdFxBcHBEYXRhXFJvYW1pbmdcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1xTeXN0ZW0gVG9vbHNcKiIKJGZvYmogPSBHZXQtSXRlbSAiQzpcUHJvZ3JhbURhdGFcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1wkREVTVFNZU1RPT0wiCiRmb2JqLkF0dHJpYnV0ZXMgPSAiU3lzdGVtIgokZm9iaiA9IEdldC1JdGVtICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXCRERVNUU1lTVE9PTC9kZXNrdG9wLmluaSIKJGZvYmouQXR0cmlidXRlcyA9ICJTeXN0ZW0iLCAiSGlkZGVuIgoKIyBBZG1pbmlzdHJhdGl2ZSB0b29scwpOZXctSXRlbSAtUGF0aCAiQzpcUHJvZ3JhbURhdGFcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1wkREVTVEFETVRPT0wiIC1JdGVtVHlwZSAiRGlyZWN0b3J5IiAtRm9yY2UKQ29weS1JdGVtIC1QYXRoICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXEFkbWluaXN0cmF0aXZlIFRvb2xzXCoubG5rIiAtRGVzdGluYXRpb24gIkM6XFByb2dyYW1EYXRhXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcJERFU1RBRE1UT09MIiAtRm9yY2UgLVJlY3Vyc2UKQ29weS1JdGVtIC1QYXRoICIkSE9NRVxBcHBEYXRhXFJvYW1pbmdcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1xBZG1pbmlzdHJhdGl2ZSBUb29sc1wqLmxuayIgLURlc3RpbmF0aW9uICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXCRERVNUQURNVE9PTCIgLUZvcmNlIC1SZWN1cnNlClJlbW92ZS1JdGVtIC1QYXRoICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXEFkbWluaXN0cmF0aXZlIFRvb2xzXCIgLUZvcmNlIC1SZWN1cnNlClJlbW92ZS1JdGVtIC1QYXRoICIkSE9NRVxBcHBEYXRhXFJvYW1pbmdcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1xBZG1pbmlzdHJhdGl2ZSBUb29sc1wiIC1Gb3JjZSAtUmVjdXJzZQpSZW1vdmUtSXRlbSAtUGF0aCAiQzpcUHJvZ3JhbURhdGFcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1wkREVTVEFETVRPT0xcZGVza3RvcC5pbmkiIC1Gb3JjZQpOZXctSXRlbSAtUGF0aCAiQzpcUHJvZ3JhbURhdGFcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1wkREVTVEFETVRPT0xcZGVza3RvcC5pbmkiIC1JdGVtVHlwZSAiRmlsZSIgLUZvcmNlCltTeXN0ZW0uVGV4dC5FbmNvZGluZ106OlVURjguR2V0U3RyaW5nKFtDb252ZXJ0XTo6RnJvbUJhc2U2NFN0cmluZygiVzB4dlkyRnNhWHBsWkVacGJHVk9ZVzFsYzEwTkNtbFRRMU5KSUVsdWFYUnBZWFJ2Y2k1c2JtczlRQ1ZUZVhOMFpXMVNiMjkwSlZ4emVYTjBaVzB6TWx4cGMyTnphV053YkM1a2JHd3NMVFV3TURFTkNrOUVRa01nUkdGMFlTQlRiM1Z5WTJWeklDZ3pNaTFpYVhRcExteHVhejFBSlZONWMzUmxiVkp2YjNRbFhITjVjM2R2ZHpZMFhHOWtZbU5wYm5RdVpHeHNMQzB4TmprekRRcFBSRUpESUVSaGRHRWdVMjkxY21ObGN5QW9OalF0WW1sMEtTNXNibXM5UUNWVGVYTjBaVzFTYjI5MEpWeHplWE4wWlcwek1seHZaR0pqYVc1MExtUnNiQ3d0TVRZNU5BMEtUV1Z0YjNKNUlFUnBZV2R1YjNOMGFXTnpJRlJ2YjJ3dWJHNXJQVUFsVTNsemRHVnRVbTl2ZENWY2MzbHpkR1Z0TXpKY1RXUlRZMmhsWkM1bGVHVXNMVFF3TURFTkNrVjJaVzUwSUZacFpYZGxjaTVzYm1zOVFDVlRlWE4wWlcxU2IyOTBKVnh6ZVhOMFpXMHpNbHh0YVdkMWFYSmxjMjkxY21ObExtUnNiQ3d0TVRBeERRcERiMjF3ZFhSbGNpQk5ZVzVoWjJWdFpXNTBMbXh1YXoxQUpWTjVjM1JsYlZKdmIzUWxYSE41YzNSbGJUTXlYRzE1WTI5dGNIVjBMbVJzYkN3dE16QXdEUXBEYjIxd2IyNWxiblFnVTJWeWRtbGpaWE11Ykc1clBVQWxjM2x6ZEdWdGNtOXZkQ1ZjYzNsemRHVnRNekpjWTI5dGNtVnpMbVJzYkN3dE16UXhNQTBLYzJWeWRtbGpaWE11Ykc1clBVQWxjM2x6ZEdWdGNtOXZkQ1ZjYzNsemRHVnRNekpjWm1sc1pXMW5iWFF1Wkd4c0xDMHlNakEwRFFwVGVYTjBaVzBnUTI5dVptbG5kWEpoZEdsdmJpNXNibXM5UUNWemVYTjBaVzF5YjI5MEpWeHplWE4wWlcwek1seHRjMk52Ym1acFp5NWxlR1VzTFRVd01EWU5DbE41YzNSbGJTQkpibVp2Y20xaGRHbHZiaTVzYm1zOVFDVnplWE4wWlcxeWIyOTBKVnh6ZVhOMFpXMHpNbHh0YzJsdVptOHpNaTVsZUdVc0xURXdNQTBLVjJsdVpHOTNjeUJFWldabGJtUmxjaUJHYVhKbGQyRnNiQ0IzYVhSb0lFRmtkbUZ1WTJWa0lGTmxZM1Z5YVhSNUxteHVhejFBSlZONWMzUmxiVkp2YjNRbFhGTjVjM1JsYlRNeVhFRjFkR2hHVjBkUUxtUnNiQ3d0TWpBTkNsUmhjMnNnVTJOb1pXUjFiR1Z5TG14dWF6MUFKVk41YzNSbGJWSnZiM1FsWEhONWMzUmxiVE15WEcxcFozVnBjbVZ6YjNWeVkyVXVaR3hzTEMweU1ERU5Da1JwYzJzZ1EyeGxZVzUxY0M1c2JtczlRQ1ZUZVhOMFpXMVNiMjkwSlZ4emVYTjBaVzB6TWx4emFHVnNiRE15TG1Sc2JDd3RNakl3TWpZTkNtUm1jbWQxYVM1c2JtczlRQ1Z6ZVhOMFpXMXliMjkwSlZ4emVYTjBaVzB6TWx4a1puSm5kV2t1WlhobExDMHhNRE1OQ2xCbGNtWnZjbTFoYm1ObElFMXZibWwwYjNJdWJHNXJQVUFsVTNsemRHVnRVbTl2ZENWY2MzbHpkR1Z0TXpKY2QyUmpMbVJzYkN3dE1UQXdNakVOQ2xKbGMyOTFjbU5sSUUxdmJtbDBiM0l1Ykc1clBVQWxVM2x6ZEdWdFVtOXZkQ1ZjYzNsemRHVnRNekpjZDJSakxtUnNiQ3d0TVRBd016QU5DbEpsWjJsemRISjVJRVZrYVhSdmNpNXNibXM5UUNWVGVYTjBaVzFTYjI5MEpWeHlaV2RsWkdsMExtVjRaU3d0TVRZTkNsTmxZM1Z5YVhSNUlFTnZibVpwWjNWeVlYUnBiMjRnVFdGdVlXZGxiV1Z1ZEM1c2JtczlRQ1ZUZVhOMFpXMVNiMjkwSlZ4emVYTjBaVzB6TWx4M2MyVmpaV1JwZEM1a2JHd3NMVGN4T0EwS1VISnBiblFnVFdGdVlXZGxiV1Z1ZEM1c2JtczlRQ1Z6ZVhOMFpXMXliMjkwSlZ4emVYTjBaVzB6TWx4d2JXTnpibUZ3TG1Sc2JDd3ROekF3RFFwU1pXTnZkbVZ5ZVVSeWFYWmxMbXh1YXoxQUpYTjVjM1JsYlhKdmIzUWxYSE41YzNSbGJUTXlYRkpsWTI5MlpYSjVSSEpwZG1VdVpYaGxMQzAxTURBTkNnPT0iKSkgfCBPdXQtRmlsZSAiQzpcUHJvZ3JhbURhdGFcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1wkREVTVEFETVRPT0xcZGVza3RvcC5pbmkiIC1Gb3JjZQokZm9iaiA9IEdldC1JdGVtICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXCRERVNUQURNVE9PTCIKJGZvYmouQXR0cmlidXRlcyA9ICJTeXN0ZW0iCiRmb2JqID0gR2V0LUl0ZW0gIkM6XFByb2dyYW1EYXRhXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcJERFU1RBRE1UT09MXGRlc2t0b3AuaW5pIgokZm9iai5BdHRyaWJ1dGVzID0gIlN5c3RlbSIsICJIaWRkZW4i"))
    $TSAction = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-executionpolicy bypass `"C:\Program`` Files\11Tweaks\RestoreToolsFolder.ps1`""
    $TSTrigger = New-ScheduledTaskTrigger -AtStartup
    $TSSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable -RestartCount 5 -RestartInterval (New-TimeSpan -Minutes 1)
    $TSPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
    $TSTask = New-ScheduledTask -Action $TSAction -Principal $TSPrincipal -Trigger $TSTrigger -Settings $TSSettings
    Register-ScheduledTask "Restore Administrative Tools Folder" -InputObject $TSTask
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
        & $CURL_EXEC -L -o "$HOME\Downloads\ep_setup.exe" "https://github.com/valinet/ExplorerPatcher/releases/latest/download/ep_setup.exe"
    } else {
        Invoke-WebRequest -Uri "https://github.com/valinet/ExplorerPatcher/releases/latest/download/ep_setup.exe" -OutFile "$HOME\Downloads\ep_setup.exe"
    }
    Start-Process "$HOME\Downloads\ep_setup.exe"
}

Write-Host "***This procedure was prepared exclusively for myself, the script developer. Most users don't need this procedure.***"
$YESORNO = Read-Host "Are you a Japanese and using SKK? Do you want to install CorvusSKK?(y/N): "
if($YESORNO -eq "y" -or $YESORNO -eq "Y") {
    if ($USE_WINGET -eq "1") {
        & winget install nathancorvussolis.corvusskk --source winget
    } elseif ($USE_WGET -eq "1") {
        & $CURL_EXEC -L -o "$HOME\Downloads\corvusskk-3.3.1.exe" "https://github.com/nathancorvussolis/corvusskk/releases/download/3.3.1/corvusskk-3.3.1.exe"
    } else {
        Invoke-WebRequest -Uri "https://github.com/nathancorvussolis/corvusskk/releases/download/3.3.1/corvusskk-3.3.1.exe" -OutFile "$HOME\Downloads\corvusskk-3.3.1.exe"
    }
    if ($USE_WGET -eq "1") {
        New-Item -Force -Path "$HOME\AppData\Roaming\CorvusSKK\Dictionaries" -ItemType "Directory"
        & $CURL_EXEC -L -o "$HOME\AppData\Roaming\CorvusSKK\Dictionaries\SKK-JISYO.L" "http://openlab.jp/skk/skk/dic/SKK-JISYO.L"
        & $CURL_EXEC -L -o "$HOME\AppData\Roaming\CorvusSKK\Dictionaries\SKK-JISYO.jinmei" "http://openlab.jp/skk/skk/dic/SKK-JISYO.jinmei"
        & $CURL_EXEC -L -o "$HOME\AppData\Roaming\CorvusSKK\Dictionaries\SKK-JISYO.geo" "http://openlab.jp/skk/skk/dic/SKK-JISYO.geo"
        & $CURL_EXEC -L -o "$HOME\AppData\Roaming\CorvusSKK\Dictionaries\SKK-JISYO.station" "http://openlab.jp/skk/skk/dic/SKK-JISYO.station"
        & $CURL_EXEC -L -o "$HOME\AppData\Roaming\CorvusSKK\Dictionaries\SKK-JISYO.emoji-ja.utf8" "https://github.com/TranslucentFoxHuman/SKK-JISYO.emoji-ja/raw/master/SKK-JISYO.emoji-ja.utf8"
    } else {
        New-Item -Force -Path "$HOME\AppData\Roaming\CorvusSKK\Dictionaries" -ItemType "Directory"
        Invoke-WebRequest -Uri "http://openlab.jp/skk/skk/dic/SKK-JISYO.L" -OutFile "$HOME\AppData\Roaming\CorvusSKK\Dictionaries\SKK-JISYO.L"
        Invoke-WebRequest -Uri "http://openlab.jp/skk/skk/dic/SKK-JISYO.jinmei" -OutFile "$HOME\AppData\Roaming\CorvusSKK\Dictionaries\SKK-JISYO.jinmei"
        Invoke-WebRequest -Uri "http://openlab.jp/skk/skk/dic/SKK-JISYO.geo" -OutFile "$HOME\AppData\Roaming\CorvusSKK\Dictionaries\SKK-JISYO.geo"
        Invoke-WebRequest -Uri "http://openlab.jp/skk/skk/dic/SKK-JISYO.station" -OutFile "$HOME\AppData\Roaming\CorvusSKK\Dictionaries\SKK-JISYO.station"
        Invoke-WebRequest -Uri "https://github.com/TranslucentFoxHuman/SKK-JISYO.emoji-ja/raw/master/SKK-JISYO.emoji-ja.utf8" -OutFile "$HOME\AppData\Roaming\CorvusSKK\Dictionaries\SKK-JISYO.emoji-ja.utf8"
    }
    if ($USE_WINGET -ne "1") {
        Start-Process "$HOME\Downloads\corvusskk-3.3.1.exe"
    }
}
