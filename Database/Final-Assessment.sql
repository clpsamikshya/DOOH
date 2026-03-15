-- =============================================
-- Author:		Samikshya Khatiwada
-- Create date: 13 march
-- Description: 1.Retrieves filtered grid data with pagination.
/* 
EXEC core.SpTenantPagedSel 
@JSON = '{
    "Offset": 0,
    "PageSize": 3,
    "Name": "Tech",
    "IsActive": 1
}';
*/
-- =============================================

CREATE OR ALTER PROCEDURE core.SpTenantPagedSel
    @JSON NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @Offset   INT           = ISNULL(JSON_VALUE(@JSON, '$.Offset'), 0),
        @PageSize INT           = ISNULL(JSON_VALUE(@JSON, '$.PageSize'), 3),
        @Name     NVARCHAR(50)  = JSON_VALUE(@JSON, '$.Name'),
        @IsActive BIT           = JSON_VALUE(@JSON, '$.IsActive');

    SELECT COUNT(*) AS TotalCount
    FROM core.Tenant
    WHERE IsDeleted = 0
        AND (@Name IS NULL OR Name LIKE '%' + @Name + '%')
        AND (@IsActive IS NULL OR IsActive = @IsActive);

    SELECT *
    FROM core.Tenant
    WHERE IsDeleted = 0
        AND (@Name IS NULL OR Name LIKE '%' + @Name + '%')
        AND (@IsActive IS NULL OR IsActive = @IsActive)
    ORDER BY Id
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;

END
GO

-- =============================================
-- Author:		Samikshya Khatiwada
-- Create date: 13 march
-- Description:	2.Bulk Insert with Related Table and also handle duplicate entries
/* 
DECLARE @Json NVARCHAR(MAX) = N'
[
    {
        "UserName": "user3",
        "Password": "123456",
        "Email": "user1@test.com",
        "TenantId": 1,
        "IsActive": 0,
        "CreatedBy": 101,
        "UserInfo":
        {
            "FirstName": "Ram",
            "MiddleName": "K",
            "LastName": "Sharma",
            "Dob": "1998-05-10",
            "Gender": 1,
            "ContactNo": "9800000000"
        }
    },
    {
        "UserName": "user4",
        "Password": "123456",
        "Email": "user4@test.com",
        "TenantId": 1,
        "IsActive": 1,
        "CreatedBy": 101,
        "UserInfo":
        {
            "FirstName": "Sita",
            "MiddleName": null,
            "LastName": "Thapa",
            "Dob": "2000-08-15",
            "Gender": 2,
            "ContactNo": "9811111111"
        }
    }

]';

EXEC core.SpUserIns @Json = @Json OUTPUT;
 SELECT @Json AS JsonOutput;
 select * from core.[User]

*/
-- =============================================

