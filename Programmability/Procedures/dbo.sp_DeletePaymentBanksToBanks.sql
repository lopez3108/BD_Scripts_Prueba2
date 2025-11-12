SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePaymentBanksToBanks] 
@PaymentBanksToBankId INT,
@CurrentDate DATETIME
AS
BEGIN

IF(CAST(@CurrentDate as DATE) <> (SELECT TOP 1 CAST(CreationDate as DATE) FROM PaymentBanksToBanks WHERE
PaymentBanksToBankId = @PaymentBanksToBankId))
BEGIN

SELECT -1

END
ELSE
BEGIN

DELETE            dbo.PaymentBanksToBanks 
WHERE PaymentBanksToBankId = @PaymentBanksToBankId

SELECT @PaymentBanksToBankId

END

   



END
GO