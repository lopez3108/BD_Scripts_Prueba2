SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Last update by JT/02-09-2025 Task 6689 Daily report nueva columna TOTAL CASH DAILY y TOTAL CASH DISTRIBUTED
--Last update by JT/02-09-2025 Task 6689 Show distribution in the daily only when the daily has a least one distribution, regardless of whether the distribution was saved as 0.
CREATE PROCEDURE [dbo].[sp_GetDailyByDateByAgencyByCashier] @AgencyId INT,
@CashierId INT,
@CreationDate DATETIME = NULL
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    D.DailyId
   ,D.CashierId
   ,D.AgencyId
   ,D.CreationDate
   ,D.Total
   ,D.TotalFree
   ,D.Missing
   ,D.Surplus
   ,D.Note
   ,D.LastEditedOn
   ,D.LastEditedBy
   ,ISNULL(D.Cash, 0) AS Cash
   ,ISNULL(D.CashAdmin, 0) AS CashAdmin
   ,ISNULL(D.CardPayments, 0) AS CardPayments
   ,ISNULL(D.CardPaymentsAdmin, 0) AS CardPaymentsAdmin
   ,ISNULL(DA.DailyAdjustmentId, 0) AS DailyAdjustmentId
   ,ISNULL(D.ClosedOn, NULL) ClosedOn
   ,ISNULL(D.ClosedBy, 0) ClosedBy
   ,ISNULL(D.ClosedOnCashAdmin, NULL) ClosedOnCashAdmin
   ,ISNULL(D.ClosedByCashAdmin, 0) ClosedByCashAdmin
   ,ISNULL(D.ClosedOnCardPaymentsAdmin, NULL) ClosedOnCardPaymentsAdmin
   ,ISNULL(D.ClosedByCardPaymentsAdmin, 0) ClosedByCardPaymentsAdmin
   ,U.UserId
   ,ISNULL(DDX.DailyDistributed, 0) AS DailyDistributed
  ,CASE 
    WHEN EXISTS (SELECT 1 FROM DailyDistribution DD WHERE DD.DailyId = D.DailyId) 
    THEN CAST(1 AS BIT) 
    ELSE CAST(0 AS BIT) 
 END AS HasDistribution
  FROM Daily D
  LEFT JOIN DailyAdjustments DA
    ON D.DailyId = DA.DailyId
  LEFT JOIN Cashiers C
    ON D.CashierId = C.CashierId
  LEFT JOIN Users U
    ON U.UserId = C.UserId
  LEFT JOIN (SELECT
      DailyId
     ,SUM(Usd) AS DailyDistributed
    FROM DailyDistribution
    GROUP BY DailyId) DDX
    ON D.DailyId = DDX.DailyId
  WHERE D.AgencyId = @AgencyId
  AND D.CashierId = @CashierId
  AND (
  @CreationDate IS NULL
  OR (D.CreationDate >= CAST(@CreationDate AS DATE)
  AND D.CreationDate < DATEADD(DAY, 1, CAST(@CreationDate AS DATE)))
  );
END;



GO