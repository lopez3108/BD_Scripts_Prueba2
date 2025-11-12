SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GetProvidersXOrdersOfficeSupplies](@OrderOfficeSupplieId INT)
RETURNS VARCHAR(300)
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN
         RETURN
         (
             SELECT STUFF(
             (
                 SELECT ',' + POS.ProviderName
                 FROM OrdersOfficeSupplies OROF INNER JOIN
				 dbo.OrderOfficeSuppliesDetails OOS ON OROF.OrderOfficeSupplieId = OOS.OrderOfficeSupplieId INNER JOIN
				  dbo.ProvidersXOfficeSupplies PXOS  ON OOS.OfficeSupplieId = PXOS.OfficeSupplieId INNER JOIN
				   dbo.ProvidersOfficeSupplies POS ON PXOS.ProvidersOfficeSuppliesId = POS.ProvidersOfficeSuppliesId            
                                                                AND OROF.OrderOfficeSupplieId = @OrderOfficeSupplieId FOR XML PATH(''), TYPE
             ).value('text()[1]', 'nvarchar(max)'), 1, LEN(','), '') AS listStr
         );
     END;
GO