SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSumProvidersMoneyTransferByProviderIdByDateDailyByAgency] @ProviderId   INT      = NULL,
                                                                                        @CreationDate DATETIME,
                                                                                        @AgencyId     INT
AS
     BEGIN
         SELECT ISNULL(SUM(b.Usd), 0) AS Suma
         FROM MoneyTransfers b
         WHERE b.ProviderId = @ProviderId
               AND b.AgencyId = @AgencyId
               AND (CAST(b.CreationDate AS DATE) = CAST(@CreationDate AS DATE));
     END;
GO