SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllMoneyTransfersDailyByProvider]
(@Creationdate DATE = NULL,
 @AgencyId     INT,
 @CreatedBy    INT,
 @ProviderId   INT  = NULL
)
AS
     BEGIN
         SELECT m.MoneyTransfersId,
                m.ProviderId,
                m.CreatedBy UserId,
                m.CreatedBy,
                m.AgencyId,
                m.CreationDate,
                ISNULL(m.Usd, 0) moneyvalue,
                ISNULL(m.Transactions, 0) Transactions,
				ISNULL(m.TotalTransactions, 0) TotalTransactions,
                ISNULL(m.UsdMoneyOrders, 0) UsdMoneyOrders,
                ISNULL(m.TransactionsNumberMoneyOrders, 0) TransactionsNumberMoneyOrders,
				ISNULL(m.ProviderMoneyCommission, 0) ProviderMoneyCommission,
				ISNULL(m.MoneyOrderFee, 0) MoneyOrderFee,
				 m.LastUpdatedOn,
				 m.LastUpdatedBy,
         usu.Name LastUpdatedByName,
		ISNULL(m.AcceptNegative , 0)AcceptNegative,
		ISNULL(m.OnlyNegative , 0)OnlyNegative,
		 ISNULL(m.DetailedTransaction , 0) DetailedTransaction,
		 ISNULL(m.MoneyOrderService , 0) MoneyOrderService,
         m.ProviderService,
		 ps.Code ProviderServiceCode,
         ps.Description ProviderServiceDescription, 
		 ps.Translate ProviderServiceTranslate
         FROM MoneyTransfers m
		  LEFT JOIN dbo.ProvidersServices ps ON m.ProviderService = ps.ProviderServiceId
		  LEFT JOIN Users usu ON m.LastUpdatedBy = usu.UserId
         WHERE m.AgencyId = @AgencyId
               AND (CAST(m.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
               AND m.CreatedBy = @CreatedBy
               AND m.DailyId IS NULL
               AND (m.ProviderId = @ProviderId
                    OR @ProviderId IS NULL);
     END;
GO