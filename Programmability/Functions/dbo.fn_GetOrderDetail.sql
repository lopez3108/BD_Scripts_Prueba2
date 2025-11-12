SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GetOrderDetail](@OrderOfficeSupplieId INT)
RETURNS VARCHAR(300)
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN
         RETURN
         (
             SELECT STUFF(
             (
                 SELECT ',' + A.Name
                 FROM OrdersOfficeSupplies OROF
				 INNER JOIN OrderOfficeSuppliesDetails AXO ON OROF.OrderOfficeSupplieId = AXO.OrderOfficeSupplieId
                      INNER JOIN dbo.OfficeSupplies A ON AXO.OfficeSupplieId = A.OfficeSupplieId
                                                                AND OROF.OrderOfficeSupplieId = @OrderOfficeSupplieId FOR XML PATH(''), TYPE
             ).value('text()[1]', 'nvarchar(max)'), 1, LEN(','), '') AS listStr
         );
     END;
GO