@ECHO OFF
CHCP 65001

:: ======================================================================
:: 1. CONFIGURATION: กำหนดค่าตัวแปรสำคัญ
:: ======================================================================
SET "MYSQL_BIN_FOLDER=C:\Program Files\jhcis\MySQL5.6\bin"
SET "DB_USER=root"
SET "DB_PASS=123456"
SET "DB_NAME=jhcisdb"
SET "MYSQL_PORT=3333"

:: กำหนดโฟลเดอร์สำหรับเก็บไฟล์สำรองและ Log
SET "BACKUP_DIR=C:\Scripts\BackupData"
SET "LOG_FILE=%BACKUP_DIR%\backup_error.log"

:: ======================================================================
:: 2. PREPARATION: การเตรียมการก่อนเริ่มสำรองข้อมูล
:: ======================================================================

:: ตรวจสอบและสร้างโฟลเดอร์สำรองข้อมูล ถ้ายังไม่มี
IF NOT EXIST "%BACKUP_DIR%" (
    MD "%BACKUP_DIR%"
    ECHO %DATE% %TIME%: Created backup directory: %BACKUP_DIR% >> "%LOG_FILE%"
)

:: ======================================================================
:: **แก้ไข: การสร้างชื่อไฟล์ที่เชื่อถือได้ (Clean Filename)**
:: **ใช้ Substitution เพื่อลบอักขระพิเศษทั้งหมดออกจาก DATE/TIME**
:: ======================================================================
SET "DATE_PART=%DATE%"
SET "TIME_PART=%TIME%"

:: 1. ทำความสะอาด DATE: ลบ / และ - และ ช่องว่าง (เหลือแต่ตัวเลขและตัวอักษร)
SET "DATE_PART=%DATE_PART:/=%"
SET "DATE_PART=%DATE_PART:-=%"
SET "DATE_PART=%DATE_PART: =%"
SET "DATE_PART=%DATE_PART:Mon=%"
SET "DATE_PART=%DATE_PART:Tue=%"
SET "DATE_PART=%DATE_PART:Wed=%"
SET "DATE_PART=%DATE_PART:Thu=%"
SET "DATE_PART=%DATE_PART:Fri=%"
SET "DATE_PART=%DATE_PART:Sat=%"
SET "DATE_PART=%DATE_PART:Sun=%"
SET "DATE_PART=%DATE_PART:จ.=%"
SET "DATE_PART=%DATE_PART:อ.=%"
SET "DATE_PART=%DATE_PART:พ.=%"
SET "DATE_PART=%DATE_PART:พฤ.=%"
SET "DATE_PART=%DATE_PART:ศ.=%"
SET "DATE_PART=%DATE_PART:ส.=%"
SET "DATE_PART=%DATE_PART:อา.=%"

:: 2. ทำความสะอาด TIME: ลบ : และ . (เหลือแต่ตัวเลข)
SET "TIME_PART=%TIME_PART::=%"
SET "TIME_PART=%TIME_PART:.=%"
SET "TIME_PART=%TIME_PART: =%"
SET "TIME_PART=%TIME_PART:~0,6%" :: ตัดให้เหลือแค่ HHMMSS (ตัดเศษมิลลิวินาที)

SET "BACKUP_ID=%DATE_PART%_%TIME_PART%"
SET "BACKUP_FILE_PATH=%BACKUP_DIR%\%DB_NAME%_%BACKUP_ID%.sql"


ECHO. >> "%LOG_FILE%"
ECHO =============================================================== >> "%LOG_FILE%"
ECHO %DATE% %TIME%: Starting MySQL backup for %DB_NAME% >> "%LOG_FILE%"
ECHO Backup File ID generated: %BACKUP_ID% >> "%LOG_FILE%"


:: ======================================================================
:: 3. EXECUTION: คำสั่งสำรองข้อมูลหลัก
:: ======================================================================

:: คำสั่ง mysqldump หลัก:
"%MYSQL_BIN_FOLDER%\mysqldump" -u %DB_USER% -p%DB_PASS% -P%MYSQL_PORT% --default-character-set=utf8 --single-transaction --routines --events %DB_NAME% > "%BACKUP_FILE_PATH%" 2> "%LOG_FILE%"


:: ======================================================================
:: 4. VERIFICATION: การตรวจสอบผลลัพธ์และบันทึก Log
:: ======================================================================

ECHO %DATE% %TIME%: mysqldump command finished. Checking result... >> "%LOG_FILE%"

:: ตรวจสอบขนาดไฟล์สำรอง
SET /a FILE_SIZE=0
IF EXIST "%BACKUP_FILE_PATH%" FOR %%f IN ("%BACKUP_FILE_PATH%") DO SET /a FILE_SIZE=%%~zf

IF %FILE_SIZE% GTR 1024 (
    ECHO SUCCESS: Backup complete! File size: %FILE_SIZE% bytes. >> "%LOG_FILE%"
) ELSE (
    ECHO ERROR: Backup failed or file size is too small (%FILE_SIZE% bytes). >> "%LOG_FILE%"
    ECHO **ACTION REQUIRED: Please check the content of "%LOG_FILE%" for specific MySQL error messages (e.g., Access Denied).** >> "%LOG_FILE%"
)

ECHO =============================================================== >> "%LOG_FILE%"
EXIT