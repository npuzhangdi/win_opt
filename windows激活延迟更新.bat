@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 936 >nul 2>&1
title 系统激活与更新控制程序
color 0A

:: ============================================================
::  常量定义
::  UXKEY   : 设置界面读取的暂停更新时间戳（新旧界面共用）
::  POLKEY  : 官方延期策略与版本锁定
::  LEGAKEY : 旧版脚本写入的状态键（清理用）
::  CFGKEY  : 旧版自建配置键（仅用于清理残留）
:: ============================================================
set "UXKEY=HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
set "POLKEY=HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
set "LEGAKEY=HKLM\SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\Settings"
set "CFGKEY=HKLM\SOFTWARE\WinOpt\UpdateDelay"

:: ============================================================
::  系统版本与版本型号检测（只读，先于任何权限检查）
:: ============================================================
set "BUILD=0"
for /f "tokens=3" %%V in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild 2^>nul ^| findstr /i "CurrentBuild"') do set "BUILD=%%V"
set "EDITION=Unknown"
for /f "tokens=3" %%V in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionID 2^>nul ^| findstr /i "EditionID"') do set "EDITION=%%V"
set "ISHOME=0"
echo(!EDITION!| findstr /i "Core" >nul && set "ISHOME=1"
set "DISPVER="
for /f "tokens=3" %%V in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v DisplayVersion 2^>nul ^| findstr /i "DisplayVersion"') do set "DISPVER=%%V"


:: ============================================================
::  管理员权限检查 (net session 在 Win10/11 全版本可用, 替代已弃用的 cacls)
:: ============================================================
net session >nul 2>&1
if errorlevel 1 (
    echo.
    echo   [权限不足] 请右键选择「以管理员身份运行」后重试。
    echo.
    pause
    exit /b 1
)

:main
cls
echo ========================================
echo       系统激活与更新控制程序
echo ========================================
echo.
echo   1. 激活Windows和Office
echo.
echo   2. Windows更新控制
echo.
echo   3. 退出程序
echo.
echo --------------------------------------------------------
echo    当前系统: !EDITION!  内部版本: !BUILD!
echo ========================================================
choice /c 123 /n /m "请输入选择（1-3）: "
if errorlevel 3 goto exit
if errorlevel 2 goto update_menu
goto activate_menu

:: ============================================================
::  一、激活相关（功能保持原样，仅修正兼容性缺陷）
:: ============================================================
:activate_menu
cls
echo ========================================================
echo              Windows 和 Office 激活
echo ========================================================
echo.
echo    警告：选项 1 / 2 需要联网，并会打开第三方站点。
echo    第三方激活工具存在合规与安全风险，建议优先使用正版授权。
echo.
echo    1. 命令行激活（联网）
echo    2. HEU 激活
echo    3. 查看激活状态
echo    4. 返回主菜单
echo.
echo ========================================================
choice /c 1234 /n /m "请输入选择 1-4: "
if errorlevel 4 goto main
if errorlevel 3 goto windows_states
if errorlevel 2 goto heu
goto irm

:irm
cls
echo ========================================================
echo            Windows 和 Office 激活脚本（联网）
echo ========================================================
echo.
echo  正在打开脚本下载地址，请确保网络连接正常...
start "" "https://massgrave.dev/"
echo.
echo  按任意键返回主菜单...
pause >nul
goto main

:heu
cls
echo ========================================================
echo              HEU 激活软件（支持离线）
echo ========================================================
echo.
echo  打开软件网址...
start "" "https://github.com/zbezj/HEU_KMS_Activator"
echo  备用网址
echo  地址1：https://wwi.lanzoup.com/b05gumbe 密码:9xum
echo  地址2：https://pan.baidu.com/s/14U3zIG4tG6ZdMBrHaPaLzw?pwd=c65c
echo  地址3：https://github.com/zbezj/HEU_KMS_Activator/releases
echo  蓝奏云链接经常会失效，可把链接中的 lanzoup 依次替换为
echo  lanzouh、lanzous、lanzousi、lanzoux、lanzouw、lanzouo、lanzouy 重试。
echo.
echo  按任意键返回主菜单...
pause >nul
goto main

:windows_states
cls
title 激活状态查询工具
echo ========================================================
echo              激活状态查询工具
echo ========================================================
echo.
echo [1] Windows 激活状态
echo --------------------------------------------------------
echo  永久激活状态:
cscript //nologo "%SYSTEMROOT%\system32\slmgr.vbs" -xpr
echo.
echo  激活详细信息:
cscript //nologo "%SYSTEMROOT%\system32\slmgr.vbs" -dli
echo.
echo  安装 ID:
cscript //nologo "%SYSTEMROOT%\system32\slmgr.vbs" /dti
echo.
echo [2] Office 激活状态
echo --------------------------------------------------------
set "office_path="
set "office_ver="
for %%v in (16 15 14) do (
    if not defined office_path (
        if exist "%ProgramFiles%\Microsoft Office\Office%%v\ospp.vbs" (
            set "office_path=%ProgramFiles%\Microsoft Office\Office%%v\ospp.vbs"
            set "office_ver=Office%%v"
        ) else if exist "%ProgramFiles(x86)%\Microsoft Office\Office%%v\ospp.vbs" (
            set "office_path=%ProgramFiles(x86)%\Microsoft Office\Office%%v\ospp.vbs"
            set "office_ver=Office%%v 32位"
        )
    )
)
if defined office_path (
    echo  检测到 !office_ver!...
    echo.
    cscript //nologo "!office_path!" /dstatus | findstr /i /c:"LICENSE STATUS" /c:"Last 5" /c:"Product Key Channel"
) else (
    echo  未检测到 Office 或版本不支持
)
echo.
echo [3] 系统信息
echo --------------------------------------------------------
echo  操作系统版本:
ver
echo.
echo  系统类型: %PROCESSOR_ARCHITECTURE%
echo.
echo  产品 ID:
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductId 2>nul | findstr /i "ProductId"
echo.
echo ========================================================
echo  注意：激活密钥信息属于敏感数据，请妥善保管
echo ========================================================
echo.
echo  按任意键返回主菜单...
pause >nul
title 系统激活与更新控制程序
goto main

:: ============================================================
::  二、Windows 更新控制
:: ============================================================
:update_menu
cls
echo ========================================
echo                Windows 更新控制
echo ========================================
echo.
echo    1. 设置延迟更新
echo    2. 恢复 Windows 更新
echo    3. 查看当前更新状态
echo    4. 返回主菜单
echo.
echo ----------------------------------------
echo    可设置 1 - 36500 天，一次写入即生效。
echo ========================================
choice /c 1234 /n /m "请输入选择 1-4: "
if errorlevel 4 goto main
if errorlevel 3 goto show_status
if errorlevel 2 goto resume_update
goto set_delay

:: ------------------------------------------------------------
::  设置延迟更新
:: ------------------------------------------------------------
:set_delay
cls
echo ========================================
echo                设置延迟更新
echo ========================================
echo.
:set_delay_input
set "DAYS="
set /p "DAYS=  延迟更新天数（1-36500，回车返回）: "
if not defined DAYS goto update_menu
echo(!DAYS!| findstr /r "^[1-9][0-9]*$" >nul
if errorlevel 1 (
    echo   输入无效，请输入数字。
    goto set_delay_input
)
if !DAYS! GTR 36500 (
    echo   超出范围，请输入 1 - 36500。
    goto set_delay_input
)

choice /c YN /n /m "  确定延迟 !DAYS! 天吗（Y 确定 / N 重填）: "
if errorlevel 2 goto set_delay

:: 一次性写入目标截止日 = 当前 UTC + N 天，不建立任何后台任务
set /a MAXPAUSE=DAYS
if !MAXPAUSE! LSS 35 set /a MAXPAUSE=35
if !MAXPAUSE! GTR 3650 set /a MAXPAUSE=3650
set /a DEFERFEAT=DAYS
if !DEFERFEAT! GTR 365 set /a DEFERFEAT=365
set /a DEFERQUAL=DAYS
if !DEFERQUAL! GTR 30 set /a DEFERQUAL=30

call :clear_legacy
powershell.exe -NoProfile -NonInteractive -Command "$ErrorActionPreference='Stop'; $n=[DateTime]::UtcNow; $f='yyyy-MM-ddTHH:mm:ssZ'; $ux='HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'; if (-not (Test-Path $ux)) { [void](New-Item -Path $ux -Force) }; $s=$n.ToString($f); $e=$n.AddDays(!DAYS!).ToString($f); foreach($v in 'PauseUpdatesStartTime','PauseFeatureUpdatesStartTime','PauseQualityUpdatesStartTime') { Set-ItemProperty -Path $ux -Name $v -Value $s -Type String }; foreach($v in 'PauseUpdatesExpiryTime','PauseFeatureUpdatesEndTime','PauseQualityUpdatesEndTime') { Set-ItemProperty -Path $ux -Name $v -Value $e -Type String }; exit 0"
if errorlevel 1 (
    echo   写入失败，请以管理员身份重新运行。
    echo.
    pause
    goto update_menu
)
reg add "%UXKEY%" /v FlightSettingsMaxPauseDays /t REG_DWORD /d !MAXPAUSE! /f >nul 2>&1

:: 官方延期策略（家庭版 / 旧版本跳过）
if !ISHOME! EQU 1 goto skip_wufb
if !BUILD! LSS 14393 goto skip_wufb
reg add "%POLKEY%" /v DeferFeatureUpdates /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%POLKEY%" /v DeferFeatureUpdatesPeriodInDays /t REG_DWORD /d !DEFERFEAT! /f >nul 2>&1
reg add "%POLKEY%" /v DeferQualityUpdates /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%POLKEY%" /v DeferQualityUpdatesPeriodInDays /t REG_DWORD /d !DEFERQUAL! /f >nul 2>&1
:skip_wufb

:: 锁定当前系统版本，不接收功能更新
if !ISHOME! EQU 1 goto skip_pin
if not defined DISPVER goto skip_pin
reg add "%POLKEY%" /v TargetReleaseVersion /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%POLKEY%" /v TargetReleaseVersionInfo /t REG_SZ /d "!DISPVER!" /f >nul 2>&1
:skip_pin

call :repair_services
net start wuauserv >nul 2>&1
net start bits >nul 2>&1
gpupdate /target:computer /force /wait:20 >nul 2>&1

cls
color 2F
echo ========================================
echo                  设置完成
echo ========================================
echo.
echo    延迟更新天数 : !DAYS! 天
echo    更新服务     : 保持正常
echo.
echo    打开「设置 → Windows 更新」可查看暂停日期。
echo    需要提前恢复请用菜单 2。
echo ========================================
echo.
echo  按任意键返回...
pause >nul
color 0A
goto update_menu

:: ------------------------------------------------------------
::  恢复 Windows 更新
:: ------------------------------------------------------------
:resume_update
cls
echo ========================================
echo              恢复 Windows 更新
echo ========================================
echo.
echo  正在清除全部设置...
call :clear_legacy
reg delete "%CFGKEY%" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\WinOpt" /f >nul 2>&1
call :repair_services
net start wuauserv >nul 2>&1
net start bits >nul 2>&1
gpupdate /target:computer /force /wait:20 >nul 2>&1
color 2F
echo.
echo   已恢复 Windows 更新。
echo.
echo  按任意键返回...
pause >nul
color 0A
goto update_menu

:: ------------------------------------------------------------
::  查看当前状态（只读）
:: ------------------------------------------------------------
:show_status
cls
echo ========================================
echo              当前 Windows 更新状态
echo ========================================
echo.
echo [暂停配置] %UXKEY%
reg query "%UXKEY%" 2>nul | findstr /i /c:"Pause" /c:"FlightSettingsMaxPauseDays"
if errorlevel 1 echo    （未配置）
echo.
echo [延期策略与版本锁定] %POLKEY%
reg query "%POLKEY%" 2>nul | findstr /i /c:"Defer" /c:"TargetReleaseVersion"
if errorlevel 1 echo    （未配置）
echo.
echo  按任意键返回...
pause >nul
goto update_menu

:: ------------------------------------------------------------
::  公共子程序
:: ------------------------------------------------------------
:clear_legacy
for %%N in (PauseUpdatesStartTime PauseUpdatesExpiryTime PauseFeatureUpdatesStartTime PauseFeatureUpdatesEndTime PauseQualityUpdatesStartTime PauseQualityUpdatesEndTime FlightSettingsMaxPauseDays PauseFeatureUpdates PauseQualityUpdates) do reg delete "%UXKEY%" /v %%N /f >nul 2>&1
for %%N in (PausedFeatureStatus PausedQualityStatus) do reg delete "%LEGAKEY%" /v %%N /f >nul 2>&1
for %%N in (DeferFeatureUpdates DeferFeatureUpdatesPeriodInDays DeferQualityUpdates DeferQualityUpdatesPeriodInDays PauseFeatureUpdatesStartTime PauseQualityUpdatesStartTime TargetReleaseVersion TargetReleaseVersionInfo) do reg delete "%POLKEY%" /v %%N /f >nul 2>&1
goto :eof

:repair_services
for %%S in (wuauserv UsoSvc bits WaaSMedicSvc) do call :fix_service %%S
goto :eof

:fix_service
set "SVSTART="
for /f "tokens=3" %%V in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\%~1" /v Start 2^>nul ^| findstr /i "REG_DWORD"') do set "SVSTART=%%V"
if not defined SVSTART goto :eof
if /i not "!SVSTART!"=="0x4" goto :eof
sc.exe config "%~1" start= demand >nul 2>&1
goto :eof

:exit
cls
echo ========================================
echo                   程序退出
echo ========================================
echo.
echo   感谢使用系统激活与更新控制程序！
echo.
echo   按任意键退出...
pause >nul
endlocal
exit /b 0