﻿/*
Deployment script for TestDatabase

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "TestDatabase"
:setvar DefaultFilePrefix "TestDatabase"
:setvar DefaultDataPath "C:\Users\chandrur\AppData\Local\Microsoft\VisualStudio\SSDT\TestDatabase"
:setvar DefaultLogPath "C:\Users\chandrur\AppData\Local\Microsoft\VisualStudio\SSDT\TestDatabase"

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ARITHABORT ON,
                CONCAT_NULL_YIELDS_NULL ON,
                CURSOR_DEFAULT LOCAL 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET PAGE_VERIFY NONE,
                DISABLE_BROKER 
            WITH ROLLBACK IMMEDIATE;
    END


GO
USE [$(DatabaseName)];


GO
PRINT N'Rename refactoring operation with key 6cbe70d6-406d-4bda-a100-91118d056d08 is skipped, element [dbo].[tbl_Product].[Id] (SqlSimpleColumn) will not be renamed to ProductId';


GO
PRINT N'Creating [dbo].[typ_ProductPrice]...';


GO
CREATE TYPE [dbo].[typ_ProductPrice] AS TABLE (
    [CountryCode] VARCHAR (3)     NOT NULL PRIMARY KEY CLUSTERED ([CountryCode] ASC),
    [Price]       DECIMAL (10, 2) NULL);


GO
PRINT N'Creating [dbo].[tbl_Product]...';


GO
CREATE TABLE [dbo].[tbl_Product] (
    [ProductId] INT             IDENTITY (1, 1) NOT NULL,
    [Name]      NVARCHAR (100)  NOT NULL,
    [Price]     DECIMAL (10, 2) NOT NULL,
    CONSTRAINT [PK_tbl_Product] PRIMARY KEY CLUSTERED ([ProductId] ASC)
);


GO
PRINT N'Creating [dbo].[tbl_ProductPrice]...';


GO
CREATE TABLE [dbo].[tbl_ProductPrice] (
    [ProductId]   INT             NOT NULL,
    [CountryCode] VARCHAR (3)     NOT NULL,
    [Price]       DECIMAL (10, 2) NOT NULL,
    CONSTRAINT [PK_tbl_ProductPrice] PRIMARY KEY CLUSTERED ([ProductId] ASC, [CountryCode] ASC)
);


GO
PRINT N'Creating [dbo].[prc_CreateProduct]...';


GO
CREATE PROCEDURE prc_CreateProduct
    @name    NVARCHAR(100),
    @prices  typ_ProductPrice READONLY
AS
SET XACT_ABORT ON
SET NOCOUNT ON

DECLARE @productId  INT
BEGIN TRAN

INSERT  tbl_Product(Name)
SELECT  @name

SELECT  @productId = @@IDENTITY

INSERT  tbl_ProductPrice(ProductId, CountryCode, Price)
SELECT  @productId,
        CountryCode, 
        Price
FROM    @prices

COMMIT TRAN

SELECT  @productId AS ProductId

RETURN 0
GO
PRINT N'Creating [dbo].[prc_GetProduct]...';


GO
CREATE PROCEDURE prc_GetProduct
    @productId  INT
AS
SET NOCOUNT ON

SELECT  ProductId,
        Name
FROM    tbl_Product
WHERE   ProductId = @productId

SELECT  CountryCode,
        Price
FROM    tbl_ProductPrice
WHERE   ProductId = @productId

RETURN 0
GO
PRINT N'Creating [dbo].[prc_UpdateProduct]...';


GO
/*****************************************************************************
* Description of prc_UpdateProduct goes here
*****************************************************************************/
CREATE PROCEDURE prc_UpdateProduct
    @productId      INT,
    @name    NVARCHAR(100),
    @prices  typ_ProductPrice READONLY   
AS 
SET NOCOUNT     ON
SET XACT_ABORT  ON

BEGIN TRAN

UPDATE  tbl_Product
SET     Name = @name
WHERE   ProductId = @productId

MERGE   tbl_ProductPrice pp
USING   @prices i
ON      pp.CountryCode = i.CountryCode
        AND pp.ProductId = @productId
WHEN MATCHED THEN
UPDATE SET Price = i.Price
WHEN NOT MATCHED BY TARGET THEN
INSERT (ProductId, CountryCode, Price)
VALUES (@productId, i.CountryCode, i.Price)
WHEN NOT MATCHED BY SOURCE THEN 
DELETE;

COMMIT TRAN

RETURN 0
GO
-- Refactoring step to update target server with deployed transaction logs

IF OBJECT_ID(N'dbo.__RefactorLog') IS NULL
BEGIN
    CREATE TABLE [dbo].[__RefactorLog] (OperationKey UNIQUEIDENTIFIER NOT NULL PRIMARY KEY)
    EXEC sp_addextendedproperty N'microsoft_database_tools_support', N'refactoring log', N'schema', N'dbo', N'table', N'__RefactorLog'
END
GO
IF NOT EXISTS (SELECT OperationKey FROM [dbo].[__RefactorLog] WHERE OperationKey = '6cbe70d6-406d-4bda-a100-91118d056d08')
INSERT INTO [dbo].[__RefactorLog] (OperationKey) values ('6cbe70d6-406d-4bda-a100-91118d056d08')

GO

GO
PRINT N'Update complete.';


GO
