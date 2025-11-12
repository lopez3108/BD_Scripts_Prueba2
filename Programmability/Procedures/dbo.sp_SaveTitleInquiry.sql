SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveTitleInquiry]
(@TitleInquiryId INT            = NULL,
 @Usd            DECIMAL(18, 2),
 @Fee1           DECIMAL(18, 2), 
 @Cash           DECIMAL(18, 2) = NULL,
 @CreationDate   DATETIME,
 @AgencyId       INT,
 @CreatedBy      INT,
 @IdCreated      INT OUTPUT,
 @CardPayment    BIT,
 @CardPaymentFee DECIMAL(18, 2)     = NULL,
 @FeeEls           DECIMAL(18, 2),
 @UpdatedBy INT, 
 @UpdatedOn DATETIME
)
AS
     BEGIN
         IF(@TitleInquiryId IS NULL)
             BEGIN
                 INSERT INTO [dbo].[TitleInquiry]
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
                  UpdatedOn
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
                  @UpdatedOn
                 );
                 SET @IdCreated = @@IDENTITY;
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].[TitleInquiry]
                   SET
                       USD = @Usd,
                       Fee1 = @Fee1,
					   Cash = @Cash,
                       CreationDate = @CreationDate,
                       CreatedBy = @CreatedBy,
                       CardPayment = @CardPayment,
                       CardPaymentFee = @CardPaymentFee,
					   FeeEls = @FeeEls,
					   UpdatedBy = @UpdatedBy, 
                       UpdatedOn = @UpdatedOn
                 WHERE TitleInquiryId = @TitleInquiryId;
                 SET @IdCreated = 0;
         END;
     END;
GO