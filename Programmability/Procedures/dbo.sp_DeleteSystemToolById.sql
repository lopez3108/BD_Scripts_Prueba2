SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteSystemToolById]
@BillId INT = NULL
AS 
BEGIN
DELETE FROM dbo.SystemToolsBill
  WHERE (dbo.SystemToolsBill.BillId  = @BillId OR @BillId is NULL)
END
GO