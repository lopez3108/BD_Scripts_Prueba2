SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteBillType](@BillTypeId INT)
AS
     BEGIN
         DELETE BillTypes
         WHERE BillTypeId = @BillTypeId;
	    SELECT 1;
     END;
GO