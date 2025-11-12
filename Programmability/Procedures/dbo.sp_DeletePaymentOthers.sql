SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePaymentOthers] @PaymentOthersId INT,
@DeletedOn DATETIME,
@DeletedBy INT,
@Date DATETIME

AS
BEGIN
  -- Siempre que se cree un other payment estará en pending
  DECLARE @PaymentOthersStatusId INT
  SET @PaymentOthersStatusId = (SELECT TOP 1
      pos.PaymentOtherStatusId
    FROM PaymentOthersStatus pos
    WHERE pos.Code = 'C03')

  UPDATE [dbo].[PaymentOthers]
  SET [DeletedOn] = @DeletedOn
     ,[DeletedBy] = @DeletedBy
     ,[Date] = @Date
     ,PaymentOtherStatusId = @PaymentOthersStatusId
  WHERE PaymentOthersId = @PaymentOthersId

  SELECT
    @PaymentOthersId


END;
GO