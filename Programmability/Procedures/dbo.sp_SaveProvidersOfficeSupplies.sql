SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveProvidersOfficeSupplies]
(@ProvidersOfficeSuppliesId INT          = NULL, 
 @ProviderName              VARCHAR(80), 

 @IdCreated                 INT OUTPUT
)
AS
    BEGIN
        IF(@ProvidersOfficeSuppliesId IS NULL)
            BEGIN
                INSERT INTO [dbo].[ProvidersOfficeSupplies]
                ([ProviderName]
                
                )
                VALUES
                (@ProviderName 
          
                );
                SET @IdCreated = @@IDENTITY;
            END;
            ELSE
            BEGIN
                UPDATE [dbo].[ProvidersOfficeSupplies]
                  SET 
                      [ProviderName] = @ProviderName
                
                WHERE ProvidersOfficeSuppliesId = @ProvidersOfficeSuppliesId;
                SET @IdCreated = @ProvidersOfficeSuppliesId;
            END;
    END;
GO