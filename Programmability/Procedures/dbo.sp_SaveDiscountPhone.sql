SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveDiscountPhone]
(@DiscountPhoneId INT            = NULL,
 @PhoneSaleId     INT,
 @Usd             DECIMAL(18, 2),
 @Discount        DECIMAL(18, 2),
 @CreationDate    DATETIME,
 @CreatedBy       INT,
 @AgencyId        INT,
 @IdCreated       INT OUTPUT,
  @LastUpdatedBy INT, 
 @LastUpdatedOn DATETIME,
  @ActualClientTelephone varchar(10),
 @TelIsCheck bit = null
)
AS
     BEGIN
         IF(@DiscountPhoneId IS NULL)
             BEGIN
                 INSERT INTO [dbo].DiscountPhones
                 (PhoneSaleId,
                  Usd,
                  Discount,                
                  CreationDate,
                  CreatedBy,
                  AgencyId,
				   LastUpdatedBy, 
                 LastUpdatedOn,
				 ActualClientTelephone,
				 TelIsCheck
                 )
                 VALUES
                 (@PhoneSaleId,
                  @Usd,
                  @Discount,                  
                  @CreationDate,
                  @CreatedBy,
                  @AgencyId,
				   @LastUpdatedBy, 
                 @LastUpdatedOn,
				  @ActualClientTelephone,
				 @TelIsCheck
                 );
                 SET @IdCreated = @@IDENTITY;
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].DiscountPhones
                   SET
                       PhoneSaleId = PhoneSaleId,
                       Usd = @Usd,
                       Discount = @Discount,
					   LastUpdatedBy = @LastUpdatedBy, 
                      LastUpdatedOn = @LastUpdatedOn,
					   ActualClientTelephone = @ActualClientTelephone,
					  TelIsCheck = @TelIsCheck
                 WHERE DiscountPhoneId = @DiscountPhoneId;
                 SET @IdCreated = 0;
         END;
     END;
GO