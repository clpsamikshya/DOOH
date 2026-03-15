-- =============================================
-- Author:		Samikshya Khatiwada
-- Create date: 11 march
-- Description:	Sp to select screen by id
/*

EXEC core.SpScreenSel @Json = '{"Id": 2}'
   */
-- =============================================
CREATE OR ALTER PROCEDURE inv.SpScreenByIdSel
    @Json NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Id INT = JSON_VALUE(@Json, '$.Id')
    DECLARE @Result NVARCHAR(MAX)

    SET @Result = (
        SELECT
            Id,
            Name,
            Address,
            TenantId,
            Isactive,
            CostPercontact
        FROM
            inv.Screen
        WHERE
            Isactive = 1
            AND (@Id IS NULL OR Id = @Id)
        FOR JSON PATH
    )

    SELECT @Result
END
Go
/*CREATE OR ALTER PROCEDURE core.SpScreenSel
    @Json NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    --DECLARE @Id INT = JSON_VALUE(@Json, '$.Id')
    DECLARE @Result NVARCHAR(MAX)

    SET @Result = (
        SELECT
            Id,
            Name,
            Address,
            TenantId,
            Isactive,
            CostPercontact
        FROM
            inv.Screen
        --WHERE
        --    Isactive = 1
        --    AND (@Id IS NULL OR Id = @Id)
        FOR JSON PATH
    )

    SELECT @Result As Result
END
Go*/

-- =============================================
-- Author:		Samikshya Khatiwada
-- Create date: 11 march
-- Description:	Sp to select screen 
/*

EXEC core.SpScreenSel 
    @Json = '{}';
   */
-- =============================================
CREATE OR ALTER PROCEDURE inv.SpScreenSel
    @Json NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @Name     NVARCHAR(100) = JSON_VALUE(@Json, '$.Name'),
        @IsActive BIT           = JSON_VALUE(@Json, '$.IsActive');

    DECLARE @Result NVARCHAR(MAX);

    SET @Result = (
        SELECT
            Id,
            Name,
            Address,
            TenantId,
            IsActive,
            CostPerContact
        FROM inv.Screen
        WHERE IsDeleted = 0
            AND (@Name     IS NULL OR Name LIKE '%' + @Name + '%')
            AND (@IsActive IS NULL OR IsActive = @IsActive)
        ORDER BY Name ASC
        FOR JSON PATH
    );

    SELECT @Result AS Result;
END
GO


-- =============================================
-- Author:		<Samikshya Khatiwada>
-- Create date: <2 March 2026>
-- Description:	<delete data>
-- EXEC core.SpScreenDel @ScreenId = 48;
--select * from inv.Screen where Id = 48
-- =============================================

CREATE OR ALTER PROCEDURE inv.SpScreenDel
    @Json NVARCHAR(MAX) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @ScreenId INT = JSON_VALUE(@Json, '$.ScreenId');

        DELETE FROM inv.Screen WHERE Id = @ScreenId;

        COMMIT TRANSACTION;
        SET @Json = '{}';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
Go

-- =============================================
-- Author:		<Samikshya Khatiwada>
-- Create date: <2 March 2026>
-- Description:	Update screen
/*
DECLARE @Json NVARCHAR(MAX) = '{
    "Id": 3,
    "Name": "Screen ",
    "Address": "ktm",
    "TenantId": 3,
    "IsActive": 0,
    "IsDeleted": 0,
    "CostPerContact": 15.50
}';

EXEC [inv].[SpScreenUpd] @Json = @Json OUTPUT;
SELECT @Json AS Result;

*/
--select * from inv.Screen where Id = 48
-- =============================================

