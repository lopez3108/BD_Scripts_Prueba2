SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportSurplusRefundNotes] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME)
AS
BEGIN
  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;

  SELECT
    dbo.Users.Name AS Employee
   ,dbo.ExpensesType.Code
   ,CAST(dbo.Expenses.Description AS VARCHAR(500)) AS Note
   ,dbo.Expenses.USD AS USD
   ,'REFUND' AS Type
   ,dbo.Expenses.CreatedOn
   ,dbo.Expenses.RefundSurplusDate

  FROM dbo.Expenses
  INNER JOIN dbo.ExpensesType
    ON dbo.Expenses.ExpenseTypeId = dbo.ExpensesType.ExpensesTypeId
  INNER JOIN dbo.Users
    ON dbo.Expenses.CreatedBy = dbo.Users.UserId
  WHERE AgencyId = @AgencyId
  AND CAST(CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
  AND CAST(CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
  AND dbo.ExpensesType.Code = 'C14'





END;
GO