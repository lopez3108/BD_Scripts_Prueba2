SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Created by jt/15-06-2025  Add new module LEAVE HOURS

CREATE PROCEDURE [dbo].[sp_GetAllEmployeeLeaveHoursAccumulatedByUser] @UserId INT

AS
BEGIN

  SELECT
    ev.EmployeeLeaveHoursAccumulatedId
   ,ISNULL(Hours, 0) Hours
   ,ev.CycleDateLeaveHours
  FROM EmployeeLeaveHoursAccumulated ev
  WHERE ev.UserId = @UserId
END
GO