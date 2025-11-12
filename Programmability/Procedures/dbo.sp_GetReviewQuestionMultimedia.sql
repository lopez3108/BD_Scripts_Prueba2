SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReviewQuestionMultimedia] @ReviewQuestionsId INT           = NULL,
                                                 @Url                 VARCHAR(1000) = NULL
AS
     BEGIN
         DECLARE @FullUrl VARCHAR(2000);
         SET @FullUrl = @Url+'/Compliance/Multimedia/QuestionReviewMedia/';
         SELECT *,
              
                IsImage,
                @FullUrl+CAST(ReviewQuestionsId AS VARCHAR(100))+'/'+DocumentNameMultimedia+'/'+DocumentNameMultimedia AS UrlDocument,
                CASE
                    WHEN IsImage = 1
                    THEN @FullUrl+CAST(ReviewQuestionsId AS VARCHAR(100))+'/'+DocumentNameMultimedia+'/'+DocumentNameMultimedia
                    ELSE @Url+'/files/media/icon_video.png'
                END AS UrlThumbnail
         FROM [dbo].ReviewMultimedia
         WHERE(ReviewQuestionsId = @ReviewQuestionsId
               OR @ReviewQuestionsId IS NULL);
     END;
GO