SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCityStickersById](@CityStickersId INT)
AS
     BEGIN
         SELECT c.CityStickerId,
                c.Usd,
                c.Fee1,
                c.CreationDate
         FROM  CityStickers c
         WHERE CityStickerId = @CityStickersId;
     END;
GO