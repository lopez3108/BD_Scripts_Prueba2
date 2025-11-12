SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveCountryTax]
(@CountryTaxId   INT            = NULL,
 @USD            DECIMAL(18, 2), 
 @Cash           DECIMAL(18, 2) = NULL,
 @Fee1           DECIMAL(18, 2),
 @FeeEls         DECIMAL(18, 2),
 @CreationDate   DATETIME,
 @AgencyId       INT,
 @UserId         INT,
 @CardPayment    BIT,
 @CardPaymentFee DECIMAL(18, 2)            = NULL,
 @IdCreated      INT OUTPUT,
 @UpdatedBy INT, 
 @UpdatedOn DATETIME
)
AS
     BEGIN
         IF(@CountryTaxId IS NULL)
             BEGIN
                 INSERT INTO [dbo].[CountryTaxes]
                 (USD,
				  Cash,
                  Fee1,
                  CreationDate,
                  AgencyId,
                  CreatedBy,
                  CardPayment,
                  CardPaymentFee,
                  FeeEls,
				  UpdatedBy, 
                 UpdatedOn
                 )
                 VALUES
                 (@Usd,
				 @Cash,
                  @Fee1,
                  @CreationDate,
                  @AgencyId,
                  @UserId,
                  @CardPayment,
                  @CardPaymentFee,
                  @FeeEls,
				  @UpdatedBy, 
                 @UpdatedOn
                 );
                 SET @IdCreated = @@IDENTITY;
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].[CountryTaxes]
                   SET
                       USD = @Usd,
					   Cash = @Cash,
                       Fee1 = @Fee1,
                       CreationDate = @CreationDate,
                       CardPayment = @CardPayment,
                       CardPaymentFee = @CardPaymentFee,
                       FeeEls = @FeeEls,
					   UpdatedBy = @UpdatedBy, 
                      UpdatedOn = @UpdatedOn
                 WHERE CountryTaxId = @CountryTaxId;
                 SET @IdCreated = 0;
         END;
     END;
GO