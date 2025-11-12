SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created by JT/26-08-2024 sp_GetAllEmployeeVacationsAccumulatedByUser

CREATE PROCEDURE [dbo].[sp_GetAllEmployeeVacationsAccumulatedByUser] @UserId INT

AS
BEGIN

  SELECT
    EmployeeVacationsAccumulatedId
   ,ISNULL(Hours, 0) Hours
   ,ev.CycleDateVacation
  FROM EmployeeVacationsAccumulated ev
  WHERE ev.UserId = @UserId
END
GO