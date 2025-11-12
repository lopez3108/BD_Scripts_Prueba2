SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateFilesBusinessLicense] 
	@BusinessLicenseId int = NULL,
	@AgencyId int,
	@CreationDate datetime,
	@UserId int,
	@Name varchar(150),
	@Extension varchar(25),
	@ExpirationDate DATETIME,
	@IdCreated      INT OUTPUT
AS
BEGIN
	IF (@BusinessLicenseId IS NOT NULL)
	BEGIN
		UPDATE dbo.BusinessLicenses
		SET AgencyId = @AgencyId,
		CreationDate = @CreationDate,
		UserId = @UserId,
		Name = @Name,
		Extension = @Extension
		WHERE BusinessLicenseId = @BusinessLicenseId
 SET @IdCreated = @BusinessLicenseId;

	END
	ELSE
	BEGIN


	DECLARE @maxExpirationDate DATETIME
	SET @maxExpirationDate = ISNULL((SELECT TOP 1 ExpirationDate FROM BusinessLicenses WHERE AgencyId = @AgencyId ORDER BY ExpirationDate DESC), @CreationDate)


	IF(@maxExpirationDate >= @ExpirationDate AND EXISTS(SELECT * FROM BusinessLicenses WHERE AgencyId = @AgencyId))
	BEGIN

	SET @IdCreated = -1


	END
	ELSE
	BEGIN

	
		INSERT INTO dbo.BusinessLicenses
		(AgencyId, CreationDate, UserId, Name, Extension, ExpirationDate)
		VALUES
		(@AgencyId, @CreationDate, @UserId, @Name, @Extension, @ExpirationDate)
		
		SET @IdCreated = @@IDENTITY;


	END












	END
END
GO