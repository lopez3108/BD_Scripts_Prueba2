SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCalculateAcumSurplusDailyByDateByAgencyByCashier] @AgencyId INT,
@CashierId INT,
@UserId INT,
@SurplusDate DATETIME = NULL
AS
  SET NOCOUNT ON;
  BEGIN
    SELECT
      (SELECT
          ISNULL(A.Refund, 0) Acum
        FROM (SELECT
            ABS(SUM(ISNULL(Usd, 0))) Refund
          FROM Expenses e
          INNER JOIN ExpensesType ET
            ON e.ExpenseTypeId = ET.ExpensesTypeId
          WHERE ET.Code = 'C14'
          AND e.AgencyId = @AgencyId
          AND e.RefundCashierId = @CashierId
          AND CAST(e.RefundSurplusDate AS DATE) = CAST(@SurplusDate AS DATE)
        --AND e.CreatedBy = @UserId --se comento porque a mi no me interesa discriminar por userId
        ) A)
      - (SELECT
          ABS(SUM(ISNULL(D.Surplus, 0))) Surplus
        FROM Daily D
        WHERE D.AgencyId = @AgencyId
        AND D.CashierId = @CashierId
        AND (CAST(D.CreationDate AS DATE) = CAST(@SurplusDate AS DATE)))
      RefundSurplus;
  END;

GO