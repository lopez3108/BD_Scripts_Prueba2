SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GetPrividerSupplyNames](@OfficeSupplieId INT)
RETURNS VARCHAR(300)
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN
         RETURN
         (
             SELECT STUFF(
             (
                 SELECT ',' + con.ProviderName
                 FROM ProvidersXOfficeSupplies tc
				 INNER JOIN ProvidersOfficeSupplies con ON TC.ProvidersOfficeSuppliesId = con.ProvidersOfficeSuppliesId
                      INNER JOIN OfficeSupplies ten ON TC.OfficeSupplieId = ten.OfficeSupplieId
                                                                AND ten.OfficeSupplieId = @OfficeSupplieId FOR XML PATH(''), TYPE
             ).value('text()[1]', 'nvarchar(max)'), 1, LEN(','), '') AS listStr
         );
     END;
GO