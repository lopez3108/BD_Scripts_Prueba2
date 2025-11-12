SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATEDBY: JT/ 18-08-2024 


CREATE PROCEDURE [dbo].[spu_UpdateSickHour] (@EmployeeVacationsId INT = NULL,
@PayrollId INT)

AS

BEGIN

  UPDATE [dbo].EmployeeVacations
  SET PayrollId = @PayrollId
  WHERE EmployeeVacationsId = @EmployeeVacationsId

END

GO