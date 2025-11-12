SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteTrainingMultimedia](@TrainingMultimediaId INT)
AS
     BEGIN
	    

         DELETE TrainingMultimedia
         WHERE TrainingMultimediaId = @TrainingMultimediaId;
         SELECT 1;
     END;
GO