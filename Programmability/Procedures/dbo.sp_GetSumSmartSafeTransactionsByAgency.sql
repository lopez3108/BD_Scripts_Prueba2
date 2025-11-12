SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSumSmartSafeTransactionsByAgency] @UserId INT = NULL,
@AgencyId INT = NULL,
@CreationDate DATETIME = NULL
AS
BEGIN
  SELECT
    ISNULL(SUM(ISNULL(S.Usd, 0)), '0') AS Suma
  FROM SmartSafeDeposit S
  WHERE S.AgencyId = @AgencyId
  AND (CAST(S.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
  AND (S.UserId = @UserId
  OR @UserId IS NULL)
END;
GO