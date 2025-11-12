SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateMoneyTransfer]
(@MoneyTransfersId              INT            = NULL,
 @ProviderId                    INT,
 @Transactions                  INT            = NULL,
 @TotalTransactions                  INT            = NULL,
 @Usd                           DECIMAL(18, 2)  = NULL,
 @TransactionsNumberMoneyOrders INT            = NULL,
 @UsdMoneyOrders                DECIMAL(18, 2)  = NULL,
 @UserId                        INT,
 @AgencyId                      INT,
 @CreationDate                  DATETIME,
 @MoneyOrderFee                 DECIMAL(18, 2)  = NULL,
 @ProviderMoneyCommission       DECIMAL(18, 2)  = NULL,
 @LastUpdatedBy INT, 
 @LastUpdatedOn DATETIME,
 @AcceptNegative BIT            = NULL,
 @DetailedTransaction BIT            = NULL,
 @MoneyOrderService BIT            = NULL,
 @ProviderService INT = NULL,
  @OnlyNegative BIT            = NULL
)
AS
     BEGIN
         IF(@MoneyTransfersId IS NULL
            OR @MoneyTransfersId = 0)
             BEGIN
			 	 IF(@Transactions > 0 OR @TotalTransactions > 0 OR @Usd > 0 OR @TransactionsNumberMoneyOrders > 0 OR @UsdMoneyOrders > 0)
			 BEGIN
                 INSERT INTO [dbo].[MoneyTransfers]
                 ([ProviderId],
                  [Transactions],
			   TotalTransactions,
                  [Usd],
                  TransactionsNumberMoneyOrders,
                  UsdMoneyOrders,
                  [CreatedBy],
                  [AgencyId],
                  CreationDate,
                  MoneyOrderFee,
                  ProviderMoneyCommission,
				  LastUpdatedBy, 
                 LastUpdatedOn,
				 AcceptNegative,--Este campo solo se guarda la primera vez, no se debe editar
				 DetailedTransaction,--Este campo solo se guarda la primera vez, no se debe editar
				 MoneyOrderService,--Este campo solo se guarda la primera vez, no se debe editar
         ProviderService,
		 OnlyNegative
                 )
                 VALUES
                 (@ProviderId,
                  @Transactions,
			   @TotalTransactions,
                  @Usd,
                  @TransactionsNumberMoneyOrders,
                  @UsdMoneyOrders,
                  @UserId,
                  @AgencyId,
                  @CreationDate,
                  @MoneyOrderFee,
                  @ProviderMoneyCommission,
				   @LastUpdatedBy, 
                 @LastUpdatedOn,
				 @AcceptNegative,
				 @DetailedTransaction,
				 @MoneyOrderService,
         @ProviderService,
		 @OnlyNegative
                 );
				 END
         END;
             ELSE
             BEGIN
			 IF(@Transactions > 0 OR @TotalTransactions > 0 OR @Usd > 0 OR @TransactionsNumberMoneyOrders > 0 OR @UsdMoneyOrders > 0)
			 BEGIN
                 UPDATE [dbo].[MoneyTransfers]
                   SET
                       USD = @Usd,
                       [Transactions] = @Transactions,
				   TotalTransactions = @Transactions, --[Transactions] y TotalTransactions siempre deben llevar el mismo valor task 5062 JT 
                       TransactionsNumberMoneyOrders = @TransactionsNumberMoneyOrders,
                       UsdMoneyOrders = @UsdMoneyOrders,
                       ProviderId = @ProviderId,
                       CreatedBy = @UserId,
                       CreationDate = @CreationDate,
                       MoneyOrderFee = @MoneyOrderFee,
                       ProviderMoneyCommission = @ProviderMoneyCommission,
					    LastUpdatedBy = @LastUpdatedBy, 
                      LastUpdatedOn = @LastUpdatedOn
                 WHERE MoneyTransfersId = @MoneyTransfersId;
			END
         END;
     END;
GO