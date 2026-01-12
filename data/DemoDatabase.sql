/* =========================================================
   DEMO: Shopee-like Vietnamese Users (10,000 records)
   Database: SQL Server 2016+
   Purpose : Demonstration / Teaching / Testing
   ========================================================= */

------------------------------------------------------------
-- 1. Create database (safe to re-run)
------------------------------------------------------------
IF DB_ID('DemoShoppingDB') IS NULL
BEGIN
    CREATE DATABASE DemoShoppingDB;
END
GO

------------------------------------------------------------
-- 2. Use the database
------------------------------------------------------------
USE DemoShoppingDB;
GO

SET NOCOUNT ON;

------------------------------------------------------------
-- 3. Clean up existing table (safe re-run)
------------------------------------------------------------
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL
    DROP TABLE dbo.Users;

------------------------------------------------------------
-- 4. Create Users table
------------------------------------------------------------
CREATE TABLE dbo.Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(50) NOT NULL,
    FullName NVARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    [Password] VARCHAR(255),
    [Address] NVARCHAR(255),
    City NVARCHAR(100),
    LoyaltyPoints INT,
    IsActive BIT,
    CreatedAt DATETIME
);

------------------------------------------------------------
-- 5. Vietnamese data pools (TEMP tables)
------------------------------------------------------------
CREATE TABLE #VN_LastName (Name NVARCHAR(50));
INSERT INTO #VN_LastName VALUES
(N'Nguyễn'), (N'Trần'), (N'Lê'), (N'Phạm'), (N'Hoàng'),
(N'Huỳnh'), (N'Phan'), (N'Vũ'), (N'Võ'), (N'Đặng');

CREATE TABLE #VN_FirstName (Name NVARCHAR(50));
INSERT INTO #VN_FirstName VALUES
(N'Anh'), (N'Bình'), (N'Chi'), (N'Dũng'), (N'Hiếu'),
(N'Hùng'), (N'Khánh'), (N'Linh'), (N'Minh'), (N'Nam'),
(N'Phương'), (N'Quang'), (N'Thảo'), (N'Trang'),
(N'Tuấn'), (N'Vy');

CREATE TABLE #VN_City (Name NVARCHAR(100));
INSERT INTO #VN_City VALUES
(N'Hồ Chí Minh'),
(N'Hà Nội'),
(N'Đà Nẵng'),
(N'Cần Thơ'),
(N'Hải Phòng'),
(N'Nha Trang'),
(N'Vũng Tàu'),
(N'Biên Hòa');

------------------------------------------------------------
-- 6. Generate 10,000 users
------------------------------------------------------------
DECLARE @i INT = 1;

BEGIN TRAN;

WHILE @i <= 10000
BEGIN
    INSERT INTO dbo.Users
    (
        Username,
        FullName,
        Email,
        Phone,
        [Password],
        [Address],
        City,
        LoyaltyPoints,
        IsActive,
        CreatedAt
    )
    VALUES
    (
        CONCAT('user', @i),

        CONCAT(
            (SELECT TOP 1 Name FROM #VN_LastName ORDER BY NEWID()),
            N' ',
            (SELECT TOP 1 Name FROM #VN_FirstName ORDER BY NEWID())
        ),

        CONCAT('user', @i, '@gmail.com'),

        CONCAT(
            '0',
            CHOOSE(ABS(CHECKSUM(NEWID())) % 4 + 1, '91', '93', '97', '98'),
            RIGHT('0000000' + CAST(ABS(CHECKSUM(NEWID())) % 10000000 AS VARCHAR), 7)
        ),

        'demo_hashed_password',

        CONCAT(
            CAST(ABS(CHECKSUM(NEWID())) % 300 + 1 AS VARCHAR),
            N' ',
            CHOOSE(ABS(CHECKSUM(NEWID())) % 4 + 1,
                N'Lê Lợi',
                N'Nguyễn Trãi',
                N'Trần Hưng Đạo',
                N'Võ Văn Tần'
            )
        ),

        (SELECT TOP 1 Name FROM #VN_City ORDER BY NEWID()),

        ABS(CHECKSUM(NEWID())) % 5000,

        CASE WHEN RAND(CHECKSUM(NEWID())) < 0.9 THEN 1 ELSE 0 END,

        DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 720, GETDATE())
    );

    SET @i = @i + 1;
END;

COMMIT;

------------------------------------------------------------
-- 7. Demo verification queries
------------------------------------------------------------
SELECT COUNT(*) AS TotalUsers FROM dbo.Users;

SELECT TOP 10 * FROM dbo.Users ORDER BY CreatedAt DESC;

------------------------------------------------------------
-- END OF DEMO SCRIPT
------------------------------------------------------------
