SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_SavePlateTypePersonalized]
(@PlateTypePersonalizedId INT            = NULL,
 @Description             VARCHAR(55)
)
AS
     BEGIN
         IF(@PlateTypePersonalizedId IS NULL)
             BEGIN
                 INSERT INTO [dbo].PlateTypesPersonalized
                 (Description
                  
                 )
                 VALUES
                 (@Description
                  
                 );
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].PlateTypesPersonalized
                   SET
                       Description = @Description
                       
                 WHERE PlateTypePersonalizedId = @PlateTypePersonalizedId;
         END;
     END;
GO