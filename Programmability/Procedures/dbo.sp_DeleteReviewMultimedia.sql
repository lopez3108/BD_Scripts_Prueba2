SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteReviewMultimedia](@ReviewMultimediaId INT)
AS
     BEGIN
	    

         DELETE ReviewMultimedia
         WHERE ReviewMultimediaId = @ReviewMultimediaId;
         SELECT 1;
     END;
GO