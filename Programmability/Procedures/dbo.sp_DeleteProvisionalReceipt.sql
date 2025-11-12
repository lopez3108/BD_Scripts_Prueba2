SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteProvisionalReceipt](@ProvisionalReceiptId INT)
AS
     BEGIN
         DELETE ProvisionalReceipts
         WHERE ProvisionalReceiptId = @ProvisionalReceiptId;
         SELECT 1;
     END;
GO