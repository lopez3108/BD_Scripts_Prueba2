SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- ===================================================
-- Author:		Diego León Acevedo Arenas
-- Create date: 2021-12-09
-- Description:	Consulta los datos de OfficeSupplies.
-- ===================================================
-- exec [dbo].[sp_GetAllOfficeSupplies] @Name = 'SILLA'

CREATE PROCEDURE [dbo].[sp_GetAllOfficeProducts] 
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT * ,
        (
            SELECT [dbo].[fn_GetPrividerSupplyNames](a.OfficeSupplieId)
        ) ProvidersNames
        FROM OfficeSupplies a WITH(NOLOCK)
		WHERE CAST(  A.IsActive AS BIT) = 1
        ORDER BY NAME
       
    END;
GO