CREATE OR ALTER PROCEDURE core.SpUserIns
(
    @JSON NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        CREATE TABLE #User (
            Id         INT            NULL,
            UserName   NVARCHAR(50)   NOT NULL,
            [Password] NVARCHAR(60)   NOT NULL, 
            IsActive   BIT,
            TenantId   INT            NOT NULL,
            Email      NVARCHAR(70)   NOT NULL,
            CreatedBy  INT            NOT NULL,
            UserInfo   NVARCHAR(MAX)  NOT NULL
        );

        CREATE TABLE #Inserted (
            Id       INT          NOT NULL,
            UserName NVARCHAR(50) NOT NULL
        );

        CREATE TABLE #UserInfo (
            UserId     INT          NOT NULL,
            FirstName  NVARCHAR(50) NULL,
            MiddleName NVARCHAR(50) NULL,
            LastName   NVARCHAR(50) NULL,
            Dob        DATE         NULL,
            Gender     INT          NULL,
            ContactNo  NVARCHAR(20) NULL,
            CreatedBy  INT          NOT NULL
        );

        INSERT INTO #User (UserName, [Password], IsActive, TenantId, Email, CreatedBy, UserInfo)
        SELECT 
            oj.UserName, 
            oj.[Password],
            oj.IsActive,
            oj.TenantId,
            oj.Email,
            oj.CreatedBy,
            oj.UserInfo
        FROM OPENJSON(@JSON)
        WITH (
            UserName   NVARCHAR(50),
            [Password] NVARCHAR(60),
            IsActive   BIT, 
            TenantId   INT,
            Email      NVARCHAR(70),
            CreatedBy  INT,
            UserInfo   NVARCHAR(MAX) AS JSON
        ) AS oj;

        
        DECLARE @DupUser NVARCHAR(50);

        SELECT TOP 1 @DupUser = u.UserName
        FROM #User AS u
        INNER JOIN core.[User] AS cu 
            ON cu.UserName = u.UserName
           AND cu.TenantId = u.TenantId;

        IF @DupUser IS NOT NULL
            RAISERROR('User "%s" already exists!', 16, 1, @DupUser);

        INSERT INTO core.[User] (UserName, [Password], IsActive, TenantId, Email)
        OUTPUT inserted.Id, inserted.UserName INTO #Inserted (Id, UserName)
        SELECT
            u.UserName,
            CONVERT(VARBINARY(60), u.[Password]),
            u.IsActive,
            u.TenantId,
            u.Email
        FROM #User AS u;

        UPDATE u
        SET u.Id = i.Id
        FROM #User AS u
        INNER JOIN #Inserted AS i ON u.UserName = i.UserName;

  
        INSERT INTO #UserInfo (UserId, FirstName, MiddleName, LastName, Dob, Gender, ContactNo, CreatedBy)
        SELECT 
            i.Id AS UserId,
            ui.FirstName,
            ui.MiddleName,
            ui.LastName,
            ui.Dob,
            ui.Gender,
            ui.ContactNo,
            u.CreatedBy
        FROM #User AS u
        INNER JOIN #Inserted AS i ON u.UserName = i.UserName
        CROSS APPLY OPENJSON(u.UserInfo)
        WITH (
            FirstName  NVARCHAR(50),
            MiddleName NVARCHAR(50),
            LastName   NVARCHAR(50),
            Dob        DATE,
            Gender     INT,
            ContactNo  NVARCHAR(20)
        ) AS ui;

        INSERT INTO core.UserInfo (UserId, FirstName, MiddleName, LastName, Dob, Gender, ContactNo, CreatedBy)
        SELECT UserId, FirstName, MiddleName, LastName, Dob, Gender, ContactNo, CreatedBy
        FROM #UserInfo;

        SELECT @JSON = (
            SELECT 
                u.Id,
                u.UserName,
                u.TenantId,
                u.IsActive,
                JSON_QUERY((
                    SELECT 
                        ui.FirstName,
                        ui.MiddleName,
                        ui.LastName,
                        ui.Dob,
                        ui.Gender,
                        ui.ContactNo
                    FROM core.UserInfo ui 
                    WHERE ui.UserId = u.Id
                    FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
                )) AS UserInfo 
            FROM core.[User] AS u 
            INNER JOIN #Inserted AS i ON u.Id = i.Id
            FOR JSON PATH, INCLUDE_NULL_VALUES
        );

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

-- =============================================
-- Author:		Samikshya Khatiwada
-- Create date: 13 march
-- Description:	3. Bulk Update with Related Table
/* 
DECLARE @JSON NVARCHAR(MAX) = N'
[
    {
        "Id": 133,
        "Email": "updated1@test.com",
        "IsActive": 0,
        "UserInfo": {
            "FirstName": "UpdatedRam",
            "MiddleName": null,
            "LastName": "Sharma",
            "Dob": "1998-05-10",
            "Gender": 1,
            "ContactNo": "9899999999"
        }
    }
]';

EXEC core.SpUserUpd @JSON = @JSON OUTPUT;
SELECT @JSON AS JsonOutput;


*/
-- =============================================

