SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_SaveTicketFeeService]
(@TicketFeeServiceId INT            = NULL, 
 @Usd                DECIMAL(18, 2), 
 @UsedCard           BIT            = NULL, 
 @AgencyId           INT            = NULL, 
 @CreatedBy          INT            = NULL, 
 @CreationDate       DATETIME       = NULL, 
 @CardPaymentFee     DECIMAL(18, 2)  = NULL, 
 @UpdatedBy          INT            = NULL, 
 @UpdatedOn          DATETIME       = NULL, 
 @Plus               INT            = NULL, 
 @Cash               DECIMAL(18, 2)  = NULL,
 @IdCreated          INT OUTPUT
)
AS
    BEGIN
        IF(@TicketFeeServiceId IS NULL)
            BEGIN
                INSERT INTO [dbo].TicketFeeServices
                (Usd, 
                 UsedCard, 
                 AgencyId, 
                 CreatedBy, 
                 CreationDate, 
                 CardPaymentFee, 
                 UpdatedBy, 
                 UpdatedOn, 
                 Plus, 
                 Cash
                 
                )
                VALUES
                (@Usd, 
                 @UsedCard, 
                 @AgencyId, 
                 @CreatedBy, 
                 @CreationDate, 
                 @CardPaymentFee, 
                 @UpdatedBy, 
                 @UpdatedOn, 
                 @Plus, 
                 @Cash
             
                );
                SET @IdCreated = @@IDENTITY;
            END;
            ELSE
            BEGIN
                UPDATE [dbo].TicketFeeServices
                  SET 
                      Usd = @Usd, 
                      UsedCard = @UsedCard, 
                      CardPaymentFee = @CardPaymentFee, 
                      UpdatedBy = @UpdatedBy, 
                      UpdatedOn = @UpdatedOn, 
                      Plus = @Plus, 
                      Cash = @Cash
                WHERE TicketFeeServiceId = @TicketFeeServiceId;
                SET @IdCreated = @TicketFeeServiceId;
            END;
    END;



GO