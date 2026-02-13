# Windows 11 Easy Setup Script
# Copyright (C) 2026 TlFoxhuman
# This script is provided under the MIT License. For more information, please see LICESE file.


# TODO:
# -[x] Add Toggle Rounded Corners 
# -[x] Rename Windows Tools Startmenu folder
# -[x] Apply LocalizedResourceName
# -[x] Add license text



if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run as Administrator."
    exit
}

# Global variable
$USE_WGET = "0"
$USE_WINGET = "0"
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
    # Allsigned, Restricted, Default, Undefined(maybe?) blocks script execution
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

$YESORNO = Read-Host "Do you want to download Firefox?(Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
    if ((Get-UICulture).Name -eq "ja-JP") {
        $DLURI = "https://download.mozilla.org/?product=firefox-stub&os=win64&lang=ja"
    } else {
        $DLURI = "https://download.mozilla.org/?product=firefox-stub&os=win64"
    }
    if ($USE_WGET -eq "1") {
        & $CURL_EXEC -L -o "$HOME\Downloads\FirefoxSetup.exe" $DLURI
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
$YESORNO = Read-Host "Do you want to get back the Windows Tools folder in start menu?(Y/n): "
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
    New-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTACCESS\desktop.ini" -ItemType "File" -Force
    [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("W0xvY2FsaXplZEZpbGVOYW1lc10NCldpbmRvd3MgTWVkaWEgUGxheWVyIExlZ2FjeS5sbms9QCVzeXN0ZW1yb290JVxzeXN3b3c2NFx3bXBsb2MuZGxsLC0xMDINClN0ZXBzIFJlY29yZGVyLmxuaz1AJVN5c3RlbVJvb3QlXHN5c3RlbTMyXHBzci5leGUsLTE3MDENClJlbW90ZSBEZXNrdG9wIENvbm5lY3Rpb24ubG5rPUAlU3lzdGVtUm9vdCVcc3lzdGVtMzJcbXN0c2MuZXhlLC00MDAwDQo=")) | Out-File "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTACCESS\desktop.ini"
    Move-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories\*" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTACCESS" -Force
    Move-Item -Path "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Accessories\*.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTACCESS" -Force
    $fobj = Get-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTACCESS"
    $fobj.Attributes = "System"
    $fobj = Get-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTACCESS\desktop.ini"
    $fobj.Attributes = "System", "Hidden"
    
    #System Tools
    New-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL" -ItemType "Directory" -Force
    New-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL\desktop.ini" -ItemType "File" -Force
    [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("W0xvY2FsaXplZEZpbGVOYW1lc10NClRhc2sgTWFuYWdlci5sbms9QCVTeXN0ZW1Sb290JVxzeXN0ZW0zMlxUYXNrbWdyLmV4ZSwtMzI0MjANCkNvbW1hbmQgUHJvbXB0Lmxuaz1AJVN5c3RlbVJvb3QlXHN5c3RlbTMyXHNoZWxsMzIuZGxsLC0yMjAyMg0KUnVuLmxuaz1AJVN5c3RlbVJvb3QlXHN5c3RlbTMyXHNoZWxsMzIuZGxsLC0xMjcxMA0KQ29udHJvbCBQYW5lbC5sbms9QCVTeXN0ZW1Sb290JVxzeXN0ZW0zMlxzaGVsbDMyLmRsbCwtMTI3MTINCg==")) | Out-File "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL\desktop.ini"
    Move-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\System Tools\*.lnk" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL" -Force
    Move-Item -Path "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\System Tools\*" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$DESTSYSTOOL" -Force
    #Delete System Tools items from Default user profile. Why are they stored in user's start menu folder?
    Remove-Item "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\System Tools\*"
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
    
}
$YESORNO = Read-Host "Do you want to create a start-up task to get back the Administrative Tools folder in start menu?(Y/n): "
if ($YESORNO -ne "n" -and $YESORNO -ne "N") {
    New-Item -Path "C:\Program Files\11Tweaks" -ItemType "Directory" -Force
    [IO.File]::WriteAllBytes("C:\Program Files\11Tweaks\RestoreToolsFolder.ps1",[Convert]::FromBase64String("77u/CiMgU3RhbmRhbG9uZSBXaW5kb3dzIEFkbWluaXN0cmF0aXZlIFRvb2xzIEZvbGRlciByZXN0b3JlaW5nIHRvb2wuCgokREVTVEFDQ0VTUz0iV2luZG93c0FjY2Vzc29yaWVzIgokREVTVFNZU1RPT0w9IlN5c3RlbVRvb2xzIgokREVTVEFETVRPT0w9IkFkbWluaXN0cmF0aXZlVG9vbHMiCmlmICgoR2V0LVVJQ3VsdHVyZSkuTmFtZSAtZXEgImphLUpQIikgewogICAgJERFU1RBQ0NFU1M9IldpbmRvd3PjgqLjgq/jgrvjgrXjg6oiCiAgICAkREVTVFNZU1RPT0w9IldpbmRvd3Pjgrfjgrnjg4bjg6Djg4Tjg7zjg6siCiAgICAkREVTVEFETVRPT0w9IldpbmRvd3PnrqHnkIbjg4Tjg7zjg6siCn0KI0FjY2Vzc29yaWVzCk5ldy1JdGVtIC1QYXRoICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXCRERVNUQUNDRVNTIiAtSXRlbVR5cGUgIkRpcmVjdG9yeSIgLUZvcmNlCk5ldy1JdGVtIC1QYXRoICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXCRERVNUQUNDRVNTXGRlc2t0b3AuaW5pIiAtSXRlbVR5cGUgIkZpbGUiIC1Gb3JjZQpbU3lzdGVtLlRleHQuRW5jb2RpbmddOjpVVEY4LkdldFN0cmluZyhbQ29udmVydF06OkZyb21CYXNlNjRTdHJpbmcoIlcweHZZMkZzYVhwbFpFWnBiR1ZPWVcxbGMxME5DbGRwYm1SdmQzTWdUV1ZrYVdFZ1VHeGhlV1Z5SUV4bFoyRmplUzVzYm1zOVFDVnplWE4wWlcxeWIyOTBKVnh6ZVhOM2IzYzJORngzYlhCc2IyTXVaR3hzTEMweE1ESU5DbE4wWlhCeklGSmxZMjl5WkdWeUxteHVhejFBSlZONWMzUmxiVkp2YjNRbFhITjVjM1JsYlRNeVhIQnpjaTVsZUdVc0xURTNNREVOQ2xKbGJXOTBaU0JFWlhOcmRHOXdJRU52Ym01bFkzUnBiMjR1Ykc1clBVQWxVM2x6ZEdWdFVtOXZkQ1ZjYzNsemRHVnRNekpjYlhOMGMyTXVaWGhsTEMwME1EQXdEUW89IikpIHwgT3V0LUZpbGUgIkM6XFByb2dyYW1EYXRhXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcJERFU1RBQ0NFU1NcZGVza3RvcC5pbmkiCk1vdmUtSXRlbSAtUGF0aCAiQzpcUHJvZ3JhbURhdGFcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1xBY2Nlc3Nvcmllc1wqIiAtRGVzdGluYXRpb24gIkM6XFByb2dyYW1EYXRhXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcJERFU1RBQ0NFU1MiIC1Gb3JjZQpNb3ZlLUl0ZW0gLVBhdGggIiRIT01FXEFwcERhdGFcUm9hbWluZ1xNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXEFjY2Vzc29yaWVzXCoubG5rIiAtRGVzdGluYXRpb24gIkM6XFByb2dyYW1EYXRhXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcJERFU1RBQ0NFU1MiIC1Gb3JjZQokZm9iaiA9IEdldC1JdGVtICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXCRERVNUQUNDRVNTIgokZm9iai5BdHRyaWJ1dGVzID0gIlN5c3RlbSIKJGZvYmogPSBHZXQtSXRlbSAiQzpcUHJvZ3JhbURhdGFcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1wkREVTVEFDQ0VTU1xkZXNrdG9wLmluaSIKJGZvYmouQXR0cmlidXRlcyA9ICJTeXN0ZW0iLCAiSGlkZGVuIgoKI1N5c3RlbSBUb29scwpOZXctSXRlbSAtUGF0aCAiQzpcUHJvZ3JhbURhdGFcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1wkREVTVFNZU1RPT0wiIC1JdGVtVHlwZSAiRGlyZWN0b3J5IiAtRm9yY2UKTmV3LUl0ZW0gLVBhdGggIkM6XFByb2dyYW1EYXRhXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcJERFU1RTWVNUT09MXGRlc2t0b3AuaW5pIiAtSXRlbVR5cGUgIkZpbGUiIC1Gb3JjZQpbU3lzdGVtLlRleHQuRW5jb2RpbmddOjpVVEY4LkdldFN0cmluZyhbQ29udmVydF06OkZyb21CYXNlNjRTdHJpbmcoIlcweHZZMkZzYVhwbFpFWnBiR1ZPWVcxbGMxME5DbFJoYzJzZ1RXRnVZV2RsY2k1c2JtczlRQ1ZUZVhOMFpXMVNiMjkwSlZ4emVYTjBaVzB6TWx4VVlYTnJiV2R5TG1WNFpTd3RNekkwTWpBTkNrTnZiVzFoYm1RZ1VISnZiWEIwTG14dWF6MUFKVk41YzNSbGJWSnZiM1FsWEhONWMzUmxiVE15WEhOb1pXeHNNekl1Wkd4c0xDMHlNakF5TWcwS1VuVnVMbXh1YXoxQUpWTjVjM1JsYlZKdmIzUWxYSE41YzNSbGJUTXlYSE5vWld4c016SXVaR3hzTEMweE1qY3hNQTBLUTI5dWRISnZiQ0JRWVc1bGJDNXNibXM5UUNWVGVYTjBaVzFTYjI5MEpWeHplWE4wWlcwek1seHphR1ZzYkRNeUxtUnNiQ3d0TVRJM01USU5DZz09IikpIHwgT3V0LUZpbGUgIkM6XFByb2dyYW1EYXRhXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcJERFU1RTWVNUT09MXGRlc2t0b3AuaW5pIgpNb3ZlLUl0ZW0gLVBhdGggIkM6XFByb2dyYW1EYXRhXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcU3lzdGVtIFRvb2xzXCoubG5rIiAtRGVzdGluYXRpb24gIkM6XFByb2dyYW1EYXRhXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcJERFU1RTWVNUT09MIiAtRm9yY2UKTW92ZS1JdGVtIC1QYXRoICIkSE9NRVxBcHBEYXRhXFJvYW1pbmdcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1xTeXN0ZW0gVG9vbHNcKiIgLURlc3RpbmF0aW9uICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXCRERVNUU1lTVE9PTCIgLUZvcmNlCiRmb2JqID0gR2V0LUl0ZW0gIkM6XFByb2dyYW1EYXRhXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcJERFU1RTWVNUT09MIgokZm9iai5BdHRyaWJ1dGVzID0gIlN5c3RlbSIKJGZvYmogPSBHZXQtSXRlbSAiQzpcUHJvZ3JhbURhdGFcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1wkREVTVFNZU1RPT0wvZGVza3RvcC5pbmkiCiRmb2JqLkF0dHJpYnV0ZXMgPSAiU3lzdGVtIiwgIkhpZGRlbiIKCiMgQWRtaW5pc3RyYXRpdmUgdG9vbHMKTmV3LUl0ZW0gLVBhdGggIkM6XFByb2dyYW1EYXRhXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcJERFU1RBRE1UT09MIiAtSXRlbVR5cGUgIkRpcmVjdG9yeSIgLUZvcmNlCk5ldy1JdGVtIC1QYXRoICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXCRERVNUQURNVE9PTFxkZXNrdG9wLmluaSIgLUl0ZW1UeXBlICJGaWxlIiAtRm9yY2UKW1N5c3RlbS5UZXh0LkVuY29kaW5nXTo6VVRGOC5HZXRTdHJpbmcoW0NvbnZlcnRdOjpGcm9tQmFzZTY0U3RyaW5nKCJXMHh2WTJGc2FYcGxaRVpwYkdWT1lXMWxjMTBOQ21sVFExTkpJRWx1YVhScFlYUnZjaTVzYm1zOVFDVlRlWE4wWlcxU2IyOTBKVnh6ZVhOMFpXMHpNbHhwYzJOemFXTndiQzVrYkd3c0xUVXdNREVOQ2s5RVFrTWdSR0YwWVNCVGIzVnlZMlZ6SUNnek1pMWlhWFFwTG14dWF6MUFKVk41YzNSbGJWSnZiM1FsWEhONWMzZHZkelkwWEc5a1ltTnBiblF1Wkd4c0xDMHhOamt6RFFwUFJFSkRJRVJoZEdFZ1UyOTFjbU5sY3lBb05qUXRZbWwwS1M1c2JtczlRQ1ZUZVhOMFpXMVNiMjkwSlZ4emVYTjBaVzB6TWx4dlpHSmphVzUwTG1Sc2JDd3RNVFk1TkEwS1RXVnRiM0o1SUVScFlXZHViM04wYVdOeklGUnZiMnd1Ykc1clBVQWxVM2x6ZEdWdFVtOXZkQ1ZjYzNsemRHVnRNekpjVFdSVFkyaGxaQzVsZUdVc0xUUXdNREVOQ2tWMlpXNTBJRlpwWlhkbGNpNXNibXM5UUNWVGVYTjBaVzFTYjI5MEpWeHplWE4wWlcwek1seHRhV2QxYVhKbGMyOTFjbU5sTG1Sc2JDd3RNVEF4RFFwRGIyMXdkWFJsY2lCTllXNWhaMlZ0Wlc1MExteHVhejFBSlZONWMzUmxiVkp2YjNRbFhITjVjM1JsYlRNeVhHMTVZMjl0Y0hWMExtUnNiQ3d0TXpBd0RRcERiMjF3YjI1bGJuUWdVMlZ5ZG1salpYTXViRzVyUFVBbGMzbHpkR1Z0Y205dmRDVmNjM2x6ZEdWdE16SmNZMjl0Y21WekxtUnNiQ3d0TXpReE1BMEtjMlZ5ZG1salpYTXViRzVyUFVBbGMzbHpkR1Z0Y205dmRDVmNjM2x6ZEdWdE16SmNabWxzWlcxbmJYUXVaR3hzTEMweU1qQTBEUXBUZVhOMFpXMGdRMjl1Wm1sbmRYSmhkR2x2Ymk1c2JtczlRQ1Z6ZVhOMFpXMXliMjkwSlZ4emVYTjBaVzB6TWx4dGMyTnZibVpwWnk1bGVHVXNMVFV3TURZTkNsTjVjM1JsYlNCSmJtWnZjbTFoZEdsdmJpNXNibXM5UUNWemVYTjBaVzF5YjI5MEpWeHplWE4wWlcwek1seHRjMmx1Wm04ek1pNWxlR1VzTFRFd01BMEtWMmx1Wkc5M2N5QkVaV1psYm1SbGNpQkdhWEpsZDJGc2JDQjNhWFJvSUVGa2RtRnVZMlZrSUZObFkzVnlhWFI1TG14dWF6MUFKVk41YzNSbGJWSnZiM1FsWEZONWMzUmxiVE15WEVGMWRHaEdWMGRRTG1Sc2JDd3RNakFOQ2xSaGMyc2dVMk5vWldSMWJHVnlMbXh1YXoxQUpWTjVjM1JsYlZKdmIzUWxYSE41YzNSbGJUTXlYRzFwWjNWcGNtVnpiM1Z5WTJVdVpHeHNMQzB5TURFTkNrUnBjMnNnUTJ4bFlXNTFjQzVzYm1zOVFDVlRlWE4wWlcxU2IyOTBKVnh6ZVhOMFpXMHpNbHh6YUdWc2JETXlMbVJzYkN3dE1qSXdNallOQ21SbWNtZDFhUzVzYm1zOVFDVnplWE4wWlcxeWIyOTBKVnh6ZVhOMFpXMHpNbHhrWm5KbmRXa3VaWGhsTEMweE1ETU5DbEJsY21admNtMWhibU5sSUUxdmJtbDBiM0l1Ykc1clBVQWxVM2x6ZEdWdFVtOXZkQ1ZjYzNsemRHVnRNekpjZDJSakxtUnNiQ3d0TVRBd01qRU5DbEpsYzI5MWNtTmxJRTF2Ym1sMGIzSXViRzVyUFVBbFUzbHpkR1Z0VW05dmRDVmNjM2x6ZEdWdE16SmNkMlJqTG1Sc2JDd3RNVEF3TXpBTkNsSmxaMmx6ZEhKNUlFVmthWFJ2Y2k1c2JtczlRQ1ZUZVhOMFpXMVNiMjkwSlZ4eVpXZGxaR2wwTG1WNFpTd3RNVFlOQ2xObFkzVnlhWFI1SUVOdmJtWnBaM1Z5WVhScGIyNGdUV0Z1WVdkbGJXVnVkQzVzYm1zOVFDVlRlWE4wWlcxU2IyOTBKVnh6ZVhOMFpXMHpNbHgzYzJWalpXUnBkQzVrYkd3c0xUY3hPQTBLVUhKcGJuUWdUV0Z1WVdkbGJXVnVkQzVzYm1zOVFDVnplWE4wWlcxeWIyOTBKVnh6ZVhOMFpXMHpNbHh3YldOemJtRndMbVJzYkN3dE56QXdEUXBTWldOdmRtVnllVVJ5YVhabExteHVhejFBSlhONWMzUmxiWEp2YjNRbFhITjVjM1JsYlRNeVhGSmxZMjkyWlhKNVJISnBkbVV1WlhobExDMDFNREFOQ2c9PSIpKSB8IE91dC1GaWxlICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXCRERVNUQURNVE9PTFxkZXNrdG9wLmluaSIKTW92ZS1JdGVtIC1QYXRoICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXEFkbWluaXN0cmF0aXZlIFRvb2xzXCoubG5rIiAtRGVzdGluYXRpb24gIkM6XFByb2dyYW1EYXRhXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcJERFU1RBRE1UT09MIiAtRm9yY2UKTW92ZS1JdGVtIC1QYXRoICIkSE9NRVxBcHBEYXRhXFJvYW1pbmdcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1xBZG1pbmlzdHJhdGl2ZSBUb29sc1wqLmxuayIgLURlc3RpbmF0aW9uICJDOlxQcm9ncmFtRGF0YVxNaWNyb3NvZnRcV2luZG93c1xTdGFydCBNZW51XFByb2dyYW1zXCRERVNUQURNVE9PTCIgLUZvcmNlCiRmb2JqID0gR2V0LUl0ZW0gIkM6XFByb2dyYW1EYXRhXE1pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcJERFU1RBRE1UT09MIgokZm9iai5BdHRyaWJ1dGVzID0gIlN5c3RlbSIKJGZvYmogPSBHZXQtSXRlbSAiQzpcUHJvZ3JhbURhdGFcTWljcm9zb2Z0XFdpbmRvd3NcU3RhcnQgTWVudVxQcm9ncmFtc1wkREVTVEFETVRPT0xcZGVza3RvcC5pbmkiCiRmb2JqLkF0dHJpYnV0ZXMgPSAiU3lzdGVtIiwgIkhpZGRlbiI="))
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