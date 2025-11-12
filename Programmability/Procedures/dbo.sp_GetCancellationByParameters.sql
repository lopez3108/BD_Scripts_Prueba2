SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Create by jt/06-05-2024 task5903
CREATE PROCEDURE [dbo].[sp_GetCancellationByParameters] @ReceiptCancelledNumber VARCHAR(20) = NULL,
@AgencyId INT = NUL
AS
BEGIN
  SELECT
    c.CancellationId
   ,c.agencyId AS agencyId
   ,a.code + ' - ' + a.Name Agency 
   ,c.CancellationDate
   ,c.ClientName
   ,c.Telephone
   ,c.Email
   ,c.ProviderCancelledId
   ,c.ReceiptCancelledNumber
   ,c.ProviderNewId
   ,c.ReceiptNewNumber
   ,c.RefundDate
   ,c.RefundAmount
   ,CAST(c.RefundAmount AS VARCHAR(30)) AS 'RefundAmountString'
   ,c.NewTransactionDate
   ,c.TotalTransaction
   ,CAST(c.TotalTransaction AS VARCHAR(30)) AS 'TotalTransactionString'
   ,c.Fee
   ,CAST(c.Fee AS VARCHAR(30)) AS 'FeeString'
   ,c.InitialStatusId
   ,c.CreatedBy
   ,c.ChangedBy
   ,cs.Code AS CodeInitialStatus
   ,cs.Description AS DescriptionInitialStatus
   ,c.FinalStatusId
   ,csf.Code AS CodeFinalStatus
   ,csf.Description AS DescriptionFinalStatus
   ,pc.Name AS NameProviderCancelled
   ,pn.Name AS NameProviderNew
   ,pct.ProviderTypeId AS CancelledProviderTypeId
   ,pct.Code AS CancelledProviderTypeCode
   ,pct.Description AS CancelledProviderTypeDescription
   ,pnt.ProviderTypeId AS NewProviderTypeId
   ,pnt.Code AS NewProviderTypeCode
   ,pnt.Description AS NewProviderTypeDescription
   ,ucreate.Name AS UserNameCreate
   ,uchange.Name AS UserNameChanged
   ,c.NoteXCancellationId
   ,nc.Description AS DescriptionNote
   ,ct.Description CancellationType
   ,ct.CancellationTypeId
   ,c.Telephone TelephoneSaved
   ,ISNULL(c.TelIsCheck, CAST(0 AS BIT)) TelIsCheck
   ,c.LastUpdatedOn
   ,uL.Name AS LastUpdatedByName
   ,CAST(RefundFee AS BIT) RefundFee
   ,uc.CashierId
   ,uc.UserId
  FROM Cancellations c
  LEFT JOIN CancellationStatus cs
    ON c.InitialStatusId = cs.CancellationStatusId
  LEFT JOIN Providers pc
    ON pc.ProviderId = c.ProviderCancelledId
  LEFT JOIN ProviderTypes pct
    ON pct.ProviderTypeId = pc.ProviderTypeId
  LEFT JOIN Users ucreate
    ON ucreate.UserId = c.CreatedBy
  INNER JOIN dbo.Cashiers uc
    ON uc.UserId = c.CreatedBy
  LEFT JOIN NotesxCancellations nc
    ON nc.NoteXCancellationId = c.NoteXCancellationId
  LEFT JOIN Agencies a
    ON a.AgencyId = c.AgencyId
  LEFT JOIN CancellationTypes ct
    ON ct.CancellationTypeId = c.CancellationTypeId
  LEFT JOIN Users uchange
    ON uchange.UserId = c.ChangedBy
  LEFT JOIN CancellationStatus csf
    ON c.FinalStatusId = csf.CancellationStatusId
  LEFT JOIN Providers pn
    ON pn.ProviderId = c.ProviderNewId
  LEFT JOIN ProviderTypes pnt
    ON pnt.ProviderTypeId = pn.ProviderTypeId
  LEFT JOIN Users uL
    ON uL.UserId = c.LastUpdatedBy
  WHERE (upper(c.ReceiptCancelledNumber) =UPPER( @ReceiptCancelledNumber)
  OR @ReceiptCancelledNumber IS NULL)
  AND (c.AgencyId = @AgencyId
  OR @AgencyId IS NULL)
END;
GO