@echo off
chcp 65001 >nul
title 系统激活与更新控制程序
color 0A

:: 管理员权限检查
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo 请右键以管理员身份运行！
    pause
    exit
)

:main
cls
echo ========================================
echo       系统激活与更新控制程序
echo ========================================
echo.
echo 请选择操作：
echo.
echo   1. 激活Windows和Office
echo.
echo   2. Windows更新控制
echo.
echo   3. 退出程序
echo.
echo ========================================
set /p choice=请输入选择（1-3）: 

if "%choice%"=="1" goto activate_windows_office
if "%choice%"=="2" goto windows_pause_update
if "%choice%"=="3" goto exit
echo 输入无效，请重新输入！
timeout /t 2 >nul
goto main

:activate_windows_office
cls
echo ========================================
echo       Windows和Office激活
echo ========================================
echo.
echo 警告：此操作需要联网！
echo.
echo 请选择激活方式：
echo.
echo   1. 命令行激活（联网）
echo.
echo   2. HEU激活
echo.
echo   3. 查看激活状态
echo.
echo   4. 返回主菜单
echo.
echo ========================================
set /p activate_choice=请输入选择（1-3）: 

if "%activate_choice%"=="1" goto irm
if "%activate_choice%"=="2" goto heu
if "%activate_choice%"=="3" goto windows_states
if "%activate_choice%"=="4" goto main
echo 输入无效，请重新输入！
timeout /t 2 >nul
goto activate_windows_office

:irm
cls
echo ========================================
echo       Windows和Office激活脚本（联网）
echo ========================================
echo.
echo 正在打开脚本下载地址...
echo 请确保网络连接正常...
echo.
start "" "https://massgrave.dev/"
echo.
timeout /t -1 
goto main

:heu
cls
echo ========================================
echo       heu激活软件（支持离线）
echo ========================================
echo.
echo 打开软件网址...
start "" "https://github.com/zbezj/HEU_KMS_Activator"
echo 备用网址
echo 地址1：https://wwi.lanzoup.com/b05gumbe 密码:9xum 
echo 地址2：https://pan.baidu.com/s/14U3zIG4tG6ZdMBrHaPaLzw?pwd=c65c
echo 地址3：https://github.com/zbezj/HEU_KMS_Activator/releases 
echo 蓝奏云链接经常会失效，把链接中的lanzoup修改为：lanzouh、lanzous、lanzousi、lanzoux、lanzouw、lanzouo、lanzouy，多尝试几个，就能打开了。
echo.
timeout /t -1 
goto main

:windows_states
cls
title 激活状态查询工具
cls

echo ============================================
echo           激活状态查询工具
echo ============================================
echo.

echo [1] Windows激活状态
echo --------------------------------------------
echo 正在查询Windows激活状态...
echo.

echo 永久激活状态:
cscript //nologo slmgr.vbs -xpr
echo.

echo 激活详细信息:
cscript //nologo slmgr.vbs -dli
echo.

echo 完整产品密钥:
for /f "tokens=2 delims=:" %%i in ('cscript //nologo slmgr.vbs /dlv 2^>nul ^| findstr /i "产品密钥通道"') do echo %%i
echo.

echo 安装ID:
cscript //nologo slmgr.vbs /dti
echo.

echo [2] Office激活状态
echo --------------------------------------------
set "office_path="

:: 简化Office检测 - 按版本优先级检测
for %%v in (16 15 14) do (
    if not defined office_path (
        if exist "%ProgramFiles%\Microsoft Office\Office%%v\ospp.vbs" (
            set "office_path=%ProgramFiles%\Microsoft Office\Office%%v\ospp.vbs"
            set "office_ver=Office%%v"
        ) else if exist "%ProgramFiles(x86)%\Microsoft Office\Office%%v\ospp.vbs" (
            set "office_path=%ProgramFiles(x86)%\Microsoft Office\Office%%v\ospp.vbs"
            set "office_ver=Office%%v (32位)"
        )
    )
)

if defined office_path (
    echo 检测到%office_ver%...
    echo.
    echo 激活状态:
    cscript //nologo "%office_path%" /dstatus | findstr /i "LICENSE STATUS\|Last 5\|Product Key Channel"
    echo.
    echo 完整信息:
    cscript //nologo "%office_path%" /dstatus
) else (
    echo 未检测到Office或版本不支持
)
echo.

