SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_SetSetDefaultConfigurationSession]
(@ConfigurationSessionId  INT            = NULL, 
 @SessionTimeout INT 
)
AS
    BEGIN
        IF(@ConfigurationSessionId  IS NULL)
            BEGIN
                INSERT INTO [dbo].[ConfigurationSession]
                (SessionTimeout
                )
                VALUES
                (@SessionTimeout
                );
            END;
            ELSE
            BEGIN
                UPDATE [dbo].[ConfigurationSession]
                  SET 
                      SessionTimeout = @SessionTimeout                    
                WHERE ConfigurationSessionId = @ConfigurationSessionId  ;
            END;
    END;
GO