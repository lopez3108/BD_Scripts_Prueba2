SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetTenantByNameTelephoneDocument]
@Name VARCHAR(80),
@Telephone VARCHAR(80),
@DocumentTypeId INT,
@DocNumber VARCHAR(15)
AS
     BEGIN

	 if(EXISTS(
         
		 SELECT TOP 1 TenantId FROM Tenants
		 WHERE Name = @Name AND
		 Telephone = @Telephone AND
		 TypeId = @DocumentTypeId AND
		 DocNumber = @DocNumber))
		 BEGIN

		 		 SELECT TOP 1 TenantId FROM Tenants
		 WHERE Name = @Name AND
		 Telephone = @Telephone AND
		 TypeId = @DocumentTypeId AND
		 DocNumber = @DocNumber

		 END
		 ELSE
		 BEGIN

		 SELECT NULL

		 END

     END;


GO