CREATE OR ALTER PROCEDURE core.SpUserUpd
(
    @JSON NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        CREATE TABLE #User (
            Id       INT           NOT NULL,
            Email    NVARCHAR(70)  NULL,
            IsActive BIT           NULL,
            UserInfo NVARCHAR(MAX) NULL
        );

        INSERT INTO #User (Id, Email, IsActive, UserInfo)
        SELECT Id, Email, IsActive, UserInfo
        FROM OPENJSON(@JSON)
        WITH (
            Id       INT,
            Email    NVARCHAR(70),
            IsActive BIT,
            UserInfo NVARCHAR(MAX) AS JSON
        );

        UPDATE cu
        SET
            cu.Email    = ISNULL(u.Email, cu.Email),
            cu.IsActive = ISNULL(u.IsActive, cu.IsActive)
        FROM core.[User] AS cu
        INNER JOIN #User AS u ON cu.Id = u.Id;

        UPDATE ui
        SET
            ui.FirstName  = ISNULL(uj.FirstName,  ui.FirstName),
            ui.MiddleName = ISNULL(uj.MiddleName, ui.MiddleName),
            ui.LastName   = ISNULL(uj.LastName,   ui.LastName),
            ui.Dob        = ISNULL(uj.Dob,        ui.Dob),
            ui.Gender     = ISNULL(uj.Gender,     ui.Gender),
            ui.ContactNo  = ISNULL(uj.ContactNo,  ui.ContactNo)
        FROM core.UserInfo AS ui
        INNER JOIN #User AS u ON ui.UserId = u.Id
        CROSS APPLY OPENJSON(u.UserInfo)
        WITH (
            FirstName  NVARCHAR(50),
            MiddleName NVARCHAR(50),
            LastName   NVARCHAR(50),
            Dob        DATE,
            Gender     INT,
            ContactNo  NVARCHAR(20)
        ) AS uj;

       
        SET @JSON = (
            SELECT
                u.Id,
                u.UserName,
                u.Email,
                u.IsActive,
                JSON_QUERY((
                    SELECT
                        ui.FirstName,
                        ui.MiddleName,
                        ui.LastName,
                        ui.Dob,
                        ui.Gender,
                        ui.ContactNo
                    FROM core.UserInfo ui
                    WHERE ui.UserId = u.Id
                    FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
                )) AS UserInfo
            FROM core.[User] AS u
            INNER JOIN #User AS i ON u.Id = i.Id
            FOR JSON PATH, INCLUDE_NULL_VALUES
        );

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO


-- =============================================
-- Author:		Samikshya Khatiwada
-- Create date: 13 march
-- Description:	4. Bulk Delete with Related Records. Delete a Tenant and all screen related to that tenant

/*
  DECLARE @JSON NVARCHAR(MAX);

EXEC core.SpTenantDel 
    @TenantId = 7,
    @Cascade = 1,
    @JSON = @JSON OUTPUT;

SELECT @JSON AS JsonOutput;

SELECT * FROM inv.Screen WHERE TenantId = 7;
SELECT * FROM core.Tenant WHERE Id = 7;     
	   
*/
-- =============================================

CREATE OR ALTER PROCEDURE core.SpTenantDel
    @TenantId   INT,
    @Cascade    BIT = 1,
	@JSON       NVARCHAR(MAX) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;
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
        PRINT 'Tenant deleted successfully';

    END TRY  
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(500) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1); 
    END CATCH	
END
GO

-- =============================================
-- Author:		Samikshya Khatiwada
-- Create date: 13 march
-- Description:	5. Dropdown Data Retrieval
/* 
EXEC SpDropDownSel;

*/
-- =============================================

CREATE OR ALTER PROCEDURE inv.SpDropDownSel
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Result NVARCHAR(MAX);

    SET @Result = (
        SELECT
            Id   AS Id,
            Name AS Name
        FROM inv.Screen
        WHERE IsActive = 1
        ORDER BY Name ASC
        FOR JSON PATH
    );

    SELECT @Result AS JsonResult;
END
GO

-- =============================================
-- Author:		Samikshya Khatiwada
-- Create date: 13 march
-- Description:	6. Upsert(INSERT AND UPDATE) data in the table 

