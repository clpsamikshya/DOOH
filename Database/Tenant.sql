-- =============================================
-- Author:		Samikshya Khatiwada
-- Create date: 11 march
-- Description:	Sp to select screen by id
/*

EXEC core.SpTenantSel 
   */
-- =============================================

CREATE OR ALTER PROCEDURE core.SpTenantSel
    @JSON NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @Name   NVARCHAR(100) = JSON_VALUE(@JSON, '$.Name'),
        @Status BIT           = JSON_VALUE(@JSON, '$.Status');

    DECLARE @Result NVARCHAR(MAX);

    SET @Result = (
        SELECT *
        FROM core.Tenant
        WHERE (@Name IS NULL OR Name LIKE '%' + @Name + '%')
          AND (@Status IS NULL OR IsActive = @Status)
        FOR JSON PATH
    );

    SELECT @Result AS JsonResult;
END
GO

-- =============================================
-- Author:		Samikshya Khatiwada
-- Create date: 11 march
-- Description:	Sp to select screen by id
/*

EXEC core.SpTenantDel @Json = '{"Id": 2}'
   */
-- =============================================

CREATE OR ALTER PROCEDURE core.SpTenantDel
    @JSON NVARCHAR(MAX) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @TenantId INT = JSON_VALUE(@JSON, '$.TenantId'),
        @Cascade  BIT = ISNULL(JSON_VALUE(@JSON, '$.Cascade'), 1);

    BEGIN TRY
        BEGIN TRANSACTION;

            UPDATE core.Tenant
            SET IsDeleted = 1
            WHERE Id = @TenantId
              AND IsDeleted = 0;

            IF @@ROWCOUNT = 0
                RAISERROR('Tenant does not exist or is already deleted!', 16, 1);

            IF @Cascade = 1
            BEGIN
                UPDATE inv.Screen
                SET IsDeleted = 1
                WHERE TenantId = @TenantId 
                  AND IsDeleted = 0;
            END  

        COMMIT TRANSACTION;

    END TRY  
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(500) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1); 
    END CATCH	
END