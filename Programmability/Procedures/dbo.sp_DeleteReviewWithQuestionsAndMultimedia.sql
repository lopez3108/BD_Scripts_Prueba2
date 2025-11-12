SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Last updated by JT/03-06-2025 Task 6649 Permitir administrar reviews externos

CREATE PROCEDURE [dbo].[sp_DeleteReviewWithQuestionsAndMultimedia] (@ReviewId INT)
AS
BEGIN
  DECLARE @Id AS INT
         ,@IsExternal AS BIT;
         SET @Id  = 0;
SELECT @IsExternal = 
  CASE 
    WHEN IsExternalReview IN (0, 1) THEN IsExternalReview
    ELSE 0
  END
FROM Reviews
WHERE ReviewId = @ReviewId;

  IF (@IsExternal = 0)
  BEGIN
    DELETE ReviewMultimedia
    WHERE ReviewQuestionsId IN (SELECT
          ReviewQuestionsId
        FROM ReviewQuestions
        WHERE ReviewId = @ReviewId);

    SET @Id = (SELECT TOP 1
        ReviewQuestionsId
      FROM ReviewQuestions
      WHERE ReviewId = @ReviewId)

    DELETE ReviewMultimedia
    WHERE ReviewId = @ReviewId

    DELETE ReviewQuestions
    WHERE ReviewId = @ReviewId
  END
  DELETE Reviews
  WHERE ReviewId = @ReviewId
  SELECT
    @Id;
END;



GO