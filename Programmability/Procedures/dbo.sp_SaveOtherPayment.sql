SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveOtherPayment]
(@OtherPaymentId INT            = NULL,
 @Description    VARCHAR(150) = null,
 @Usd            DECIMAL(18, 2) = NULL,
 @CardPayment    BIT,
  @PayMissing    BIT,
 @CardPaymentFee DECIMAL(18, 2)  = NULL,
 @AgencyId       INT,
 @CreatedBy      INT,
 @CreationDate   DATETIME,
 @IdCreated      INT OUTPUT,
 @LastUpdatedBy INT, 
 @LastUpdatedOn DATETIME,
 @Cash         DECIMAL(18, 2)  = NULL,
  @UsdMissing DECIMAL(18, 2)  = NULL,
  @UsdPayMissing DECIMAL(18, 2)  = NULL
)
AS
     BEGIN
         IF(@OtherPaymentId IS NULL)
             BEGIN
                 INSERT INTO [dbo].[OtherPayments]
                 (Description,
                  Usd,
                  CardPayment,
                  CardPaymentFee,
                  AgencyId,
                  CreatedBy,
                  CreationDate,
				  LastUpdatedBy, 
                 LastUpdatedOn,
				 Cash,
				 PayMissing,
				 UsdMissing,
				 UsdPayMissing
                 )
                 VALUES
                 (@Description,
                  @Usd,
                  @CardPayment,
                  @CardPaymentFee,
                  @AgencyId,
                  @CreatedBy,
                  @CreationDate,
				  @LastUpdatedBy, 
                  @LastUpdatedOn,
				  @Cash,
				  @PayMissing,
				  @UsdMissing,
				  @UsdPayMissing
                 );
                 SET @IdCreated = @@IDENTITY;
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].[OtherPayments]
                   SET
                       Description = @Description,
                       Usd = @Usd,
                       CardPayment = @CardPayment,
                       CardPaymentFee = @CardPaymentFee,
					   LastUpdatedBy = @LastUpdatedBy, 
                       LastUpdatedOn = @LastUpdatedOn,
					   Cash   =        @Cash
                 WHERE OtherPaymentId = @OtherPaymentId;
                 SET @IdCreated = 0;
         END;
     END;
GO