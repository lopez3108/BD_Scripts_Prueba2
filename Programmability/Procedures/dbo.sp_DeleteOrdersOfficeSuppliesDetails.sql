SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- ===================================================
-- Author:		John Terry García
-- Create date: 2021-12-10
-- Description:	Elimina un detalle de orden OfficeSupplies, y su orden principal en caso de quedar sin detalles.
-- ===================================================

-- exec [dbo].[sp_DeleteOfficeSupplies] @OfficeSupplieId = 1  
CREATE PROCEDURE [dbo].[sp_DeleteOrdersOfficeSuppliesDetails]
	@OrderOfficeSuppliesDetailsId INT = NULL	
AS
	BEGIN
		SET NOCOUNT ON;
		DECLARE @OrderOfficeSupplieIdSaved INT;
		SET @OrderOfficeSupplieIdSaved =(SELECT TOP 1 OrderOfficeSupplieId FROM OrderOfficeSuppliesDetails
		WHERE OrderOfficeSuppliesDetailsId = @OrderOfficeSuppliesDetailsId 	)
		DELETE FROM OrderOfficeSuppliesDetails WITH (ROWLOCK) 
		WHERE OrderOfficeSuppliesDetailsId = @OrderOfficeSuppliesDetailsId 	
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM OrderOfficeSuppliesDetails WHERE OrderOfficeSupplieId = @OrderOfficeSupplieIdSaved )
		BEGIN
		DELETE FROM OrdersOfficeSupplies WITH (ROWLOCK) 
		WHERE OrderOfficeSupplieId = @OrderOfficeSupplieIdSaved 
		END
	END
GO