SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreatePhoneSale]    
          @PhoneSalesId        INT            = NULL, 
          @InventoryByAgencyId INT, 
          @PurchaseValue       DECIMAL(18, 2), 
          @SellingValue        DECIMAL(18, 2), 
          @CreationDate        DATETIME, 
          @CreatedBy           INT, 
          @Imei                VARCHAR(10), 
          @ImeiId              INT, 
          @CardPayment         BIT, 
          @CardPaymentFee      DECIMAL(18, 2)            = NULL, 
          @PhonePlanId         INT            = NULL, 
          @OnlyPhone           BIT, 
          @LastUpdatedBy       INT, 
          @LastUpdatedOn       DATETIME, 
          @Tax                 DECIMAL(18, 2),
          @Cash                DECIMAL(18, 2) = NULL,
          @CashierCommission   DECIMAL (18, 2) = NULL
AS
    BEGIN
        DECLARE @createdSale INT;
        IF(@PhoneSalesId IS NULL)
            BEGIN
                -- Creates the sale
                INSERT INTO [dbo].[PhoneSales]
                ([InventoryByAgencyId], 
                 [PurchaseValue], 
                 [SellingValue], 
                 [CreationDate], 
                 [CreatedBy], 
                 [Imei], 
                 PhonePlanId, 
                 CardPayment, 
                 CardPaymentFee, 
                 OnlyPhone, 
                 Tax, 
				         LastUpdatedOn,
                 LastUpdatedBy,
				         Cash,
                 CashierCommission
                 
                )
                VALUES
                (@InventoryByAgencyId, 
                 @PurchaseValue, 
                 @SellingValue, 
                 @CreationDate, 
                 @CreatedBy, 
                 @Imei, 
                 @PhonePlanId, 
                 @CardPayment, 
                 @CardPaymentFee, 
                 @OnlyPhone, 
                 @Tax, 
				         @LastUpdatedOn,
                 @LastUpdatedBy,
			         	 @Cash,
                 @CashierCommission
                 
                );
                SET @createdSale = @@IDENTITY;

                -- Updates the inventory
                UPDATE [dbo].[InventoryByAgency]
                  SET 
                      [InStock] = [InStock] - 1
                WHERE InventoryByAgencyId = @InventoryByAgencyId;
                -- Deletes the imei
                DELETE FROM [dbo].[Imei]
                WHERE ImeiId = @ImeiId;
            END;
            ELSE
            BEGIN
                UPDATE [dbo].[PhoneSales]
                  SET 
                      CardPayment = @CardPayment, 
                      CardPaymentFee = @CardPaymentFee, 
                      OnlyPhone = @OnlyPhone, 
                      Tax = @Tax, 
                      LastUpdatedBy = @LastUpdatedBy, 
                      LastUpdatedOn = @LastUpdatedOn,
					  Cash   =        @Cash
                WHERE PhoneSalesId = @PhoneSalesId;
                SET @createdSale = @PhoneSalesId;
            END;
        SELECT @createdSale;
    END;

GO