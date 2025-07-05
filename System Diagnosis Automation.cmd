echo 시스템 검사기 (관리자 권한으로 실행 바랍니다)

Dism /Online /Cleanup-Image /ScanHealth
timeout /t 5

Dism /Online /Cleanup-Image /CheckHealth
timeout /t 5

Dism /Online /Cleanup-Image /RestoreHealth
timeout /t 5

sfc /scannow
timeout /t 5

cmd /k
