SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Created by jt/15-06-2025  Add new module LEAVE HOURS

CREATE PROCEDURE [dbo].[sp_GetNumberPendingsLeaveHoursCashier] (@CurrentDate DATETIME,
@UserId INT)
AS
BEGIN
SELECT


  ISNULL((SELECT
      dbo.fnu_CalculateLeaveHours(@UserId, C.CycleDateLeaveHours, NULL))
  , 0) AS hoursCashier
FROM dbo.Users u
INNER JOIN Cashiers C
  ON C.UserId = u.UserId
WHERE (u.UserId = @UserId)
AND ((CAST(@CurrentDate AS DATE) > CAST(C.CycleDateLeaveHours AS DATE)))
END;
GO