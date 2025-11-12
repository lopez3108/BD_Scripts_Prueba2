SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- ===================================================
-- Author:		Diego León Acevedo Arenas
-- Create date: 2021-12-10
-- Description:	Elimina los datos de OfficeSupplies.
-- ===================================================

-- exec [dbo].[sp_DeleteOfficeSupplies] @OfficeSupplieId = 1  

CREATE PROCEDURE [dbo].[sp_DeleteOfficeSupplies]
	@OfficeSupplieId INT = NULL	
AS
	BEGIN
		SET NOCOUNT ON;

		DELETE FROM ProvidersXOfficeSupplies WITH (ROWLOCK) 
		WHERE OfficeSupplieId = @OfficeSupplieId 	
		
		DELETE FROM OfficeSupplies WITH (ROWLOCK) 
		WHERE OfficeSupplieId = @OfficeSupplieId 

	END

GO