/*
 DECLARE @JSON NVARCHAR(600) = N'[
	      {"Name": "Durbarmarg", "Address":"Kathmandu", "TenantId":6 , "IsActive":0, "CostPerContact": 500.00 },
		  { "Name": "Civil Mall", "Address":"Kathmandu", "TenantId":7 , "IsActive":1, "CostPerContact": 600.00 },
		 { "Name": "Time Square", "Address":"New York", "TenantId":8 , "IsActive":1, "CostPerContact": 1000.00}
	   ]'
	   EXEC core.SpScreenTsk  @Json OUTPUT 
      SELECT @Json AS JsonOutput;
*/

-- =============================================

CREATE OR ALTER PROCEDURE inv.SpScreenTsk
    @JSON NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        CREATE TABLE #SInserted (
            Id INT
        );

        
        CREATE TABLE #Screen (
            Id INT NULL,
            [Name] NVARCHAR(50),
            Address NVARCHAR(50),
            TenantId INT,
            IsActive BIT,
            CostPerContact DECIMAL(10,2)
        );

      
        INSERT INTO #Screen (
            Id, Name, Address, TenantId, IsActive, CostPerContact
        )
        SELECT
            oj.Id,
            oj.Name,
            oj.Address,
            oj.TenantId,
            oj.IsActive,
            oj.CostPerContact
        FROM OPENJSON(@JSON)
        WITH (
            Id INT,
            Name NVARCHAR(50),
            Address NVARCHAR(50),
            TenantId INT,
            IsActive BIT,
            CostPerContact DECIMAL(10,2)
        ) AS oj;

        
        INSERT INTO inv.Screen (
            Name, Address, TenantId, IsActive, CostPerContact
        )
        OUTPUT inserted.Id INTO #SInserted (Id)
        SELECT 
            s.Name,
            s.Address,
            s.TenantId,
            s.IsActive,
            s.CostPerContact
        FROM #Screen AS s
        WHERE s.Id = 0 OR s.id IS NULL;


        UPDATE sc
        SET
            sc.Name = s.Name,
            sc.Address = s.Address,
            sc.TenantId = s.TenantId,
            sc.IsActive = s.IsActive,
            sc.CostPerContact = s.CostPerContact
        FROM inv.Screen AS sc
        INNER JOIN #Screen AS s
            ON sc.Id = s.Id
        WHERE s.Id IS NOT NULL AND s.Id > 0;

        COMMIT TRANSACTION;

       
        SELECT @JSON = ISNULL(
        (
            SELECT 
                sc.Id,
                sc.Name,
                sc.Address,
                sc.TenantId,
                sc.IsActive,
                sc.CostPerContact
            FROM inv.Screen AS sc
            WHERE EXISTS (
                SELECT 1 FROM #SInserted i WHERE i.Id = sc.Id
            )
            OR EXISTS (
                SELECT 1 FROM #Screen s 
                WHERE s.Id = sc.Id AND s.Id > 0
            )
            FOR JSON PATH, INCLUDE_NULL_VALUES
        ), '[]');

        DROP TABLE IF EXISTS #SInserted;
        DROP TABLE IF EXISTS #Screen;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        SELECT @JSON = (
            SELECT ERROR_MESSAGE() AS ErrorMessage
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
    END CATCH
END;
GO

-- =============================================
-- Author:		Samikshya Khatiwada
-- Create date: 13 march
-- Description:	7. Search with Optional Filters
/* 

-- No filters
EXEC inv.SpScreenSel;

-- Name only
EXEC inv.SpScreenSel @Name = 'Main';

-- Active only
EXEC inv.SpScreenSel @IsActive = 1;

-- Both
EXEC inv.SpScreenSel @Name = 'Main', @IsActive = 1;

*/
-- =============================================
CREATE OR ALTER PROCEDURE inv.SpScreenSel
    @Name      NVARCHAR(100) = NULL,
    @IsActive  BIT           = NULL
   
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Id,
        Name,
        IsActive   
    FROM inv.Screen
    WHERE
        (@Name     IS NULL OR Name LIKE '%' + @Name + '%')
        AND (@IsActive IS NULL OR IsActive = @IsActive)
        ORDER BY Name ASC;
END