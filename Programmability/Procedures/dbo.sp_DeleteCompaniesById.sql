SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteCompaniesById] 
	@CompanyId INT
AS
BEGIN

	IF((SELECT COUNT(*) FROM ProvisionalReceipts WHERE CompanyId = @CompanyId) > 0)
	BEGIN
		SELECT -2
	END
	ELSE
	BEGIN
		DELETE 
		FROM Companies
		WHERE CompanyId = @CompanyId

		SELECT @CompanyId
	END

END;
GO