SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePaymentBank] 
@PaymentBankId INT,
@CurrentDate DATETIME
AS
BEGIN

IF(CAST(@CurrentDate as DATE) <> (SELECT TOP 1 CAST(CreationDate as DATE) FROM PaymentBanks WHERE
PaymentBankId = @PaymentBankId))
BEGIN

SELECT -1

END
ELSE
BEGIN

DELETE            dbo.PaymentBanks 
WHERE PaymentBankId = @PaymentBankId

SELECT @PaymentBankId

END

   



END
GO