SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_HasSimilarRange] @UserId INT,
@LoginDate DATETIME,
@LogoutDate DATETIME,
@TimeSheetId INT


AS
BEGIN
  --
  --DECLARE @similarRangeTimeSheet BIT
  --  SET @similarRangeTimeSheet = 0
  IF EXISTS (SELECT
        *
      FROM dbo.TimeSheet ts
      WHERE (((@LoginDate BETWEEN ts.LoginDate AND ts.LogoutDate)
      OR (@LogoutDate BETWEEN ts.LoginDate AND ts.LogoutDate))

OR ((@LoginDate < ts.LoginDate)
      AND (@LogoutDate > ts.LogoutDate)))

      AND ts.UserId = @UserId
      AND ts.TimeSheetId != @TimeSheetId)
  BEGIN
    --                       SET @similarRangeTimeSheet = 1
    SELECT *
--    TOP 1 TS.LoginDate, TS.LogoutDate
      
    FROM dbo.TimeSheet ts
    WHERE (((@LoginDate BETWEEN ts.LoginDate AND ts.LogoutDate)
    OR (@LogoutDate BETWEEN ts.LoginDate AND ts.LogoutDate))
OR ((@LoginDate < ts.LoginDate)
      AND (@LogoutDate > ts.LogoutDate)))
    AND ts.UserId = @UserId
    AND ts.TimeSheetId != @TimeSheetId
  END;


-- SELECT
--    @similarRangeTimeSheet 

END;



GO