SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllPlateTypes]
AS
     BEGIN
         SELECT *
         FROM PlateTypes
         ORDER BY [Order];
     END;


GO