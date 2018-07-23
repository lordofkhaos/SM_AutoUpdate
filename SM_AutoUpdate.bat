@echo off
:main
setlocal enabledelayedexpansion
set v=1.2
title AdminToolbox Updater v!v!
set "scp_appdata=%appdata%\SCP Secret Laboratory"
set "data=%~dp0\SCPSL_Data\Managed"
echo.
if exist "%~dp0LocalAdmin.exe" (
	if not exist "!data!" (
		echo  Unable to locate 'SCPSL_Data\Managed'.
		echo  Make sure you are running the latest version of SCPSL.
		pause > nul
		endlocal
		exit
	)
) else (
	echo  "I have no memory of this place..." - Gandalf, 2069
	echo  ^('%~dp0' is probably not the correct location^)
	echo.
	echo  %~n0 is not running from the SCP:SL server root.
	echo  Find the correct location and retry.
	pause > nul
	endlocal
	exit
)
echo  Downloading version data...
if exist "!scp_appdata!\n_sm_version.md" (
	del /q "!scp_appdata!\n_sm_version.md" > nul
)
bitsadmin /create /download "sm_version" > nul
bitsadmin /setnoprogresstimeout "sm_version" > nul
bitsadmin /transfer "sm_version" "https://raw.githubusercontent.com/lordofkhaos/SM_AutoUpdate/master/sm_version.md" "!scp_appdata!\n_sm_version.md" > nul
if !errorlevel!==0 (
	bitsadmin /complete "sm_version" > nul
) else (
	echo  Download failed.
	echo.
	echo  Press any key to retry.
	pause > nul
	bitsadmin /complete "sm_version" > nul
	endlocal
	goto :main
)
echo     Done.
echo.
echo  Parsing version data...
if exist "!scp_appdata!\sm_version.md" (
	for /f "usebackq tokens=2 delims==" %%A in ("!scp_appdata!\sm_version.md") do (
		set "local_version=%%A"
		set _local_version=!local_version:.=!
	)
) else (
	echo     No local version data found.
	echo.
	echo  Press any key to update regardless.
	pause > nul
	for /f "usebackq tokens=2 delims==" %%A in ("!scp_appdata!\n_sm_version.md") do (
		set "sm_version=%%A"
		set _sm_version=!sm_version:.=!
	)
	goto :update
)
for /f "usebackq tokens=2 delims==" %%A in ("!scp_appdata!\n_sm_version.md") do (
	set "sm_version=%%A"
	set _sm_version=!sm_version:.=!
)
echo      Done.
echo.
if !_local_version! LSS !_sm_version! (
	echo.
	echo  A newer version of Smod is available.
	echo.
	echo  Your version: !local_version!
	echo  New version:  !sm_version!
	echo.
	echo  Press any key to download.
	pause > nul
	goto :update
) else (
	echo.
	echo  Your Smod is up to date. ^(Local: v!local_version!   Online: v!sm_version!^)
	echo.
	echo  Press any key to exit.
	pause > nul
	endlocal
	exit
)
:update
cls
echo  Preparing download...
tasklist /fi "IMAGENAME eq SCPSL.exe" | find /i "SCPSL.exe" > nul
if !errorlevel!==0 (
	echo.
	echo  Cannot download while SCP:SL is running.
	echo  Exit SCP:SL and try again.
	pause > nul
	endlocal
	exit
)
set "link=https://github.com/Grover-c13/Smod/releases/download/%sm_version%/Smod2.dll"
set "link=https://github.com/Grover-c13/Smod/releases/download/%sm_version%/Assembly-CSharp.dll"
echo  Downloading Smod...
powershell -command "& { $tls12 = [Enum]::ToObject([Net.SecurityProtocolType], 3072); [Net.ServicePointManager]::SecurityProtocol = $tls12; (New-Object Net.WebClient).DownloadFile('!link!', '!data!\Smod2.dll') }"
powershell -command "& { $tls12 = [Enum]::ToObject([Net.SecurityProtocolType], 3072); [Net.ServicePointManager]::SecurityProtocol = $tls12; (New-Object Net.WebClient).DownloadFile('!link!', '!data!\Assembly-CSharp.dll') }"
if exist "!data!\Smod2.dll" && "!data!\Assembly-CSharp.dll" (
	echo  Done.
	echo  Now running v!sm_version!
) else (
	echo  Download failed.
	echo.
	echo  Press any key to retry.
	pause > nul
	goto :update
)
echo.
echo.
echo  Press any key to exit
pause > nul
endlocal
exit