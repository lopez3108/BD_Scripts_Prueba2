SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Creation By Felipe, Date: 7-abril-2024  task 

CREATE PROCEDURE [dbo].[sp_SaveCommissionsEmployeesReturn] (@CommissionEmployeeReturnId INT = NULL,
@ExpenseId INT = NULL,
@CreatedBy INT = NULL,
@AgencyId INT = NULL,
@CashierCommission DECIMAL(18, 2),
@CreationDate DATETIME,
@Provider VARCHAR(50),
@UserLoginId INT = NULL,
@DateLogin DATETIME)
AS
BEGIN
  IF (@CommissionEmployeeReturnId IS NULL)
  BEGIN
    INSERT INTO [dbo].[CommissionsEmployeesReturn] (ExpenseId,
    CreatedBy,
    AgencyId,
    CashierCommission,
    CreationDate,
    Provider,
    UserLoginId,
    DateLogin)
      VALUES (@ExpenseId, @CreatedBy, @AgencyId, @CashierCommission, @CreationDate, @Provider, @UserLoginId, @DateLogin)
    SELECT
      @@IDENTITY;

  END;


END;


GO