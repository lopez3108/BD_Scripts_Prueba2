SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Created by JT/13-08-2025 Get the info of cycle vacactions by user
--Last by JT/14-06-2025 Get the info of cycle vacactions by user
CREATE PROCEDURE [dbo].[spu_GetInfoCycleVacationByUser] @UserId INT = NULL
AS
BEGIN
  SELECT
    c.CycleDateVacation,
    c.CycleDateLeaveHours
   ,u.Name
   ,c.UserId
  FROM Cashiers c
  INNER JOIN Users u
    ON c.UserId = u.UserId
  WHERE u.UserId = @UserId
END
GO