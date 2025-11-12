SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SavePlateTypeTrailer]
(@PlateTypeTrailerId	 INT            = NULL,
 @Description             VARCHAR(30)
)
AS
     BEGIN
         IF(@PlateTypeTrailerId IS NULL)
             BEGIN
                 INSERT INTO [dbo].PlateTypeTrailer
                 (Description
                 )
                 VALUES
                 (@Description
                 );
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].PlateTypeTrailer
                   SET
                       Description = @Description
                 WHERE PlateTypeTrailerId = @PlateTypeTrailerId;
         END;
     END;
GO