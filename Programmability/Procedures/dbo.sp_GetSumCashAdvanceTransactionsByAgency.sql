SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSumCashAdvanceTransactionsByAgency] @UserId INT = NULL,
@AgencyId INT = NULL,
@CreationDate DATETIME = NULL
AS
BEGIN
  SELECT
    ISNULL(SUM(ISNULL(caob.Usd, 0)), '0') AS Suma
  FROM dbo.CashAdvanceOrBack caob
  WHERE caob.AgencyId = @AgencyId
  AND (CAST(caob.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
  AND (caob.CreatedBy = @UserId
  OR @UserId IS NULL)
END;
GO