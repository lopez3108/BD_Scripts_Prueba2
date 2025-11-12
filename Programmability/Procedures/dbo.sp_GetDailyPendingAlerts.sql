SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetDailyPendingAlerts] @CurrentDate DATETIME = NULL

AS
BEGIN

  SELECT
    COUNT(DailyId) AS Number, a.Code +'-'+ a.Name AS Agency
  FROM Daily
  INNER JOIN Agencies a on a.AgencyId = Daily.AgencyId
  WHERE ClosedOn IS NULL
  AND ClosedBy IS NULL
  AND (CAST(Daily.CreationDate AS DATE) < CAST(@CurrentDate AS DATE)
  OR @CurrentDate IS NULL)
  GROUP BY Daily.AgencyId
  ,a.Code, a.Name

END;

GO