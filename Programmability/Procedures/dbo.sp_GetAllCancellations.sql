SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- UpdatedBy JF / UpdatedOn 4-May-2024 / Task 5837 New QA CANCELLATIONS (PENDING) '@AgencyId INT = NULL' 

-- =============================================
-- Author:      JF
-- Create date: 14/06/2024 3:21 p. m.
-- Database:    devtest
-- Description: task 5838 Enviar sms por default al momento de crear una cancelacción en pending ( select ChooseMsg )
-- =============================================
--Last update by JT/08-05-2025 TASK 6506 ADD NEW FIELDS @ValidatedRefundManagerBy,@ValidatedRefundManagerOn ,@ValidatedRefundByTelClient



CREATE   PROCEDURE [dbo].[sp_GetAllCancellations] @ClientName VARCHAR(200) = NULL,
@ReceiptCancelledNumber VARCHAR(20) = NULL,
--@CancellationStatusId   INT          = NULL, 
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@AgencyId INT = NULL,
@UserId INT = NULL,
@ListStatusId VARCHAR(500) = NULL
AS
BEGIN
  SELECT
    c.CancellationId
   ,c.CancellationDate
   ,c.ClientName
   ,c.Telephone
   ,c.Telephone TelephoneSaved
   ,c.Email
   ,c.ProviderCancelledId
   ,c.ReceiptCancelledNumber
   ,c.ProviderNewId
   ,c.ReceiptNewNumber
   ,c.RefundDate
   ,CASE
      WHEN RefundFee = 1 THEN (-ABS(ABS(c.RefundAmount) + ABS(Fee)))
      ELSE (-ABS(ABS(c.RefundAmount)))
    END AS RefundAmount
   ,CASE
      WHEN RefundFee = 1 THEN CAST(-ABS((ABS(c.RefundAmount) + ABS(Fee))) AS VARCHAR(30))
      ELSE CAST(-ABS((ABS(c.RefundAmount))) AS VARCHAR(30))
    END AS RefundAmountString
   ,CAST(ABS(c.TotalTransaction + c.Fee) AS VARCHAR(30)) AmountUsd
   ,c.RefundFee
   ,c.NewTransactionDate
   ,c.TotalTransaction
   ,CAST(c.TotalTransaction AS VARCHAR(30)) AS 'TotalTransactionString'
   ,c.Fee
   ,CAST(c.Fee AS VARCHAR(30)) AS 'FeeString'
   ,c.InitialStatusId
   ,c.CreatedBy
   ,c.ChangedBy
   ,cs.Code AS CodeInitialStatus
   ,UPPER(cs.Description) AS DescriptionInitialStatus
   ,c.FinalStatusId
   ,csf.Code AS CodeFinalStatus
   ,UPPER(csf.Description) AS DescriptionFinalStatus
   ,pc.Name AS NameProviderCancelled
   ,pn.Name AS NameProviderNew
   ,pct.ProviderTypeId AS CancelledProviderTypeId
   ,pct.Code AS CancelledProviderTypeCode
   ,UPPER(pct.Description) AS CancelledProviderTypeDescription
   ,pnt.ProviderTypeId AS NewProviderTypeId
   ,pnt.Code AS NewProviderTypeCode
   ,UPPER(pnt.Description) AS NewProviderTypeDescription
   ,ucreate.Name AS UserNameCreate
   ,uchange.Name AS UserNameChanged
   ,c.NoteXCancellationId
   ,nc.Description AS DescriptionNote
   ,a.AgencyId
   ,a.Name AgencyName
   ,a.code + ' - ' + a.Name Agency -- se agrega este codigo para crear un nuevo campo task 5897 sergio 04-06-2024
   ,a.Telephone AgencyPhone
   ,a.Address AgencyAddress
   ,c.ReceiptCancelledNumber ReceiptCancelledNumber
   ,ct.Description CancellationType
   ,ct.CancellationTypeId
   ,ISNULL(c.TelIsCheck, CAST(0 AS BIT)) TelIsCheck
   ,c.LastUpdatedOn
   ,uL.Name AS LastUpdatedByName
   ,FORMAT(c.CancellationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
   ,FORMAT(c.RefundDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') RefundDateFormat
   ,FORMAT(c.NewTransactionDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') NewTransactionDateFormat
   ,FORMAT(c.LastUpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') LastUpdatedOnFormat
   ,CASE
      WHEN RefundFee = 1 THEN 'YES'
      ELSE 'NO'
    END AS RefundFeeCase
   ,uc.CashierId
   ,c.ChooseMsg
   ,ValidatedBy
   ,ValidatedOn
   ,ValidatedRefundByTelClient
   ,ValidatedRefundManagerBy
   ,ValidatedRefundManagerOn
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
  WHERE (c.ClientName LIKE '%' + @ClientName + '%'
  OR @ClientName IS NULL)
  AND ((c.ReceiptCancelledNumber LIKE '%' + @ReceiptCancelledNumber + '%'
  OR @ReceiptCancelledNumber IS NULL)
  OR (c.ReceiptNewNumber LIKE '%' + @ReceiptCancelledNumber + '%'
  OR @ReceiptCancelledNumber IS NULL))
  --AND ((C.InitialStatusId = @CancellationStatusId
  --      OR @CancellationStatusId IS NULL)
  --     OR (C.FinalStatusId = @CancellationStatusId
  --         OR @CancellationStatusId IS NULL))

  AND ((c.InitialStatusId IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@ListStatusId))
  OR @ListStatusId IS NULL)
  OR (c.FinalStatusId IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@ListStatusId))
  OR @ListStatusId IS NULL)
  )
  AND (((CAST(c.CancellationDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(c.CancellationDate AS DATE) <= CAST(@ToDate AS DATE))
  OR @ToDate IS NULL)
  OR ((CAST(c.NewTransactionDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(c.NewTransactionDate AS DATE) <= CAST(@ToDate AS DATE))
  OR @ToDate IS NULL)
  OR ((CAST(c.RefundDate AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(c.RefundDate AS DATE) <= CAST(@ToDate AS DATE))
  OR @ToDate IS NULL))







  AND ((((cs.Code = 'C02'
  OR cs.Code = 'C01')
  AND c.ChangedBy = @UserId)
  OR c.FinalStatusId = NULL
  AND c.CreatedBy = @UserId)
  OR @UserId IS NULL)
  --AND  (c.FinalStatusId <> NULL AND C.ChangedBy = @UserId)
  AND c.AgencyId = CASE
    WHEN @AgencyId IS NULL THEN c.AgencyId
    ELSE @AgencyId
  END
  ORDER BY CancellationDate;
END;
GO