SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteFilesBusinessLicense]
	@BusinessLicenseId int
AS
BEGIN
	DECLARE @AgencyId INT
	DECLARE @ProviderId INT

	SELECT @AgencyId = AgencyId
	FROM dbo.BusinessLicenses
	WHERE BusinessLicenseId = @BusinessLicenseId

	DELETE
	FROM dbo.BusinessLicenses
	WHERE BusinessLicenseId = @BusinessLicenseId

	SELECT @AgencyId AS AgencyId
END
GO