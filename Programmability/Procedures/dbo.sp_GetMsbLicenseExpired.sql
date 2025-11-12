SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetMsbLicenseExpired]
@CurrentDate DATETIME
AS
BEGIN
	
DECLARE @daysToExpire INT 
SET @daysToExpire = CAST ((SELECT TOP 1 Value FROM CompanyConfiguration WHERE Description = 'msb_expiration_alert_days') as INT)


DECLARE @maxExpirationDate DATETIME
SET @maxExpirationDate = (SELECT TOP 1 ExpirationDate FROM dbo.Msb ORDER BY ExpirationDate DESC)

DECLARE @diff INT
SET @diff = DATEDIFF(DAY, @CurrentDate, @maxExpirationDate)

IF(@diff <= @daysToExpire)
BEGIN

SELECT 1

END
ELSE
BEGIN

SELECT 0


END


END
GO