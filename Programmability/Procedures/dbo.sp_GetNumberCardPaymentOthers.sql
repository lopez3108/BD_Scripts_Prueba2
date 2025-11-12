SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetNumberCardPaymentOthers] (@CardOtherPayments BIT)
AS
  -- Siempre que se consulta un other payment en las alertas estará en pending
  DECLARE @PaymentOthersStatusId INT
  SET @PaymentOthersStatusId = (SELECT TOP 1
      pos.PaymentOtherStatusId
    FROM PaymentOthersStatus pos
    WHERE pos.Code = 'C01')
  SELECT
    COUNT(po.PaymentOthersId) AS NumberCardOtherPayments
  FROM PaymentOthers po
  WHERE po.IsDebit = @CardOtherPayments
  AND po.PaymentOtherStatusId = @PaymentOthersStatusId
GO