SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_SaveTenant]
(@TenantId INT = NULL ,
@Name VARCHAR(80),
@Telephone VARCHAR(12) = NULL,
@TypeID INT = NULL,
@DocNumber VARCHAR(20)= NULL,
@Email VARCHAR(100) = NULL,
@IdCreated      INT OUTPUT,
@LastUpdatedBy INT = NULL, 
@LastUpdatedOn DATETIME = NULL,
@TelIsCheck bit = null
)
AS
BEGIN
  IF (@TenantId IS NULL)
  BEGIN
INSERT INTO [dbo].[Tenants] ([Name],
[Telephone],
[TypeId],
[DocNumber],
Email,
LastUpdatedBy,
LastUpdatedOn,
TelIsCheck)
	VALUES (@Name, @Telephone, @TypeID, @DocNumber, @Email,@LastUpdatedBy,@LastUpdatedOn,@TelIsCheck);
SET @IdCreated = @@IDENTITY;
  END;
ELSE
BEGIN
UPDATE [dbo].[Tenants]
SET [Name] = @Name
   ,[Telephone] = @Telephone
   ,[TypeId] = @TypeID
   ,[DocNumber] = @DocNumber
   ,Email = @Email
   ,LastUpdatedBy = @LastUpdatedBy
   ,LastUpdatedOn = @LastUpdatedOn
   ,TelIsCheck = @TelIsCheck

WHERE TenantId = @TenantId;
set @IdCreated = @TenantId;
END;

END;

GO