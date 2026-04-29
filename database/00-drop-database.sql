-- Chạy trong SSMS khi muốn XÓA HẾT database CentralKitchenDB và tạo lại từ đầu.
-- Thứ tự: (1) File này  (2) database/database.sql

USE master;
GO

IF DB_ID(N'CentralKitchenDB') IS NOT NULL
BEGIN
    ALTER DATABASE [CentralKitchenDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [CentralKitchenDB];
END
GO
