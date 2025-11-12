SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_GetAllPlateTypesPersonalized]
AS
     BEGIN
         SELECT *
         FROM PlateTypesPersonalized;
     END;


GO