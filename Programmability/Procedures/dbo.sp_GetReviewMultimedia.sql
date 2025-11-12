SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReviewMultimedia] @ReviewId          INT           = NULL,
                                                 @ReviewQuestionsId INT           = NULL,
                                                 @Url                 VARCHAR(1000) = NULL
AS
     BEGIN
         DECLARE @FullUrl VARCHAR(2000);
         SET @FullUrl = @Url+'/Compliance/Multimedia/RewiewMedia/';
         SELECT *,
                IsImage,
                @FullUrl+CAST(ReviewId AS VARCHAR(100))+'/'+DocumentNameMultimedia+'/'+DocumentNameMultimedia AS UrlDocument,
                CASE
                    WHEN IsImage = 1
                    THEN @FullUrl+CAST(ReviewId AS VARCHAR(100))+'/'+DocumentNameMultimedia+'/'+DocumentNameMultimedia
                    ELSE @Url+'/files/media/icon_video.png'
                END AS UrlThumbnail
         FROM [dbo].ReviewMultimedia
         WHERE(ReviewId = @ReviewId
               OR @ReviewId IS NULL)
              AND (ReviewQuestionsId = @ReviewQuestionsId
                   OR @ReviewQuestionsId IS NULL);
     END;
GO