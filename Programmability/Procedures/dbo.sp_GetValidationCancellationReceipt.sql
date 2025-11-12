SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetValidationCancellationReceipt] @ProviderId INT = NULL, @AgencyId INT = NULL, @ReceiptCancelledNumber VARCHAR(25) = NULL

AS
BEGIN
  SELECT
   Cancellations.*,
   cs.Description

  --AgenciesxUser.AgencyId
  FROM Cancellations
  LEFT JOIN dbo.CancellationStatus cs
    ON Cancellations.InitialStatusId = cs.CancellationStatusId
  WHERE (AgencyId = @AgencyId
  OR @ProviderId IS NULL)
  AND (ReceiptCancelledNumber = @ReceiptCancelledNumber
  OR @AgencyId IS NULL)
  AND (ProviderCancelledId = @ProviderId
  OR @ReceiptCancelledNumber IS NULL)


END;
GO