echo [3] 系统信息
echo --------------------------------------------
echo 操作系统版本:
ver
echo.

echo 系统类型:
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    echo 64位系统
) else (
    echo 32位系统
)
echo.

echo 产品ID:
wmic os get "SerialNumber" /value | findstr "SerialNumber"
echo.

echo ============================================
echo 注意：激活密钥信息属于敏感数据，请妥善保管
echo ============================================
echo.
timeout /t -1 
goto main




:windows_pause_update
cls
echo ========================================
echo           Windows更新控制
echo ========================================
echo.
echo 请选择操作：
echo.
echo   1. 暂停更新36500天（100年）
echo.
echo   2. 恢复Windows更新
echo.
echo   3. 返回主菜单
echo.
echo ========================================
set /p update_choice=请输入选择（1-3）: 

if "%update_choice%"=="1" goto pause_update
if "%update_choice%"=="2" goto resume_update
if "%update_choice%"=="3" goto main
echo 输入无效，请重新输入！
timeout /t 2 >nul
goto windows_pause_update

:pause_update
cls
echo ========================================
echo           暂停更新设置
echo ========================================
echo.
echo 正在设置注册表项...
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "FlightSettingsMaxPauseDays" /t REG_DWORD /d 36500 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PauseFeatureUpdates" /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PauseQualityUpdates" /t REG_DWORD /d 1 /f >nul
reg delete "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PauseUpdatesExpiryTime" /f >nul 2>&1

:: 设置更新策略
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\Settings" /v "PausedFeatureStatus" /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\Settings" /v "PausedQualityStatus" /t REG_DWORD /d 1 /f >nul

echo 正在停止更新服务...
net stop wuauserv >nul 2>&1
net stop UsoSvc >nul 2>&1
sc config wuauserv start= disabled >nul 2>&1
sc config UsoSvc start= disabled >nul 2>&1

color 2F
echo ========================================
echo  已暂停更新100年（36500天）！
echo ========================================
echo.
echo 注意：更新服务已禁用
echo.
timeout /t 3 >nul
color 0A

:after_pause
cls
echo ========================================
echo           操作完成
echo ========================================
echo.
echo 请选择下一步操作：
echo.
echo   1. 返回更新控制菜单
echo.
echo   2. 返回主菜单
echo.
echo   3. 退出程序
echo.
echo ========================================
set /p next_choice=请输入选择（1-3）: 

if "%next_choice%"=="1" goto windows_pause_update
if "%next_choice%"=="2" goto main
if "%next_choice%"=="3" goto exit
echo 输入无效，请重新输入！
timeout /t 2 >nul
goto after_pause

:resume_update
cls
echo ========================================
echo           恢复更新设置
echo ========================================
echo.
echo 正在清除注册表项...
reg delete "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "FlightSettingsMaxPauseDays" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PauseFeatureUpdates" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PauseQualityUpdates" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "PauseUpdatesExpiryTime" /f >nul 2>&1

:: 恢复更新策略
reg delete "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\Settings" /v "PausedFeatureStatus" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UpdatePolicy\Settings" /v "PausedQualityStatus" /f >nul 2>&1

echo 正在重启更新服务...
sc config wuauserv start= demand >nul 2>&1
sc config UsoSvc start= demand >nul 2>&1
net start wuauserv >nul 2>&1
net start UsoSvc >nul 2>&1

color 2F
echo ========================================
echo     已恢复Windows更新功能！
echo ========================================
echo.
echo 更新服务已重新启用
echo.
timeout /t 3 >nul
color 0A

:after_resume
cls
echo ========================================
echo           操作完成
echo ========================================
echo.
echo 请选择下一步操作：
echo.
echo   1. 返回更新控制菜单
echo.
echo   2. 返回主菜单
echo.
echo   3. 退出程序
echo.
echo ========================================
set /p next_choice=请输入选择（1-3）: 

if "%next_choice%"=="1" goto windows_pause_update
if "%next_choice%"=="2" goto main
if "%next_choice%"=="3" goto exit
echo 输入无效，请重新输入！
timeout /t 2 >nul
goto after_resume

:exit
cls
echo ========================================
echo           程序退出
echo ========================================
echo.
echo 感谢使用系统激活与更新控制程序！
echo.
echo 按任意键退出...
pause >nul
exit