SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePlateTypePersonalized](@PlateTypePersonalizedId INT)
AS
     BEGIN
         DELETE PlateTypesPersonalized
         WHERE PlateTypePersonalizedId = @PlateTypePersonalizedId;
	        SELECT 1;
     END;


GO