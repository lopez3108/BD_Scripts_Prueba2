SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
cREATE PROCEDURE [dbo].[sp_DeletePlateTypeTrailer](@PlateTypeTrailerId INT)
AS
     BEGIN
         DELETE PlateTypeTrailer
         WHERE PlateTypeTrailerId = @PlateTypeTrailerId;
	        SELECT 1;
     END;
GO