SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		Juan Felipe Oquendo López
-- Description:	Relaciona el Provider con el Office 
-- =============================================
CREATE PROCEDURE [dbo].[sp_SaveUrlXProviderXOfficeSupply] @UrlXProviderXOfficeSupplyId INT = null, 
                                                        @OfficeSupplieId             INT = null, 
                                                        @ProvidersOfficeSuppliesId  INT          = NULL, 
                                                        @Url                         VARCHAR(400) = null
AS
    BEGIN
        IF(@UrlXProviderXOfficeSupplyId IS NULL)
            BEGIN
                INSERT INTO [dbo].UrlsXProviderXSupply
                ([OfficeSupplieId], 
                 ProvidersOfficeSuppliesId, 
                 Url
                )
                VALUES
                (@OfficeSupplieId, 
                 @ProvidersOfficeSuppliesId, 
                 @Url
                );
            END;
            ELSE
            BEGIN
                UPDATE [dbo].UrlsXProviderXSupply
                  SET 
                      ProvidersOfficeSuppliesId = @ProvidersOfficeSuppliesId, 
                      Url = @Url, 
                      OfficeSupplieId = @OfficeSupplieId
                WHERE UrlXProviderXOfficeSupplyId = @UrlXProviderXOfficeSupplyId;
            END;
    END;
GO