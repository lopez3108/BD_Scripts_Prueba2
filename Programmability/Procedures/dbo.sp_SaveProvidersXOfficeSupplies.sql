SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		Juan Felipe Oquendo López
-- Description:	Relaciona el Provider con el Office 
-- =============================================
CREATE PROCEDURE [dbo].[sp_SaveProvidersXOfficeSupplies] @ProvidersOfficeSuppliesId  INT, 
                                                        @OfficeSupplieId            INT, 
                                                        @ProvidersXOfficeSuppliesId INT = NULL
                                               
AS
    BEGIN
        IF(@ProvidersXOfficeSuppliesId IS NULL)
            BEGIN
                INSERT INTO [dbo].ProvidersXOfficeSupplies
                ([OfficeSupplieId], 
                 ProvidersOfficeSuppliesId
                )
                VALUES
                ( @OfficeSupplieId,
				@ProvidersOfficeSuppliesId
                
                );
              
            END;
            ELSE
            BEGIN
                UPDATE [dbo].ProvidersXOfficeSupplies
                  SET 
                      ProvidersOfficeSuppliesId = @ProvidersOfficeSuppliesId, 
                      OfficeSupplieId = @OfficeSupplieId
                WHERE ProvidersXOfficeSuppliesId = @ProvidersXOfficeSuppliesId;
               
            END;
    END;
GO