CREATE OR ALTER PROCEDURE [inv].[SpScreenUpd]
    @Json NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        CREATE TABLE #TScreen (
            Id             INT NOT NULL,
            [Name]         NVARCHAR(50) NOT NULL,
            Address        NVARCHAR(50),
            TenantId       INT NOT NULL,
            IsActive       BIT,
            IsDeleted      BIT,
            CostPerContact DECIMAL(10,2)
        );

        INSERT INTO #TScreen (Id, Name, Address, TenantId, IsActive, IsDeleted, CostPerContact)
        SELECT oj.Id, oj.Name, oj.Address, oj.TenantId, oj.IsActive, oj.IsDeleted, oj.CostPerContact
        FROM OPENJSON(@Json)
        WITH (
            Id             INT,
            Name           NVARCHAR(50),
            Address        NVARCHAR(50),
            TenantId       INT,
            IsActive       BIT,
            IsDeleted      BIT,
            CostPerContact DECIMAL(10,2)
        ) AS oj;

        IF EXISTS (
            SELECT 1
            FROM #TScreen ts
            LEFT JOIN inv.Screen s ON s.Id = ts.Id
            WHERE s.Id IS NULL
               OR ts.Name IS NULL
               OR ts.Name = ''
        )
        BEGIN
            RAISERROR('Validation failed: Screen does not exist or Name cannot be empty!', 16, 1);
        END
        ELSE
        BEGIN
            UPDATE s
            SET
                --s.[Name]         = ts.[Name],
                --s.Address        = ts.Address,
                --s.TenantId       = ts.TenantId,
                s.IsActive       = ts.IsActive,
                s.IsDeleted      = ts.IsDeleted,
                s.CostPerContact = ts.CostPerContact
            FROM inv.Screen AS s
            INNER JOIN #TScreen AS ts ON s.Id = ts.Id;

            SELECT @Json = ISNULL(
                (SELECT s.Id, s.[Name], s.Address, s.TenantId, s.IsActive, s.IsDeleted, s.CostPerContact
                 FROM inv.Screen AS s
                 INNER JOIN #TScreen AS ts ON s.Id = ts.Id
                 FOR JSON PATH, INCLUDE_NULL_VALUES),
                '[]'
            );
        END

        COMMIT TRANSACTION;
        DROP TABLE IF EXISTS #TScreen;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT @Json = (
            SELECT ERROR_MESSAGE() AS ErrorMessage
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        DROP TABLE IF EXISTS #TScreen;
    END CATCH
END
Go


-- =============================================
-- Author:		Samikshya Khatiwada
-- Create date: 11 march
-- Description:	Sp to select screen by id
-- =============================================
/*

DECLARE @JSON NVARCHAR(MAX) = N'{
  "Name": "Test Screen",
  "Address": "Kathmandu",
  "TenantId": 1,
  "IsActive": 1,
  "CostPerContact": 500.00
}';
EXEC inv.SpScreenIns @JSON = @JSON OUTPUT;
SELECT @JSON;

*/

CREATE OR ALTER PROCEDURE inv.SpScreenIns
    @Json NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY 
        BEGIN TRANSACTION;

        CREATE TABLE #Inserted (
            Id INT NULL
        );

        CREATE TABLE #Screen (
            [Name]         NVARCHAR(50) NOT NULL,
            Address        NVARCHAR(50),
            TenantId       INT NOT NULL,
            IsActive       BIT,
            IsDeleted      BIT,
            CostPerContact DECIMAL(10,2)
        );

        INSERT INTO #Screen (Name, Address, TenantId, IsActive, IsDeleted, CostPerContact)
        SELECT Name, Address, TenantId, IsActive, IsDeleted, CostPerContact
        FROM OPENJSON(@Json)
        WITH (
            Name           NVARCHAR(50),
            Address        NVARCHAR(50),
            TenantId       INT,
            IsActive       BIT,
            IsDeleted      BIT,
            CostPerContact DECIMAL(10,2)
        );

        IF EXISTS (
            SELECT 1 
            FROM #Screen s
            LEFT JOIN core.Tenant t ON t.Id = s.TenantId
            WHERE t.Id IS NULL
               OR s.Name IS NULL
               OR s.Name = ''
        )
        BEGIN
            RAISERROR('Validation failed: Screen Name cannot be empty or Tenant does not exist!', 16, 1);
        END
        ELSE
        BEGIN
            INSERT INTO inv.Screen (Name, Address, TenantId, IsActive, IsDeleted, CostPerContact)
            OUTPUT inserted.Id INTO #Inserted(Id)
            SELECT Name, Address, TenantId, IsActive, IsDeleted, CostPerContact
            FROM #Screen;

            SELECT @Json = ISNULL(
                (SELECT Id, Name, Address, TenantId, IsActive, IsDeleted, CostPerContact 
                 FROM inv.Screen
                 WHERE Id IN (SELECT Id FROM #Inserted)
                 FOR JSON PATH, INCLUDE_NULL_VALUES), 
                '[]'
            );
        END

        COMMIT TRANSACTION;

        DROP TABLE IF EXISTS #Screen;
        DROP TABLE IF EXISTS #Inserted;

    END TRY
    BEGIN CATCH 
        ROLLBACK TRANSACTION;

        SELECT @Json = (
            SELECT ERROR_MESSAGE() AS ErrorMessage
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        DROP TABLE IF EXISTS #Screen;
        DROP TABLE IF EXISTS #Inserted;
    END CATCH	
END