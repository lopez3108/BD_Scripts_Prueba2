SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetUserPass](@UserId INT,@AgencyId INT)
AS
BEGIN
DECLARE @1 date
SET @1=(SELECT CAST(getdate() AS DATE))

    IF EXISTS (SELECT * FROM UserPass WHERE UserId = @UserId and AgencyId = @AgencyId)
	BEGIN
	SELECT -1
	END
	ELSE IF EXISTS (SELECT *
		FROM [dbo].[PassAccess]
		WHERE UserId = @UserId AND AgencyId = @AgencyId AND 
		@1 BETWEEN CAST(FromDate AS DATE) AND CAST(ToDate AS DATE))
	BEGIN
		DECLARE @Owner INT
		SELECT @Owner = OwnerUserId
		FROM [dbo].[PassAccess]
		WHERE UserId = @UserId AND AgencyId = @AgencyId AND 
		@1 BETWEEN CAST(FromDate AS DATE) AND CAST(ToDate AS DATE)

		EXEC [dbo].[sp_GetUserById] @UserId = @Owner
	END

END;
GO