SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteSystemToolsValuesById] @BillId INT
AS
    BEGIN
        DELETE SystemToolsValues
        WHERE BillxBillValueId = @BillId;
    END;
GO