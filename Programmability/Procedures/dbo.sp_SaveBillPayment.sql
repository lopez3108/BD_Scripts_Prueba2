SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveBillPayment]
(@BillPaymentId INT            = NULL, 
 @ProviderId    INT, 
 @Usd           DECIMAL(18, 2), 
 @Commission    DECIMAL(18, 2)  = NULL, 
 @CreationDate  DATETIME, 
 @AgencyId      INT, 
 @CreatedBy     INT, 
 @LastUpdatedBy INT, 
 @LastUpdatedOn DATETIME,
 @DetailedTransaction BIT = NULL
)
AS
    BEGIN
        IF(@BillPaymentId IS NULL)
            BEGIN
                INSERT INTO [dbo].BillPayments
                (USD, 
                 ProviderId, 
                 CreationDate, 
                 AgencyId, 
                 CreatedBy, 
                 Commission, 
                 LastUpdatedBy, 
                 LastUpdatedOn,
				  DetailedTransaction--Este campo solo se guarda la primera vez, no se debe editar
                )
                VALUES
                (@Usd, 
                 @ProviderId, 
                 @CreationDate, 
                 @AgencyId, 
                 @CreatedBy, 
                 @Commission, 
                 @LastUpdatedBy, 
                 @LastUpdatedOn,
				 @DetailedTransaction
                );
            END;
            ELSE
            BEGIN
                UPDATE [dbo].BillPayments
                  SET 
                      USD = @Usd, 
                      ProviderId = @ProviderId, 
                      CreatedBy = @CreatedBy, 
                      CreationDate = @CreationDate, 
                      Commission = @Commission, 
                      LastUpdatedBy = @LastUpdatedBy, 
                      LastUpdatedOn = @LastUpdatedOn
                WHERE BillPaymentId = @BillPaymentId;
            END;
    END;
GO