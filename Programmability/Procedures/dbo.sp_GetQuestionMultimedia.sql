SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetQuestionMultimedia] @TrainingQuestionsId INT           = NULL,
                                                 @Url                 VARCHAR(1000) = NULL
AS
     BEGIN
         DECLARE @FullUrl VARCHAR(2000);
         SET @FullUrl = @Url+'/Compliance/Multimedia/QuestionMedia/';
         SELECT *,
                --CASE
                --    WHEN IsImage = 1
                --    THEN 'true'
                --    ELSE 'false'
                --END AS IsImage,
                IsImage,
                @FullUrl+CAST(TrainingQuestionsId AS VARCHAR(100))+'/'+DocumentNameMultimedia+'/'+DocumentNameMultimedia AS UrlDocument,
                CASE
                    WHEN IsImage = 1
                    THEN @FullUrl+CAST(TrainingQuestionsId AS VARCHAR(100))+'/'+DocumentNameMultimedia+'/'+DocumentNameMultimedia
                    ELSE @Url+'/files/media/icon_video.png'
                END AS UrlThumbnail
         FROM [dbo].TrainingMultimedia
         WHERE(TrainingQuestionsId = @TrainingQuestionsId
               OR @TrainingQuestionsId IS NULL);
     END;
GO