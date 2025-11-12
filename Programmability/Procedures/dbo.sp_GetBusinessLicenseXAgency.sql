SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetBusinessLicenseXAgency]
	@AgencyId int,
	@CurrentDate DATETIME
AS
BEGIN
	SELECT f.BusinessLicenseId,
	f.AgencyId, f.CreationDate, f.UserId as CreatedBy, f.ExpirationDate,
	u.Name as CreatedByName, f.Name, f.Extension, f.Base64,
	CASE 
	WHEN
	(ISNULL(DATEDIFF(day, @CurrentDate, f.ExpirationDate),0)) < 0 THEN 
	0
	ELSE
	(ISNULL(DATEDIFF(day, @CurrentDate, f.ExpirationDate),0))
	end as DaysLeft
	FROM dbo.BusinessLicenses f
	INNER JOIN dbo.Users u on f.UserId = U.UserId
	WHERE AgencyId = @AgencyId
	ORDER BY ExpirationDate desc	
END
GO