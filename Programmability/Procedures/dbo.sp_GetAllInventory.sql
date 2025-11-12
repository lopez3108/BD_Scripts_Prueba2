SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllInventory](@Model VARCHAR (30) = NULL)
AS
     BEGIN
         SELECT *
         FROM Inventory i 
	    WHERE  Model LIKE '%'+@Model+'%'  OR @Model IS NULL
     END;
GO