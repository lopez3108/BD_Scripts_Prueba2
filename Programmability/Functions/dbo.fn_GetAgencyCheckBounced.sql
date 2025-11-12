SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
CREATE   FUNCTION [dbo].[fn_GetAgencyCheckBounced] (@AgencyId INT,
@Date DATETIME)
RETURNS DECIMAL(18, 2)
AS
BEGIN

  DECLARE @result INT

  SET @result = ISNULL((SELECT
      SUM(Checks.Amount)
    FROM Checks
    INNER JOIN Cashiers
      ON Checks.CashierId = Cashiers.CashierId
--    INNER JOIN Agencies
--      ON Cashiers.AgencyId = Agencies.AgencyId
    WHERE
--    Agencies.AgencyId = @AgencyId
--    AND Checks.IsBounced = 1
     CAST(Checks.DateCashed AS DATE) = CAST(@Date AS DATE))
  , 0)

  RETURN @result

END
GO