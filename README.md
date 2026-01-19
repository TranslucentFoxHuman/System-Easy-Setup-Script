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
- Download and install the official version of curl.
	- Disable the utterly foolish PowerShell curl alias so that the official curl is executed.
- Use curl for downloading instead of the slow built‑in PowerShell Invoke-WebRequest.
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
- Install [7-zip](https://7-zip.org).
- Install [AIM Toolkit](https://sourceforge.net/projects/aim-toolkit/). It is successor of ImDisk Toolkit.
- Disable the Web search feature on taskbar
- Get back the Windows 10-style Control Center
- Get back these folders in start menu:
	- Accessories
	- Administrative Tools
	- System Tools
- Schedule a task to restore "Accessories", "Administrative Tools", "System Tools" folder at start up.
- Install [ExplorerPatcher](https://github.com/valinet/ExplorerPatcher)

## 11Tweaks-TlFox.ps1
This script is based on 11Tweaks.ps1 and is customized for the developer, TlFoxHuman. It is not needed for most users, but it is stored in this repository for own development.
  
This script differs from 11Tweaks.ps1 in the following ways:
- Install [LibreWolf](https://librewolf.net) instead of Firefox
- Install [CorvusSKK](https://github.com/nathancorvussolis/corvusskk), the Japanese Input Method

## How to use
### 11Tweaks.ps1
## Method 1 (recommended)
By to creating a small download script that doesn't use non‑ASCII characters, you can now easily download and run scripts! Just run the command below.
```
irm https://easysetup.tlfoxhuman.net/win11 | iex
```

## Method 2
Download this script. [https://github.com/TranslucentFoxHuman/System-Easy-Setup-Script/raw/refs/heads/main/11Tweaks.ps1](https://github.com/TranslucentFoxHuman/System-Easy-Setup-Script/raw/refs/heads/main/11Tweaks.ps1)  
Open Windows PowerShell as Administrator, then run this command:
```
powershell -executionpolicy bypass <path to 11Tweaks.ps1>
```
When you run this, a description of what will be executed sequentially will be displayed, along with a prompt asking whether to proceed with the execution. You should follow the prompt and specify whether to execute by entering Y or N.

Please do not run it in a format like `irm <script URL> | iex`. This script contains non-ASCII strings for Japanese support, and executing it in that way causes them to be unrecognizable, resulting in garbled text and script errors. I tried all the encodings - Unicode, UTF-8, and Shift-JIS (also known as ANSI) - but the problem persists. It is probably a PowerShell bug. If you want to run this script easier way, please follow "Method 1".

Do you absolutely never want to launch Microsoft Edge? Or perhaps you're using Tiny 11 or a similar environment and don't have a browser? It's hidden, but there is Internet Explorer! Using the method on the following page, you can open Internet Explorer. Open IE and use it to download this script:
[https://tlfoxhuman.net/ietools/how-to-open-ie.html](https://tlfoxhuman.net/ietools/how-to-open-ie.html)
## Features planned but not yet implemented
### 11Tweaks.ps1

## Not Planned Features
### 11Tweaks.ps1
- Support for ARM Devices:  
  Windows on ARM devices are generally designed for Windows, and other operating systems are either completely non-functional or difficult to run on them. This encourages vendor lock‑in and, when Windows support is discontinued, it increases the amount of industrial waste. Such devices lack sustainability and future prospects, so I do not intend to support them.
## License
MIT License

Originally this script started as a small one that made only a few simple changes. However, since its features have recently expanded, I decided that it should be protected by a license, so it will be changed from the public domain to the MIT license.

The last version that was in the public domain was commit a0ec0ba3364c1db6c3b4e4d525a8ee02f1620040.