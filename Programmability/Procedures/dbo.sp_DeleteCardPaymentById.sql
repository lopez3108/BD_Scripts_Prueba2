SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteCardPaymentById](@CardPaymentId INT)
AS
    BEGIN
        DELETE FROM CardPayments
        WHERE CardPaymentId = @CardPaymentId;
    END;
GO