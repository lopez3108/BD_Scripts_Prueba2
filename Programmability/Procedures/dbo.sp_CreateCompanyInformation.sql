SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateCompanyInformation]

@CompanyInformationId int = null,
@Name varchar(150),
@Telephone varchar(20),
@Address varchar(150),
@ReceiptLogo varchar(200) = null,
--@CompanySeoSign varchar(200) = null,
@ZipCode nvarchar(50) = null

AS 

BEGIN

IF(@CompanyInformationId IS NULL)
BEGIN
INSERT INTO [dbo].CompanyInformation
           (Name
           ,Telephone,
		   Address,
		   ReceiptLogo,
--		   CompanySeoSign,
		   ZipCode)

     VALUES
           (@Name
           ,@Telephone,
		   @Address,
		   @ReceiptLogo,
--		   @CompanySeoSign,
		   @ZipCode)

		   SELECT @@IDENTITY

		   END
		   ELSE
		   BEGIN

		   UPDATE [dbo].CompanyInformation SET 
		   Name = @Name, 
		   Telephone = @Telephone, 
		   Address = @Address, 
		   ReceiptLogo = @ReceiptLogo,
--		   CompanySeoSign= @CompanySeoSign,
		   ZipCode =  @ZipCode
		   WHERE CompanyInformationId = @CompanyInformationId

		   SELECT @CompanyInformationId

		   END
		  
      --ACTUALIZA EL NOMBRE DE LA COMPAÑIA EN LAS CATEGORIAS DE LOS REPORTES
        UPDATE ReportCategories
        SET CategoryName = @Name
        WHERE CategoryCode = 'C02'



	END

GO