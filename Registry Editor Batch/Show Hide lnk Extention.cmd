@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: .lnk 파일 확장자 표시 여부 입력
set /p show=.lnk 파일 확장자를 보이게 하시겠습니까? (Y/N): 
set show=!show:~0,1!

:: 입력 처리
if /i "!show!"=="Y" (
    set mode=show
) else if /i "!show!"=="N" (
    set mode=hide
) else (
    echo 잘못된 입력입니다. Y 또는 N을 입력하세요.
    goto :EOF_ENTRY
)

:: 탐색기 재시작 여부 입력
set /p restart=이 설정은 파일탐색기(explorer.exe) 재시작이 필요합니다. 적용 후 재시작할까요? (Y/N/Quit): 
set restart=!restart:~0,1!

:: 사용자 입력에 따른 분기
if /i "!restart!"=="Y" (
    call :TOGGLE_LNK_EXT
    taskkill /f /im explorer.exe >nul
    start explorer.exe
    echo 탐색기를 재시작했습니다.
    goto :EOF_ENTRY
) else if /i "!restart!"=="N" (
    call :TOGGLE_LNK_EXT
    echo 레지스트리가 수정되었습니다. 탐색기를 수동으로 재시작하거나 재부팅 후 적용됩니다.
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

:TOGGLE_LNK_EXT
set REGKEY=HKLM\SOFTWARE\Classes\lnkfile

if /i "%mode%"=="show" (
    reg query "%REGKEY%" /v NeverShowExt >nul 2>&1
    if !errorlevel! equ 0 (
        reg add "%REGKEY%" /v NeverShowExt1 /f >nul
        reg delete "%REGKEY%" /v NeverShowExt /f >nul
        echo .lnk 확장자 표시 설정 적용됨 (NeverShowExt → NeverShowExt1)
    ) else (
        echo 이미 .lnk 확장자가 표시되는 상태입니다.
    )
) else (
    if /i "%mode%"=="hide" (
        reg query "%REGKEY%" /v NeverShowExt1 >nul 2>&1
        if !errorlevel! equ 0 (
            reg add "%REGKEY%" /v NeverShowExt /f >nul
            reg delete "%REGKEY%" /v NeverShowExt1 /f >nul
            echo .lnk 확장자 숨김 설정 적용됨 (NeverShowExt1 → NeverShowExt)
        ) else (
            echo 이미 .lnk 확장자가 숨겨진 상태입니다.
        )
    )
)
goto :eof


