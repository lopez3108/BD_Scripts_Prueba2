SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-08-22 CB/6015: Creates/updates insurance companies
-- 2025-01-09 LP/6274: delete parameter monthly payments service fee
-- 2025-02-07 DJ/6335: Agregar Campo URL en la Configuración de Insurance Companies
-- 2025-06-13 LP/6566: Error tratando de agregar insurance company (Faltaba un =) URL = null 
CREATE PROCEDURE [dbo].[sp_CreateInsuranceCompany]

@InsuranceCompaniesId INT = NULL,
@Name VARCHAR(200),
@CreatedBy INT,
@CreationDate DATETIME,
@LastUpdatedBy INT,
@LastUpdatedOn DATETIME,
@URL VARCHAR(400) = NULL

 

AS 

BEGIN

IF(EXISTS--Primero validamos que el maker name no se repita ni creando ni editando - Task 5120 dTa 
                (
                    SELECT Name
                    FROM dbo.InsuranceCompanies i
                    WHERE (SELECT [dbo].[removespecialcharatersinstring]( UPPER(i.Name))) = (SELECT [dbo].[removespecialcharatersinstring]( UPPER(@Name)))
					AND ((@InsuranceCompaniesId IS NOT NULL AND i.InsuranceCompaniesId <> @InsuranceCompaniesId) OR @InsuranceCompaniesId IS NULL )
                ))
                    BEGIN
                        SELECT-1
                    END
					ELSE
					BEGIN

IF @InsuranceCompaniesId IS NULL
BEGIN
INSERT INTO [dbo].[InsuranceCompanies]
           ([Name]
           ,[CreatedBy]
           ,[CreationDate]
		   ,[LastUpdatedBy]
           ,[LastUpdatedOn]
		   ,[URL]
		   )
     VALUES
           (@Name
           ,@CreatedBy
           ,@CreationDate
		   ,@LastUpdatedBy
           ,@LastUpdatedOn
		   ,@URL
		   )

		   SELECT @@IDENTITY

END
ELSE
BEGIN


UPDATE [dbo].[InsuranceCompanies]
   SET [Name] = @Name
      ,[CreatedBy] = @CreatedBy
      ,[CreationDate] = @CreationDate
      ,[LastUpdatedBy] = @LastUpdatedBy
      ,[LastUpdatedOn] = @LastUpdatedOn
	  ,[URL] = @URL
 WHERE InsuranceCompaniesId = @InsuranceCompaniesId

 SELECT @InsuranceCompaniesId

END

END

END
GO