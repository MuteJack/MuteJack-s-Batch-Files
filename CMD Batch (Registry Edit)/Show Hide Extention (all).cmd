@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 확장자 표시 여부 입력 받기
set /p show=파일 확장자를 보이게 하시겠습니까? (Y/N): 
set show=!show:~0,1!

:: 대문자로 변환 (영문 기준)
if /i "!show!"=="Y" (
    set hide=0
) else if /i "!show!"=="N" (
    set hide=1
) else (
    echo 잘못된 입력입니다. Y 또는 N을 입력하세요.
    goto :eof
)

:: 재부팅 여부 확인
set /p restart=이 설정은 파일탐색기(explorer.exe)를 재시작이 필요합니다. 적용 후 재시작할까요? (Y/N/Quit): 
set restart=!restart:~0,1!

:: 입력 처리
if /i "!restart!"=="Y" (
    call :REGISTRY_ENTRY
    taskkill /f /im explorer.exe
    start explorer.exe
    echo 레지스트리 수정 후 탐색기를 재시작했습니다.
    goto :EOF_ENTRY
) else if /i "!restart!"=="N" (
    call :REGISTRY_ENTRY
    echo 레지스트리가 수정되었습니다. 파일탐색기를 수동으로 재시작 또는 재부팅 후 설정이 적용됩니다.
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
:: 레지스트리 수정
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d %hide% /f
echo 확장자 표시 설정이 변경되었습니다.