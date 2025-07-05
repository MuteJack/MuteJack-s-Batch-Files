@echo off
chcp 65001 >nul
setlocal

:: ========================
:: 정보 안내
:: ========================
echo [Boot Loader 추가 매크로]
echo.
echo 작성자: MuteJack
echo.
echo Contact: coldman1224@outlook.com
echo.
echo Description:
echo 이 스크립트는 Windows 복구 환경에서 부팅 항목 편집을 돕기 위해 제작되었습니다.
echo 해당 파일을 실행하기 위해서는 관리자 권한이 필요하니 확인바랍니다.
echo.
echo Caution^^!:
echo 부팅항목 수정은 잘못 사용할 시 시스템에 영향을 줄 수 있습니다.
echo bcdedit 명령 또는 Windows 부팅 구조에 대한 이해가 없다면 실행 전 신중히 검토하세요.
echo 본 Shell 스크립트는 개인적 목적으로 작성되었으며, 이 스크립트를 실행함에 따라 발생하는 문제에 대해 작성자는 책임지지 않습니다.
echo 실행을 원한다면 Y, 중단을 원한다면 N을 입력해주세요.
echo 또는 사용자 입력에서 Q를 입력하여 중간에 중지시킬 수 있습니다.
echo.

:EXECUTE_CONFIRM_ENTRY
set /p execute_confirm=실행하겠습니까? (Y/N): 
if /i "%execute_confirm%"=="Y" (
    call :COPY_ENTRY
) else if /i "%execute_confirm%"=="N" (
    goto :EOF_ENTRY
    exit /b
) else if /i "%execute_confirm%"=="Q" (
    goto :EOF_ENTRY
    exit /b
) else (
    echo 잘못된 입력입니다.
    call :EXECUTE_CONFIRM_ENTRY
) 

:EXECUTE_ENTRY
:: ========================
:: 관리자 권한 확인
:: ========================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [오류] 관리자 권한 CMD로 실행해주세요.
    pause
    exit /b
)

:: ========================
:: 현재 부팅 항목 표시
:: ========================
echo.
bcdedit
echo.

:USER_INPUT_ENTRY
:: ========================
:: 사용자 입력
:: ========================
set /p osname=운영체제 이름을 입력하세요 (예: 복구용 Windows): 
set /p drive=드라이브 문자를 입력하세요 (콜론 제외, 예: D):
set /p mode=새로 생성 시 Y, 기존 항목 수정 시 N 입력 (Y/N/Q): 
set "mode=%mode:"=%"
set "mode=%mode: =%"

if /i "%mode%"=="Y" (
    call :COPY_ENTRY
) else if /i "%mode%"=="N" (
    call :GET_GUID
) else if /i "%mode%"=="Q" (
    goto :EOF_ENTRY
    exit /b
) else (
    goto :USER_INPUT_ENTRY
)

:: 드라이브 문자 정리
set "drive=%drive: =%"
set "drive=%drive:"=%"
set "drive=%drive:\=%"
set "drive=%drive::=%"


:CONFIRM_ENTRY
:: ========================
:: 확인 및 적용
:: ========================
echo.
echo ========================================
echo 아래와 같이 새 부팅항목을 추가합니다:
echo 운영체제 이름 : %osname%
echo 드라이브 문자 : %drive%
echo GUID        : {%newguid%}
echo ========================================

set /p confirm=이대로 진행하시겠습니까? (Y/N/Q): 
if /i "%confirm%"=="Y" (
    goto :ACTION_ENTRY
) else if  /i "%confirm%"=="N" (
    goto :USER_INPUT_ENTRY
) else if  /i "%confirm%"=="Q" (
    if /i "%mode%"=="Y" (
    bcdedit /delete {%newguid%}
    )
    goto :EOF_ENTRY
    exit /b
) else (
        echo 잘못된 입력입니다. && goto :CONFIRM_ENTRY
)

:ACTION_ENTRY
:: ========================
:: 부트 항목 속성 수정
:: ========================
echo.
echo [description 설정 중 - %osname%]   && bcdedit /set {%newguid%} description "%osname%"
if errorlevel 1 (
    echo [오류] description 설정 실패
    goto :USER_INPUT_ENTRY
)
echo [device 설정 중 - %drive%]         && bcdedit /set {%newguid%} device partition=%drive%:
if errorlevel 1 (
    echo [오류] device 설정 실패
    goto :USER_INPUT_ENTRY
)
echo [osdevice 설정 중 - %drive%]       && bcdedit /set {%newguid%} osdevice partition=%drive%:
if errorlevel 1 (
    echo [오류] osdevice 설정 실패
    goto :USER_INPUT_ENTRY
)


:: ========================
:: 완료 안내
:: ========================
echo.
echo ========================================
echo 부트 항목 설정 완료^^!
echo 운영체제 이름 : %osname%
echo 드라이브 문자 : %drive%
echo 부트로더 GUID : {%newguid%}
echo ========================================


:CONFIRM_FINAL_ENTRY
set /p confirm_final=종료를 원하면 Y, 해당 항목 삭제 후 재생성을 원하면 N, 삭제 후 종료를 원하면 Q 입력 (Y/N/Q): 

if /i "%confirm_final%"=="Y" (
    goto :EOF_ENTRY
    exit /b
) else if  /i "%confirm_final%"=="N" (
    bcdedit /delete {%newguid%}
    goto :USER_INPUT_ENTRY
) else if  /i "%confirm_final%"=="Q" (
    bcdedit /delete {%newguid%}
    goto :EOF_ENTRY
    exit /b
) else (
    echo 잘못된 입력입니다.
    goto :CONFIRM_FINAL_ENTRY
)

:EOF_ENTRY
@echo 프로그램을 종료합니다.
@echo on
exit /b

:: ========================
:: GUID 복사 라벨
:: ========================
:COPY_ENTRY
for /f "delims=" %%i in ('bcdedit /copy {current} /d "%osname%"') do (
    set "guid_line=%%i"
)
for /f "tokens=2 delims={}" %%j in ("%guid_line%") do (
    set "newguid=%%j"
)
goto :eof

:: ========================
:: 직접 입력 라벨
:: ========================
:GET_GUID
set /p newguid=수정할 GUID를 입력하세요 (괄호 없이): 
:: 중괄호 {} 자동 제거
set "newguid=%newguid:{=%"
set "newguid=%newguid:}=%"
goto :eof
