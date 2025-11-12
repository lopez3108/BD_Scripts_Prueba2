SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_DeleteVentra](@VentraId INT)
AS
     BEGIN
         DELETE FROM [dbo].Ventra
         WHERE VentraId = @VentraId;
     END;
GO