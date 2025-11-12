SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- UPDATED 2024-11-8 BY JT/6175: Daily olny sum M.O createdey by cashier, but not crated by admin(UpdatedToPendingByAdmin)

CREATE PROCEDURE [dbo].[sp_GetSumAllTicketsUpdateToPendingByAgencyDaily] @AgencyId INT,
@UpdateToPendingDate DATE = NULL,
@UserId INT = NULL
AS
BEGIN
  DECLARE @MoneyOrderFeeSet DECIMAL(18, 2);
  SET @MoneyOrderFeeSet = (SELECT TOP 1
      MoneyOrderFee
    FROM [dbo].[ConfigurationELS]);
  SELECT
    (COUNT(*) * @MoneyOrderFeeSet) MoneyOrdersFees
   ,ISNULL(SUM(t.Usd), 0) MoneyOrders
  FROM Tickets t
  WHERE t.ChangedToPendingByAgency = @AgencyId
  AND t.MoneyOrderFee IS NOT NULL
  AND t.MoneyOrderFee > 0
  AND (T.UpdatedToPendingByAdmin IS NULL OR t.UpdatedToPendingByAdmin <=0)
  AND (CAST(t.UpdateToPendingDate AS DATE) = CAST(@UpdateToPendingDate AS DATE)
  OR @UpdateToPendingDate IS NULL)
  AND (t.UpdateToPendingBy = @UserId
  OR @UserId IS NULL);
END;


GO