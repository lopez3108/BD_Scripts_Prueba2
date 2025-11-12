SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllPlateTypesTrailer]
AS
     BEGIN
         SELECT *
         FROM PlateTypeTrailer;
     END;
GO