SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SavePlateTypeOtherTruck]
(@PlateTypeOtherTruckId	 INT            = NULL,
 @Description             VARCHAR(30)
)
AS
     BEGIN
         IF(@PlateTypeOtherTruckId IS NULL)
             BEGIN
                 INSERT INTO [dbo].PlateTypeOtherTruck
                 (Description
                 )
                 VALUES
                 (@Description
                 );
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].PlateTypeOtherTruck
                   SET
                       Description = @Description
                 WHERE PlateTypeOtherTruckId = @PlateTypeOtherTruckId;
         END;
     END;
GO