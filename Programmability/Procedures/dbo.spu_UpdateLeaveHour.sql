SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Created by jt/15-06-2025  Add new module LEAVE HOURS

CREATE PROCEDURE [dbo].[spu_UpdateLeaveHour] (@EmployeeLeaveHoursId INT = NULL,
@PayrollId INT)

AS

BEGIN

  UPDATE [dbo].EmployeeLeaveHours
  SET PayrollId = @PayrollId
  WHERE EmployeeLeaveHoursId = @EmployeeLeaveHoursId

END
GO