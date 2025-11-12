SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPaymentCash] @AgencyId   INT      = NULL, 
                                          @ProviderId INT      = NULL, 
                                          @DateFrom   DATETIME = NULL, 
                                          @DateTo     DATETIME = NULL, 
                                          @Status     INT      = NULL
AS
    BEGIN
        SELECT dbo.PaymentCash.PaymentCashId, 
               ISNULL(dbo.PaymentCash.AgencyId, '') AS AgencyId, 
               dbo.Agencies.Name AS AgencyName, 
               dbo.Agencies.Code + ' - ' + dbo.Agencies.Name AS AgencyCodeName, 
               ISNULL(dbo.PaymentCash.ProviderId, '') AS ProviderId, 
               dbo.Providers.Name + ISNULL(
        (
            SELECT TOP 1 ' - ' + dbo.MoneyTransferxAgencyNumbers.Number
            FROM dbo.MoneyTransferxAgencyNumbers
            WHERE dbo.MoneyTransferxAgencyNumbers.AgencyId = dbo.PaymentCash.AgencyId
                  AND dbo.MoneyTransferxAgencyNumbers.ProviderId = dbo.PaymentCash.ProviderId
        ), '') AS ProviderName, 
               dbo.PaymentCash.USD, 
               dbo.PaymentCash.CreationDate,
			   FORMAT(PaymentCash.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
               dbo.PaymentCash.DeletedOn, 
			   FORMAT(PaymentCash.DeletedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  DeletedOnFormat,
               UPPER(dbo.Users.Name) AS DeletedBy,
               CASE
                   WHEN dbo.PaymentCash.STATUS = '1'
                   THEN 'PENDING'
                   WHEN dbo.PaymentCash.STATUS = '2'
                   THEN 'COMPLETE'
                   WHEN dbo.PaymentCash.STATUS = '3'
                   THEN 'DELETED'
               END AS Status, 
			          CASE
                   WHEN dbo.PaymentCash.STATUS = '1'
                   THEN 'PENDING'
                   WHEN dbo.PaymentCash.STATUS = '2'
                   THEN 'COMPLETED'
                   WHEN dbo.PaymentCash.STATUS = '3'
                   THEN 'DELETED'
               END AS StatusName, 
               dbo.PaymentCash.FileImageName, 
               dbo.PaymentCash.Date, 
			   FORMAT(PaymentCash.Date, 'MM-dd-yyyy', 'en-US')  DateCashFormat,
               UPPER(Users1.Name) AS CreatedByName
        FROM dbo.PaymentCash
             LEFT JOIN dbo.Providers ON dbo.PaymentCash.ProviderId = dbo.Providers.ProviderId
             LEFT JOIN dbo.Agencies ON dbo.PaymentCash.AgencyId = dbo.Agencies.AgencyId
             LEFT OUTER JOIN dbo.Users ON dbo.PaymentCash.DeletedBy = dbo.Users.UserId
             INNER JOIN dbo.Users AS Users1 ON dbo.PaymentCash.CreatedBy = Users1.UserId
        WHERE(dbo.PaymentCash.AgencyId = @AgencyId
              OR @AgencyId IS NULL
              OR dbo.PaymentCash.AgencyId IS NULL)
             AND (dbo.PaymentCash.ProviderId = @ProviderId
                  OR @ProviderId IS NULL
                  OR dbo.PaymentCash.ProviderId IS NULL)
             AND (dbo.PaymentCash.STATUS = @Status
                  OR @Status IS NULL)
             AND ((CAST(dbo.PaymentCash.CreationDate AS DATE) >= CAST(@DateFrom AS DATE)
                   OR @DateFrom IS NULL)
                  AND (CAST(dbo.PaymentCash.CreationDate AS DATE) <= CAST(@DateTo AS DATE)
                       OR @DateTo IS NULL));
    END;
GO