SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE   FUNCTION [dbo].[fn_CalculateAgencyPersonalInventoryMinimun](@AgencyId     INT)
RETURNS INT
AS
     BEGIN
         
		 DECLARE @resut INT


SET @resut = ISNULL((SELECT TOP 1 ISNULL(dbo.InventoryELSByAgency.InStock, 0) AS Quantity
FROM     dbo.InventoryELS LEFT OUTER JOIN
                  dbo.InventoryELSByAgency ON dbo.InventoryELS.InventoryELSId = dbo.InventoryELSByAgency.InventoryELSId AND dbo.InventoryELSByAgency.AgencyId = @AgencyId
				  WHERE dbo.InventoryELS.IsPersonalInventory = 1
				  ORDER BY Quantity ASC),0)



				  RETURN @resut


     END;
GO