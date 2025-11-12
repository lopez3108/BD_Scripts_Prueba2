SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveSystemToolsBill]
(@BillId          INT            = NULL, 
 @CreationDate    DATETIME       = NULL, 
 @CreatedBy       INT            = NULL, 
 @LastUpdatedOn DATETIME       = NULL, 
 @LastUpdatedBy    INT            = NULL, 
 @Total           DECIMAL(18, 2), 
 @Cash            DECIMAL(18, 2)  = NULL, 
 @Change          DECIMAL(18, 2)  = NULL, 
 @CardPayment     BIT, 
 @CardPaymentFee  DECIMAL(18, 2), 
 @AgencyId        INT            = NULL, 
 @IdCreated       INT OUTPUT
)
AS
    BEGIN
        IF(@BillId IS NULL)
            BEGIN
                INSERT INTO [dbo].SystemToolsBill
                (CreationDate, 
                 CreatedBy, 
                 Total, 
                 Cash, 
                 Change, 
                 CardPayment, 
                 CardPaymentFee, 
                 AgencyId, 
                 LastUpdatedOn, 
                 LastUpdatedBy
                )
                VALUES
                (@CreationDate, 
                 @CreatedBy, 
                 @Total, 
                 @Cash, 
                 @Change, 
                 @CardPayment, 
                 @CardPaymentFee, 
                 @AgencyId, 
                 @LastUpdatedOn, 
                 @LastUpdatedBy
                );
                SET @IdCreated = @@IDENTITY;
            END;
            ELSE
            BEGIN
                UPDATE [dbo].SystemToolsBill
                  SET 
                      --CreationDate = @CreationDate, 
                      --CreatedBy = @CreatedBy, 
                      Total = @Total, 
                      Cash = @Cash, 
                      Change = @Change, 
                      CardPayment = @CardPayment, 
                      CardPaymentFee = @CardPaymentFee, 
                      --AgencyId = @AgencyId, 
                      LastUpdatedOn = @LastUpdatedOn, 
                      LastUpdatedBy = @LastUpdatedBy
                WHERE BillId = @BillId;
                SET @IdCreated = @BillId;
            END;
    END;
GO