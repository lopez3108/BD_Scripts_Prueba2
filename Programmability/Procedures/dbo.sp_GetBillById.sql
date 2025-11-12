SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetBillById] @BillId INT = NULL
AS
BEGIN
  SELECT
    *
  FROM dbo.SystemToolsValues stv
  WHERE (stv.BillId = @BillId OR @BillId is null)
END
GO