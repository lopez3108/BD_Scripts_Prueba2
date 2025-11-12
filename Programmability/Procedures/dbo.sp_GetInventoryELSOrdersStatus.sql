SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetInventoryELSOrdersStatus]
AS
     BEGIN
       

SELECT [InventoryELSOrdersStatusId]
      ,[Code]
      ,[Description]
  FROM [dbo].[InventoryELSOrdersStatus]






     END;
GO