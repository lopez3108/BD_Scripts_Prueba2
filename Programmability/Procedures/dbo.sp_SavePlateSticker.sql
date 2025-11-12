SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_SavePlateSticker]
(@PlateStickerId INT            = NULL, 
 @Usd            DECIMAL(18, 2),  
 @Cash           DECIMAL(18, 2) = NULL,
 @Fee1           DECIMAL(18, 2), 
 @CreationDate   DATETIME, 
 @AgencyId       INT, 
 @IdCreated      INT OUTPUT, 
 @CreatedBy      INT            = NULL, 
 @CardPayment    BIT, 
 @CardPaymentFee DECIMAL(18, 2)          = NULL, 
 @FeeEls         DECIMAL(18, 2), 
 @UpdatedBy      INT, 
 @UpdatedOn      DATETIME,
 @CashierCommission DECIMAL (18, 2) = NULL
)
AS
    BEGIN
        IF(@PlateStickerId IS NULL)
            BEGIN
                INSERT INTO [dbo].[PlateStickers]
                (USD, 
                 Fee1, 
				         Cash,
                 CreationDate, 
                 AgencyId, 
                 CreatedBy, 
                 CardPayment, 
                 CardPaymentFee, 
                 FeeEls, 
                 UpdatedBy, 
                 UpdatedOn,
                 CashierCommission
                )
                VALUES
                (@Usd, 
                 @Fee1, 
				         @Cash, 
                 @CreationDate, 
                 @AgencyId, 
                 @CreatedBy, 
                 @CardPayment, 
                 @CardPaymentFee, 
                 @FeeEls, 
                 @UpdatedBy, 
                 @UpdatedOn,
                 @CashierCommission
                );
                SET @IdCreated = @@IDENTITY;
            END;
            ELSE
            BEGIN
                UPDATE [dbo].[PlateStickers]
                  SET 
                      USD = @Usd, 
                      Fee1 = @Fee1, 
					            Cash = @Cash,
                      CreationDate = @CreationDate, 
                      CardPayment = @CardPayment, 
                      CardPaymentFee = @CardPaymentFee, 
                      FeeEls = @FeeEls, 
                      UpdatedBy = @UpdatedBy, 
                      UpdatedOn = @UpdatedOn
                WHERE PlateStickerId = @PlateStickerId;
                SET @IdCreated = @PlateStickerId;
            END;
    END;
GO