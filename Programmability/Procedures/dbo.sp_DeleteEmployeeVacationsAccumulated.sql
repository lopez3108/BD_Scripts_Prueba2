SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Created by JT/26-08-2024 sp_DeleteEmployeeVacationsAccumulated

CREATE PROCEDURE [dbo].[sp_DeleteEmployeeVacationsAccumulated] @EmployeeVacationsAccumulatedId INT

AS
BEGIN

  DELETE FROM EmployeeVacationsAccumulated
  WHERE EmployeeVacationsAccumulatedId = @EmployeeVacationsAccumulatedId
END
GO