SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveSerialsXReturn] @SerialsId    INT         = NULL, 
                                               @ReturnsELSId INT         = NULL, 
                                               @SerialNumber VARCHAR(15)
AS
    BEGIN
        IF(@SerialsId IS NULL)
            BEGIN
                INSERT INTO [dbo].SerialsXReturn
                (ReturnsELSId, 
                 SerialNumber
                )
                VALUES
                (@ReturnsELSId, 
                 @SerialNumber
                );
            END;
            ELSE
            BEGIN
                UPDATE [dbo].SerialsXReturn
                  SET 
                      ReturnsELSId = @ReturnsELSId, 
                      SerialNumber = @SerialNumber
                WHERE SerialsId = @SerialsId;
            END;
    END;
GO