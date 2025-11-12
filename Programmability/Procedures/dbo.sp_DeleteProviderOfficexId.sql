SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteProviderOfficexId] @ProvidersXOfficeSuppliesId INT, 
                                          @ProvidersOfficeSuppliesId  INT,
										   @UrlXProviderXOfficeSupplyId  INT
AS
     --DECLARE @retVal INT;
     --SELECT @retVal = COUNT(*)
     --FROM dbo.ProvidersXOfficeSupplies
     --WHERE ProvidersOfficeSuppliesId = 4;
     --IF(@retVal > 1)
     --    BEGIN
     --        DELETE FROM dbo.ProvidersXOfficeSupplies
     --        WHERE @ProvidersXOfficeSuppliesId = @ProvidersXOfficeSuppliesId;
     --    END;
     --    ELSE
         BEGIN
             DELETE FROM dbo.ProvidersXOfficeSupplies
             WHERE ProvidersXOfficeSuppliesId = @ProvidersXOfficeSuppliesId;

			 DELETE FROM dbo.UrlsXProviderXSupply
             WHERE UrlXProviderXOfficeSupplyId = @UrlXProviderXOfficeSupplyId; 
             --DELETE FROM dbo.ProvidersOfficeSupplies
             --WHERE ProvidersOfficeSuppliesId = @ProvidersOfficeSuppliesId;
         END;
GO