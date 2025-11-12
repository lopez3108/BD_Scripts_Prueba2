SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetBusinessLicenseExpired]
@CurrentDate DATETIME
AS
BEGIN
	
DECLARE @daysToExpire INT 
SET @daysToExpire = CAST ((SELECT TOP 1 Value FROM CompanyConfiguration WHERE Description = 'business_license_expiration_alert_days') as INT)


SELECT *,
(SELECT TOP 1  ag.Code + ' - ' + ag.Name as AgencyName FROM Agencies ag  WHERE ag.AgencyId = query.AgencyId) as AgencyName,
CASE 
	WHEN
	(ISNULL(DATEDIFF(day, @CurrentDate, query.AgencyExpiration),0)) < 0 THEN 
	0
	ELSE
	(ISNULL(DATEDIFF(day, @CurrentDate, query.AgencyExpiration),0))
	end as DaysLeft
FROM
(SELECT DISTINCT
b.AgencyId,
(SELECT TOP 1 ExpirationDate FROM BusinessLicenses bl WHERE bl.AgencyId = b.AgencyId ORDER BY ExpirationDate DESC) as AgencyExpiration
FROM     dbo.BusinessLicenses b INNER JOIN
                  dbo.Agencies a ON b.AgencyId = a.AgencyId
				  WHERE 
				  a.IsActive = 1) as query WHERE
				 CAST(DATEADD(DAY, (@daysToExpire),  @CurrentDate ) as DATE) >= CAST(AgencyExpiration as DATE)
				 ORDER BY AgencyExpiration DESC




END

GO