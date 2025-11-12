SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_UpdateOtherPayments]
(@OtherPaymentId INT            = NULL, 
 @Cash               DECIMAL(18, 2)  = NULL
)
AS
    BEGIN
        UPDATE [dbo].OtherPayments
          SET   Cash = @Cash
        WHERE OtherPaymentId = @OtherPaymentId;
    END;
GO