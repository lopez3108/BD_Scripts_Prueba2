SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateTrainingMultimedia] @TrainingMultimediaId   INT          = NULL,
                                                    @TrainingId             INT          = NULL,
                                                    @TrainingQuestionsId    INT          = NULL,
                                                    @IsImage                BIT,
                                                    @DocumentNameMultimedia VARCHAR(500)
AS
     BEGIN
         IF(@TrainingMultimediaId IS NULL)
             BEGIN
                 INSERT INTO [dbo].TrainingMultimedia
                 (TrainingId,
                  TrainingQuestionsId,
                  DocumentNameMultimedia,
                  IsImage
                 )
                 VALUES
                 (@TrainingId,
                  @TrainingQuestionsId,
                  @DocumentNameMultimedia,
                  @IsImage
                 );
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].TrainingMultimedia
                   SET
                       TrainingId = @TrainingId,
                       TrainingQuestionsId = @TrainingQuestionsId,
                       DocumentNameMultimedia = @DocumentNameMultimedia,
                       IsImage = @IsImage
                 WHERE TrainingMultimediaId = @TrainingMultimediaId;
         END;
     END;
GO