SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCountExtraFundCashAgencyToAgencyByUser]
(
 @UserId      INT, 
 @AgencyId         INT = NULL
)
AS
    BEGIN

	IF(@AgencyId IS NOT NULL)
	BEGIN
       
	   DECLARE @userRight BIT

	 IF(EXISTS(SELECT 
r.UserId
from RightsxUser r
WHERE SUBSTRING(r.Rights, 26, 1) = '1' 
AND r.UserId = @UserId))
BEGIN

SET @userRight = CAST(1 as BIT)

END
ELSE
BEGIN

DECLARE @isAmin BIT, @isManager BIT

SELECT @isAmin = IsAdmin, @isManager = IsManager FROM Cashiers c WHERE c.UserId = @UserId

IF(CAST(@isAmin as BIT) = CAST(1 AS BIT) OR CAST(@isManager as BIT) = CAST(1 AS BIT))
BEGIN

SET @userRight = CAST(1 as BIT)

END
ELSE
BEGIN

SET @userRight = CAST(0 as BIT)


END

END

		-- Cashier
     
            SELECT ISNULL(COUNT(*), 0) Suma
            FROM dbo.ExtraFundAgencyToAgency e
            WHERE e.AcceptedBy IS NULL
			AND e.ToAgencyId = @AgencyId
			AND @userRight = CAST(1 as BIT)

			END
			ELSE
			BEGIN

			-- Admin/Manager

			 SELECT ISNULL(COUNT(*), 0) Suma
            FROM dbo.ExtraFundAgencyToAgency e
            WHERE e.AcceptedBy IS NULL


			END
				
    END;
GO