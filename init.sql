IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
CREATE TABLE [Products] (
    [Id] int NOT NULL IDENTITY,
    [Name] nvarchar(max) NOT NULL,
    [Code] nvarchar(max) NOT NULL,
    [InsertDate] datetime2 NOT NULL,
    CONSTRAINT [PK_Products] PRIMARY KEY ([Id])
);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20251025184024_Initial', N'9.0.10');

COMMIT;
GO

-- init Data
SET NOCOUNT ON;

DECLARE @batchSize INT = 100000;  -- تعداد رکورد در هر batch
DECLARE @max INT = 1000000000;    -- تعداد کل رکوردها
DECLARE @i INT = 1;

WHILE @i <= @max
BEGIN
INSERT INTO [DataHubSql].[dbo].[Products] ([Name], [Code], [InsertDate])
SELECT TOP (@batchSize)
           CONCAT('Test Product ', n),
    CONCAT('P', RIGHT('000000000' + CAST(n AS VARCHAR(9)), 9)),
       GETDATE()
FROM (
         SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) + @i - 1 AS n
         FROM sys.all_objects a CROSS JOIN sys.all_objects b
     ) t
WHERE n <= @max;

PRINT CONCAT('Inserted up to record ', @i + @batchSize - 1);
    SET @i += @batchSize;
END;
