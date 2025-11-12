SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPlateStickerById]
													(@PlateStickerId     INT  )
AS
     BEGIN
         SELECT p.PlateStickerId,
                p.Usd,
				p.Fee1,
				p.CreationDate
			                      
         FROM PlateStickers p 
         WHERE P.PlateStickerId = @PlateStickerId
     END;

GO