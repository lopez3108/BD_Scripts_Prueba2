SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--last update by:sergio
--date 08-05-2024

--last update by:sergio
--date 14-05-2024
--se modificó el filtro de cardpayment para que se mostrara

CREATE PROCEDURE [dbo].[sp_GetPaymentOthers] @AgencyId INT = NULL,
@ProviderId INT = NULL,
@DateFrom DATETIME = NULL,
@DateTo DATETIME = NULL,
@Type BIT = NULL,
@Status VARCHAR(3) = NULL

AS
BEGIN
  IF @Status IS NOT NULL
  BEGIN
    DECLARE @PaymentOthersStatusId INT
    SET @PaymentOthersStatusId = (SELECT TOP 1
        pos.PaymentOtherStatusId
      FROM PaymentOthersStatus pos
      WHERE pos.Code = @Status)
  END

  SELECT
    dbo.PaymentOthers.PaymentOthersId
   ,dbo.Agencies.AgencyId
   ,dbo.Agencies.Name AS AgencyName
   ,dbo.Agencies.Code + ' - ' + dbo.Agencies.Name AS AgencyCodeName
   ,dbo.Providers.ProviderId
   ,CASE
      WHEN dbo.PaymentOthers.IsCardPayment = 1 --When type id card payment 
      THEN 'CARD PAYMENT - ' + ISNULL(RIGHT(dbo.Agencies.Mid, 6), '')
      ELSE --When it's diferten to card payment
        dbo.Providers.Name +
        ISNULL((SELECT TOP 1
            ' - ' + dbo.MoneyTransferxAgencyNumbers.Number
          FROM dbo.MoneyTransferxAgencyNumbers
          WHERE dbo.MoneyTransferxAgencyNumbers.AgencyId = dbo.PaymentOthers.AgencyId
          AND dbo.MoneyTransferxAgencyNumbers.ProviderId = dbo.PaymentOthers.ProviderId)
        , '')
    END AS ProviderName
   ,dbo.PaymentOthers.USD
   ,dbo.PaymentOthers.CreationDate
   ,dbo.PaymentOthers.LastUpdatedOn
   ,FORMAT(PaymentOthers.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
   ,FORMAT(PaymentOthers.LastUpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') LastUpdatedOnFormat
   ,dbo.PaymentOthers.DeletedOn
   ,FORMAT(PaymentOthers.CompletedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CompletedOnFormat
   ,dbo.PaymentOthers.CompletedOn
   ,FORMAT(PaymentOthers.DeletedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') DeletedOnFormat
   ,UPPER(dbo.Users.Name) AS DeletedBy
   ,pto.Name AS Status
   ,pto.Code AS Code
    --   ,CASE
    --      WHEN
    --        dbo.PaymentOthers.DeletedOn IS NOT NULL THEN 'DELETED'
    --      ELSE 'ACTIVE'
    --    END AS Status
   ,CASE
      WHEN IsDebit = 1 THEN 'DEBIT'
      ELSE 'CREDIT'
    END AS Type
   ,CAST(IsDebit AS BIT) TypeValue
   ,dbo.PaymentOthers.Date
   ,FORMAT(PaymentOthers.Date, 'MM-dd-yyyy', 'en-US') DateOthersFormat
   ,UPPER(Users1.Name) AS CreatedByName
   ,UPPER(u2.Name) AS LastUpdatedByName
   ,UPPER(u3.Name) AS CompletedByName
  FROM dbo.PaymentOthers
  LEFT JOIN dbo.Providers
    ON dbo.PaymentOthers.ProviderId = dbo.Providers.ProviderId
  INNER JOIN dbo.Agencies
    ON dbo.PaymentOthers.AgencyId = dbo.Agencies.AgencyId
  LEFT OUTER JOIN dbo.Users
    ON dbo.PaymentOthers.DeletedBy = dbo.Users.UserId
  INNER JOIN dbo.Users AS Users1
    ON dbo.PaymentOthers.CreatedBy = Users1.UserId
  LEFT OUTER JOIN Users u2
    ON PaymentOthers.LastUpdatedBy = u2.UserId
  LEFT OUTER JOIN Users u3
    ON PaymentOthers.CompletedBy = u3.UserId
  LEFT JOIN PaymentOthersStatus pto
    ON PaymentOthers.PaymentOtherStatusId = pto.PaymentOtherStatusId

  WHERE ((CAST(dbo.PaymentOthers.CreationDate AS DATE) >= CAST(@DateFrom AS DATE)
  OR @DateFrom IS NULL)
  AND (CAST(dbo.PaymentOthers.CreationDate AS DATE) <= CAST(@DateTo AS DATE))
  OR @DateTo IS NULL)
  AND (dbo.PaymentOthers.AgencyId = @AgencyId
  OR @AgencyId IS NULL)
  -- si el card payment es mayor a 0 que me lo muestre, en caso de que sea -1 que me coloque card payment
  AND ((@ProviderId > 0
  AND dbo.PaymentOthers.ProviderId = @ProviderId)
  OR (
  @ProviderId = -1
  AND dbo.PaymentOthers.IsCardPayment = 1
  )
  OR @ProviderId IS NULL)
  AND (dbo.PaymentOthers.IsDebit = @Type
  OR @Type IS NULL)
  AND (pto.Code = @Status
  OR @Status IS NULL)

END;




GO