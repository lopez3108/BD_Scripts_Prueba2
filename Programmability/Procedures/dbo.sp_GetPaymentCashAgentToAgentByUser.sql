SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPaymentCashAgentToAgentByUser] @AgencyId     INT,
                                          @FromAgencyId INT      = NULL,
                                          @ProviderId   INT      = NULL,
                                          @DateFrom     DATETIME,
                                          @DateTo       DATETIME
AS
     BEGIN
         SELECT dbo.PaymentCashAgentToAgent.PaymentCashId,
                AgenciesFrom.AgencyId FromAgencyId,
                AgenciesFrom.Name AS FromAgencyName,
                dbo.Agencies.AgencyId,
                dbo.Agencies.Name AS AgencyName,
                dbo.Providers.ProviderId,
                dbo.Providers.Name+ISNULL(
                                         (
                                             SELECT TOP 1 ' - '+dbo.MoneyTransferxAgencyNumbers.Number
                                             FROM dbo.MoneyTransferxAgencyNumbers
                                             WHERE dbo.MoneyTransferxAgencyNumbers.AgencyId = dbo.PaymentCashAgentToAgent.AgencyId
                                                   AND dbo.MoneyTransferxAgencyNumbers.ProviderId = dbo.PaymentCashAgentToAgent.ProviderId
                                         ), '') AS ProviderName,
                dbo.PaymentCashAgentToAgent.USD,
                dbo.PaymentCashAgentToAgent.CreationDate,
                dbo.PaymentCashAgentToAgent.DeletedOn,
                UPPER(dbo.Users.Name) AS DeletedBy,
                CASE
                    WHEN dbo.PaymentCashAgentToAgent.DeletedOn IS NOT NULL
                    THEN 'DELETED'
                    ELSE 'ACTIVE'
                END AS Status,
                dbo.PaymentCashAgentToAgent.Date,
                UPPER(Users1.Name) AS CreatedByName
         FROM dbo.PaymentCashAgentToAgent
              INNER JOIN dbo.Providers ON dbo.PaymentCashAgentToAgent.ProviderId = dbo.Providers.ProviderId
              INNER JOIN dbo.Agencies ON dbo.PaymentCashAgentToAgent.AgencyId = dbo.Agencies.AgencyId
              INNER JOIN dbo.Agencies AgenciesFrom ON dbo.PaymentCashAgentToAgent.FromAgencyId = AgenciesFrom.AgencyId
              LEFT OUTER JOIN dbo.Users ON dbo.PaymentCashAgentToAgent.DeletedBy = dbo.Users.UserId
              INNER JOIN dbo.Users AS Users1 ON dbo.PaymentCashAgentToAgent.CreatedBy = Users1.UserId
         WHERE dbo.PaymentCashAgentToAgent.AgencyId = @AgencyId
               AND (dbo.PaymentCashAgentToAgent.FromAgencyId = @FromAgencyId
                    OR @FromAgencyId IS NULL)
               AND dbo.PaymentCashAgentToAgent.ProviderId = CASE
                                                    WHEN @ProviderId IS NULL
                                                    THEN dbo.PaymentCashAgentToAgent.ProviderId
                                                    ELSE @ProviderId
                                                END
               AND CAST(dbo.PaymentCashAgentToAgent.CreationDate AS DATE) >= CAST(@DateFrom AS DATE)
               AND CAST(dbo.PaymentCashAgentToAgent.CreationDate AS DATE) <= CAST(@DateTo AS DATE)
     END;
GO