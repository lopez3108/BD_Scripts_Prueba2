SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[sp_CreateReviewMultimedia] @ReviewMultimediaId   INT          = NULL,
                                                    @ReviewId             INT          = NULL,
                                                    @ReviewQuestionsId    INT          = NULL,
                                                    @IsImage                BIT,
                                                    @DocumentNameMultimedia VARCHAR(500)
AS
     BEGIN
         IF(@ReviewMultimediaId IS NULL)
             BEGIN
                 INSERT INTO [dbo].ReviewMultimedia
                 (ReviewId,
                  ReviewQuestionsId,
                  DocumentNameMultimedia,
                  IsImage
                 )
                 VALUES
                 (@ReviewId,
                  @ReviewQuestionsId,
                  @DocumentNameMultimedia,
                  @IsImage
                 );
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].ReviewMultimedia
                   SET
                       ReviewId = @ReviewId,
                       ReviewQuestionsId = @ReviewQuestionsId,
                       DocumentNameMultimedia = @DocumentNameMultimedia,
                       IsImage = @IsImage
                 WHERE ReviewMultimediaId = @ReviewMultimediaId;
         END;
     END;
GO