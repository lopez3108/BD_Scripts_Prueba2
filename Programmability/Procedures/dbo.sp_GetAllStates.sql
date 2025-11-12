SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Nombre:  sp_GetAllStates				    															         
-- Descripcion: Procedimiento Almacenado que consulta los estados de EEUU.				    					         
-- Creado por: 																				 
-- Fecha: 																									 	
-- Modificado por: Diego León Acevedo Arenas																										 
-- Fecha: 2023-07-24																											 
-- Observación:  Se agregan el campos StateAbre.    
-- Test: EXECUTE [dbo].[sp_GetAllStates]                         
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE PROCEDURE [dbo].[sp_GetAllStates]
AS 
BEGIN
	SELECT DISTINCT 
		   UPPER([State]) AS [State],
	       UPPER([StateAbre]) AS [StateAbre]
    FROM [dbo].[ZipCodes]
    WHERE [State] IS NOT NULL AND [StateAbre] IS NOT NULL
    ORDER BY [State]
  	
	END
GO