SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-06-22 DJ/5923: City sticker created from Title and Plates form

CREATE PROCEDURE [dbo].[sp_SaveCitySticker]
(@CityStickerId  INT            = NULL,
 @USD            DECIMAL(18, 2),
 @Cash           DECIMAL(18, 2) = NULL,
 @Fee1           DECIMAL(18, 2),
 @FeeEls         DECIMAL(18, 2) ,
 @CreationDate   DATETIME,
 @AgencyId       INT,
 @IdCreated      INT OUTPUT,
 @CreatedBy      INT            = NULL,
 @CardPayment    BIT,
 @CardPaymentFee DECIMAL(18, 2)  = NULL,
 @UpdatedBy        INT, 
 @UpdatedOn        DATETIME,
 @CashierCommission DECIMAL (18, 2) = NULL,
 @TitleId INT = NULL --5923
)
AS
     BEGIN
         IF(@CityStickerId IS NULL)
             BEGIN
                 INSERT INTO [dbo].[CityStickers]
                 (USD,
				          Cash,
                  Fee1,
                  FeeEls,
                  CreationDate,
                  AgencyId,
                  CreatedBy,
                  CardPayment,
                  CardPaymentFee,
				         UpdatedBy, 
                 UpdatedOn,
                 CashierCommission,
				 TitleParentId
                 )
                 VALUES
                 (@Usd,
				          @Cash,
                  @Fee1,
                  @FeeEls,
                  @CreationDate,
                  @AgencyId,
                  @CreatedBy,
                  @CardPayment,
                  @CardPaymentFee,
				          @UpdatedBy, 
                  @UpdatedOn,
                  @CashierCommission,
				  @TitleId
                 );
                 SET @IdCreated = @@IDENTITY;
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].[CityStickers]
                   SET
                       USD = @Usd,
					             Cash = @Cash,
                       Fee1 = @Fee1,
                       FeeEls = @FeeEls,
                       CreationDate = @CreationDate,
                       CardPayment = @CardPayment,
                       CardPaymentFee = @CardPaymentFee,
					             UpdatedBy = @UpdatedBy, 
                       UpdatedOn = @UpdatedOn
--                       ComissionCashier= @ComissionCashier
                 WHERE CityStickerId = @CityStickerId;
                 SET @IdCreated = @CityStickerId;
         END;
     END;
GO