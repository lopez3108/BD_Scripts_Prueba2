SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveSystemToolsValues] @BillxBillValueId INT = NULL,
@BillId INT,
@Value DECIMAL(18, 2),
@Fee DECIMAL(18, 2),
@IdCreated INT OUTPUT
AS
BEGIN
  IF (@BillxBillValueId IS NULL)
  BEGIN
    INSERT INTO [dbo].SystemToolsValues (BillId,
    Value,
    Fee)
      VALUES (@BillId, @Value, @Fee);
    SET @IdCreated = @@IDENTITY;
  END;
  ELSE
  BEGIN
    UPDATE [dbo].SystemToolsValues
    SET BillId = @BillId
       ,Value = @Value
       ,Fee = @Fee
    WHERE BillxBillValueId = @BillxBillValueId;
    SET @IdCreated = @BillxBillValueId;
  END;
END;
GO