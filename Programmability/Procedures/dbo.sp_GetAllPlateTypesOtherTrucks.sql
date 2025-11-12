SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllPlateTypesOtherTrucks]
AS
     BEGIN
         SELECT *
         FROM PlateTypeOtherTruck;
     END;
GO