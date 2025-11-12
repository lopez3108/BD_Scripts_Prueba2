SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPlateTypeById](@PlateTypeId INT)
AS
     BEGIN
         SELECT *
         FROM PlateTypes
         WHERE PlateTypeId = @PlateTypeId;
     END;

GO