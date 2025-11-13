# System-Easy-Setup-Script

<small>This text is translated from Japanese to English using the built-in translation function of Firefox. And, some of them are rough English translations by Japanese people who do not use English natively. There may be a mistranslation, but please read on hard :)</small>

This script is a script that automatically performs the initial setting for comfortable use of various operating systems in bulk.   
You can do all the tedious tasks, such as installing the required software, removing unnecessary components, and rewriting system settings.
  
The software was originally created by the developer TlFoxHuman for himself. It may not be suitable for general use, but you can customize what you do and do not do by selecting it at runtime. Unnecessary manipulations to you do not need to perform.
  
The operating system which the script is currently being created is as follows:
- Windows 11 (mainly Tiny11)

The Debian/Ubuntu script is also in my hands, but this is not published because I don’t think it will be useful to anyone other than me. Because GNU/Linux is easy to use from almost the beginning, right?

## Included scripts
### 11Tweaks.ps1
This script does common(?) initial setup for Windows 11. You can perform the following operations:
- Uninstall these:
	- Teams
	- Outlook
	- DevHome
	- WebExperience (a.k.a Widgets)
- Install [Firefox](https://mozilla.org/firefox) (You can choose Japanese version of Firefox)
- Install [Microsoft Edge Uninstaller](https://github.com/ShadowWhisperer/Remove-MS-Edge) and...
	- Uninstall Microsoft Edge right now
	- Schedule a task to uninstall Microsoft Edge at every startup.
- Install [MSEdge-Redirect](https://github.com/rcmaehl/MSEdgeRedirect)
- Disable the Web search feature on taskbar
- Get back the Windows 10-style Control Center
- Get back these folders in start menu:
	- Accessories
	- Administrative Tools
	- System Tools
- Install [ExplorerPatcher](https://github.com/valinet/ExplorerPatcher)

## 11Tweaks-TlFox.ps1
This script is based on 11Tweaks.ps1 and is customized for the developer, TlFoxHuman. It is not needed for most users, but it is stored in this repository for own development.
  
This script differs from 11Tweaks.ps1 in the following ways:
- Install [LibreWolf](https://librewolf.net) instead of Firefox
- Install [CorvusSKK](https://github.com/nathancorvussolis/corvusskk), the Japanese Input Method

## How to use
### 11Tweaks.ps1
Download this script. [https://github.com/TranslucentFoxHuman/System-Easy-Setup-Script/raw/refs/heads/main/11Tweaks.ps1](https://github.com/TranslucentFoxHuman/System-Easy-Setup-Script/raw/refs/heads/main/11Tweaks.ps1)  
Open Windows PowerShell as Administrator, then run this command:
```
powershell -executionpolicy bypass <path to 11Tweaks.ps1>
```
When you run this, a description of what will be executed sequentially will be displayed, along with a prompt asking whether to proceed with the execution. You should follow the prompt and specify whether to execute by entering Y or N.

Do you absolutely never want to launch Microsoft Edge? Or perhaps you're using Tiny 11 or a similar environment and don't have a browser? It's hidden, but there is Internet Explorer! Using the method on the following page, you can open Internet Explorer. Open IE and use it to download this script:
[https://tlfoxhuman.net/ietools/how-to-open-ie.html](https://tlfoxhuman.net/ietools/how-to-open-ie.html)
## Features planned but not yet implemented
### 11Tweaks.ps1
- [ ] Install 7-Zip
- [ ] Install ImDisk drivers and toolkit

## License
These scripts are provided under the Public Domain.