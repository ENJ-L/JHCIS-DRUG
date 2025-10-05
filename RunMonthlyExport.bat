@ECHO OFF
CHCP 65001
SETLOCAL ENABLEDELAYEDEXPANSION

:: ======================================================================
:: 1. CONFIGURATION: กำหนดค่าตัวแปรสำคัญ (ไม่ต้องแก้ไขหากค่าเดิมถูกต้อง)
:: ======================================================================
SET "MYSQL_BIN_FOLDER=C:\Program Files\jhcis\MySQL5.6\bin"
SET "DB_USER=root"
SET "DB_PASS=123456"
SET "DB_NAME=jhcisdb"
SET "MYSQL_PORT=3333"

SET "SQL_FILE_PATH=C:\Scripts\MonthlyExport.sql"
SET "EXPORT_DIR=C:\Reports\MonthlyDrugUsage"
SET "LOG_FILE=%EXPORT_DIR%\export_log.txt"

:: ======================================================================
:: 2. PREPARATION: การสร้างโฟลเดอร์และชื่อไฟล์
:: ======================================================================

IF NOT EXIST "%EXPORT_DIR%" (
    MD "%EXPORT_DIR%"
)

FOR /F "usebackq" %%i IN (`powershell -Command "Get-Date -Date (Get-Date).AddMonths(-1) -Format 'yyyyMM'"`) DO SET "LAST_MONTH_YYYYMM=%%i"

:: **สำคัญ: เปลี่ยนนามสกุลไฟล์ปลายทางเป็น .tsv**
SET "EXPORT_FILE_NAME=DrugUsageReport_%LAST_MONTH_YYYYMM%.tsv"
SET "EXPORT_FILE_PATH=%EXPORT_DIR%\%EXPORT_FILE_NAME%"

ECHO. >> "%LOG_FILE%"
ECHO =============================================================== >> "%LOG_FILE%"
ECHO %DATE% %TIME%: Starting Monthly Export... >> "%LOG_FILE%"


:: ======================================================================
:: 3. EXECUTION: สั่งรัน Query ไปยังไฟล์ TSV โดยตรง
:: ======================================================================
ECHO %DATE% %TIME%: Running MySQL Query to TSV... >> "%LOG_FILE%"

:: คำสั่งนี้สร้างไฟล์ TSV (Tab-Separated) ที่มี UTF-8 ถูกต้อง
"%MYSQL_BIN_FOLDER%\mysql" -u %DB_USER% -p%DB_PASS% -P%MYSQL_PORT% %DB_NAME% --default-character-set=utf8 --batch --raw --skip-column-names ^
    --execute="SOURCE %SQL_FILE_PATH%" > "%EXPORT_FILE_PATH%" 2>> "%LOG_FILE%"


:: **ขั้นตอนที่ 4 (POST-PROCESSING) ถูกยกเลิก**


:: ======================================================================
:: 4. VERIFICATION: การตรวจสอบผลลัพธ์
:: ======================================================================

ECHO %DATE% %TIME%: MySQL export finished. Checking final file... >> "%LOG_FILE%"

SET /a FILE_SIZE=0
IF EXIST "%EXPORT_FILE_PATH%" FOR %%f IN ("%EXPORT_FILE_PATH%") DO SET /a FILE_SIZE=%%~zf

IF %FILE_SIZE% GTR 512 (
    ECHO SUCCESS: Export complete! File saved as: %EXPORT_FILE_PATH%. File size: %FILE_SIZE% bytes. >> "%LOG_FILE%"
) ELSE (
    ECHO ERROR: Export failed or file size is too small (%FILE_SIZE% bytes). >> "%LOG_FILE%"
    ECHO **ACTION REQUIRED: Check the log for connection errors or verify the SQL query.** >> "%LOG_FILE%"
)

ECHO =============================================================== >> "%LOG_FILE%"
ENDLOCAL
EXIT