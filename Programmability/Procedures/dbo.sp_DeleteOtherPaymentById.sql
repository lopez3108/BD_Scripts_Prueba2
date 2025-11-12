SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteOtherPaymentById](@OtherPaymentId INT)
AS
    BEGIN
        DELETE FROM OtherPayments
        WHERE OtherPaymentId = @OtherPaymentId;
    END;
GO