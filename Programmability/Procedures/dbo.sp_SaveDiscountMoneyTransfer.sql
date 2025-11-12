SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveDiscountMoneyTransfer]
(@DiscountMoneyTransferId INT            = NULL,
 @ProviderId              INT,
 @Number                  VARCHAR(10),
 @Usd                     DECIMAL(18, 2),
 @Fee                     DECIMAL(18, 2),
 @Discount                DECIMAL(18, 2),
 @ActualClient            VARCHAR(50),
 @ReferedClient           VARCHAR(50) = NULL,
 @CreationDate            DATETIME,
 @CreatedBy               INT,
 @AgencyId                INT,
 @IdCreated               INT OUTPUT,
 @IsActualClient               BIT            = NULL,
  @LastUpdatedBy INT, 
 @LastUpdatedOn DATETIME,
 @ActualClientTelephone varchar(10),
 @TelIsCheck bit = null
)
AS
     BEGIN
         IF(@DiscountMoneyTransferId IS NULL)
             BEGIN
                 INSERT INTO [dbo].DiscountMoneyTransfers
                 (ProviderId,
                  Number,
                  Usd,
                  Fee,
                  Discount,
                  ActualClient,
                  ReferedClient,
                  CreationDate,
                  CreatedBy,
                  AgencyId,
				  IsActualClient ,
				  LastUpdatedBy, 
                 LastUpdatedOn,
				  ActualClientTelephone,
				 TelIsCheck
                 )
                 VALUES
                 (@ProviderId,
                  @Number,
                  @Usd,
                  @Fee,
                  @Discount,
                  @ActualClient,
                  @ReferedClient,
                  @CreationDate,
                  @CreatedBy,
                  @AgencyId,
				  @IsActualClient ,
				   @LastUpdatedBy, 
                 @LastUpdatedOn,
				  @ActualClientTelephone,
				 @TelIsCheck
                 );
                 SET @IdCreated = @@IDENTITY;
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].DiscountMoneyTransfers
                   SET
                       ProviderId = @ProviderId,
                       Number = @Number,
                       Usd = @Usd,
                       Fee = @Fee,
                       Discount = @Discount,
                       ActualClient = @ActualClient,
                       ReferedClient = @ReferedClient,
                       CreationDate = @CreationDate,
                       CreatedBy = @CreatedBy,
                       AgencyId = @AgencyId,
					   IsActualClient =@IsActualClient ,
					   LastUpdatedBy = @LastUpdatedBy, 
                      LastUpdatedOn = @LastUpdatedOn,
					   ActualClientTelephone = @ActualClientTelephone,
					  TelIsCheck = @TelIsCheck
                 WHERE DiscountMoneyTransferId = @DiscountMoneyTransferId;
                 SET @IdCreated = 0;
         END;
     END;
GO