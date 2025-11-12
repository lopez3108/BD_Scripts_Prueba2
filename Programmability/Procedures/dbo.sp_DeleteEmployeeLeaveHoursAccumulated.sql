SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Created by Wilmar Zapata/02-07-2025 sp_DeleteEmployeeLeaveHoursAccumulated task: 6564

CREATE PROCEDURE [dbo].[sp_DeleteEmployeeLeaveHoursAccumulated] @EmployeeLeaveHoursAccumulatedId INT

AS
BEGIN

  DELETE FROM EmployeeLeaveHoursAccumulated
  WHERE EmployeeLeaveHoursAccumulatedId = @EmployeeLeaveHoursAccumulatedId
END
GO