SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_DeletePlateTypeOtherTruck](@PlateTypeOtherTruckId INT)
AS
     BEGIN
         DELETE PlateTypeOtherTruck
         WHERE PlateTypeOtherTruckId = @PlateTypeOtherTruckId;
	        SELECT 1;
     END;
GO