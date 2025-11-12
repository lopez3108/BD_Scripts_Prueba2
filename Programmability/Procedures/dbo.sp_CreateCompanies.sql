SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateCompanies] 
	@CompanyId  INT = NULL,
    @CompanyName VARCHAR(40),
	@CompanyType INT
	
AS
     BEGIN

	 IF(@CompanyId IS NULL)
	 BEGIN

			INSERT INTO dbo.Companies
			(
				CompanyName,
				CompanyType
				
				
			)
			VALUES
			(
				@CompanyName,
				@CompanyType
				
				
			)

			SELECT @@IDENTITY
	 END
	 ELSE
	 BEGIN
			UPDATE dbo.Companies
			SET CompanyName = @CompanyName,
			CompanyType = @CompanyType
			
			WHERE CompanyId = @CompanyId

			SELECT @CompanyId
	 END

END;
GO