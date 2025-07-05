@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 경로 길이 제한 해제 여부 입력
set /p Input=경로 길이 제한을 해제하시겠습니까? (Y/N): 
set Input=!Input:~0,1!

:: 활성화 여부 확인 
if /i "!Input!"=="Y" (
    set enable=1
) else if /i "!Input!"=="N" (
    set enable=0
) else (
    echo 잘못된 입력입니다. Y 또는 N을 입력하세요.
    goto :EOF_ENTRY
)

:: 재부팅 여부 확인
set /p restart=이 설정은 재부팅이 필요합니다. 적용 후, 재시작 하시겠습니까? (Y/N/Quit): 
set restart=!restart:~0,1!

:: 입력 처리
if /i "!restart!"=="Y" (
    call :REGISTRY_ENTRY
    echo 5초 후 시스템을 재시작합니다...
    shutdown /r /t 5
) else if /i "!restart!"=="N" (
    call :REGISTRY_ENTRY
    echo 나중에 재부팅하시면 설정이 적용됩니다.
    goto :EOF_ENTRY
) else if /i "!restart!"=="Q" (
    echo 수정사항 없이 스크립트를 종료합니다.
    goto :EOF_ENTRY
) else (
    echo 잘못된 입력입니다. 프로그램을 종료합니다.
    goto :EOF_ENTRY
)

:EOF_ENTRY
echo.
pause
cmd /k
exit /b

:REGISTRY_ENTRY
:: 레지스트리 변경
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d %enable% /f
echo 경로 길이 제한 설정이 변경되었습니다.
