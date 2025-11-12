SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-04-22 JF/5811: Generate expense daily after paying payroll


--UPDATE BY JT/30-04-2024
--Show the real name of owner of commission employee 
--Permitir a un manager pagar las comisiones de otros cajeros task 5750
--Modificado JF 27-03-2025-- add @PayrollExpenseType para excluir este tipo  

CREATE PROCEDURE [dbo].[sp_GetAllExpensesByAgencyId] @AgencyId  INT, @CreatedOn DATE = NULL,@UserId INT, @ProviderId int = NULL
AS
     SET NOCOUNT ON;
    BEGIN

	DECLARE @forexExpenseType INT
		   SET @forexExpenseType = (SELECT TOP 1 e.ExpensesTypeId FROM dbo.ExpensesType e WHERE e.Code = 'C15')

DECLARE @PayrollExpenseType INT
		   SET @PayrollExpenseType = (SELECT TOP 1 e.ExpensesTypeId FROM dbo.ExpensesType e WHERE e.Code = 'C16')

        SELECT e.ExpenseId, 
               e.Description, 
               e.Description DescriptionSaved, 
               e.Usd, 
               e.AgencyId, 
               e.CreatedBy, 
               e.CreatedOn, 
               e.Usd 'moneyvalue', 
               e.Usd 'Value', 
               'true' 'OnlyNegative', 
               'true' 'AcceptNegative', 
               CAST(0 AS BIT) AcceptZero, 
               'true' 'Set', 
               CAST(1 AS BIT) AS NeedEvaluate, 
               e.ExpenseTypeId, 
               EY.Code ExpenseTypeCode, 
               EY.Code ExpenseTypeCodeSaved, 
               e.BillTypeId, 
               e.BillTypeId BillTypeIdSaved, 
               e.MonthsId, 
               e.MonthsId MonthsIdSaved, 
               e.Year, 
               e.Year YearSaved, 
               e.ReceiptNumber, 
               e.ReceiptNumber ReceiptNumberSaved, 
               e.ProviderName, 
               e.ProviderName ProviderNameSaved, 
               e.ProviderId, 
               e.Company, 
               e.Company CompanySaved, 
               e.TransactionNumber, 
               e.TransactionNumber TransactionNumberSaved, 
               e.Sender, 
               e.Sender SenderSaved, 
               e.Recipient, 
               e.Recipient RecipientSaved, 
               e.Quantity, 
               e.Quantity QuantitySaved, 
               e.MoneyOrderNumber, 
               e.MoneyOrderNumber MoneyOrderNumberSaved, 
               e.RefundCashierId AS CashierId, 
               e.RefundCashierId AS CashierIdSaved, 
               e.RefundSurplusDate AS SurplusDate, 
               e.RefundSurplusDate AS SurplusDateSaved, 
               e.PlateSticker, 
               e.CitySticker, 
               e.ExpenseTypeId ExpenseTypeIdSaved, 
               e.RefundCashierId RefundCashierIdSaved, 
               e.RefundSurplusDate RefundSurplusDateSaved, 
               e.Usd 'ValueSaved', 
               e.Usd UsdSaved, 
               e.Validated, 
               e.UpdatedBy, 
               e.UpdatedOn, 
               un.Name AS UpdatedByName, 
               e.FileIdNameExpenses,
               uc.Name CashierCommissionName
        FROM Expenses E
             INNER JOIN Agencies a ON e.AgencyId = a.AgencyId
             INNER JOIN Users u ON e.CreatedBy = u.UserId
             LEFT JOIN Users un ON e.UpdatedBy = un.UserId
             LEFT JOIN Cashiers c ON E.CashierId = c.CashierId
             LEFT join Users uc ON uc.UserId  = C.UserId
             INNER JOIN ExpensesType EY ON EY.ExpensesTypeId = E.ExpenseTypeId
        WHERE e.AgencyId = @AgencyId AND (e.ProviderId = @ProviderId OR @ProviderId IS NULL)
              AND (CAST(e.CreatedOn AS DATE) = CAST(@CreatedOn AS DATE)
                   OR @CreatedOn IS NULL)
              AND e.CreatedBy = @UserId
  AND E.ExpenseTypeId NOT IN (@forexExpenseType,@PayrollExpenseType)
  END;
GO