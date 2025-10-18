:: 1. Locate the Mysql database 
cd "C:\Program Files\jhcis\MySQL5.6\bin"
:: ======================================================================
:: 2. Restore
mysql -u root -p123456 -P3333 jhcisdb < "C:\Scripts\BackupData\name-of-backup.sql"
pause
