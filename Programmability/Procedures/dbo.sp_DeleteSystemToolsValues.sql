SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteSystemToolsValues] @BillId INT
AS
    BEGIN
        DELETE SystemToolsValues
        WHERE BillId = @BillId;
    END;
GO