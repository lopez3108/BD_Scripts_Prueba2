SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_SaveCardPayment]
(@CardPaymentId INT            = NULL, 
 @Usd           DECIMAL(18, 2) = NULL, 
 @Fee           DECIMAL(18, 2)  = NULL, 
  @FeeUsd         DECIMAL(18, 2)  = NULL, 
 @TotalPay           DECIMAL(18, 2)  = NULL, 
  @NumberPayments     INT = NULL, 
   @Batch      BIT, 
 @AgencyId      INT, 
 @CreatedBy     INT, 
 @CreationDate  DATETIME, 
 @LastUpdatedBy INT, 
 @LastUpdatedOn DATETIME, 
 @IdCreated     INT OUTPUT
)
AS
    BEGIN
        IF(@CardPaymentId IS NULL)
            BEGIN
                INSERT INTO [dbo].CardPayments
                (Usd, 
                 Fee, 
                 AgencyId, 
                 CreatedBy, 
                 CreationDate, 
                 LastUpdatedBy, 
                 LastUpdatedOn,
                 FeeUsd,
                 TotalPay,
                 NumberPayments,
Batch
                )
                VALUES
                (@Usd, 
                 @Fee, 
                 @AgencyId, 
                 @CreatedBy, 
                 @CreationDate, 
                 @LastUpdatedBy, 
                 @LastUpdatedOn,
                 @FeeUsd,
                 @TotalPay,
                 @NumberPayments,
                 @Batch
                );
                SET @IdCreated = @@IDENTITY;
            END;
            ELSE
            BEGIN
                UPDATE [dbo].CardPayments
                  SET 
                      Usd = @Usd, 
                      Fee = @Fee, 
                          FeeUsd = @FeeUsd, 
                          TotalPay = @TotalPay,
                          Batch= @Batch,
                     
                      NumberPayments = @NumberPayments,
                      LastUpdatedBy = @LastUpdatedBy, 
                      LastUpdatedOn = @LastUpdatedOn
                WHERE CardPaymentId = @CardPaymentId;
                SET @IdCreated = 0;
            END;
    END;
GO