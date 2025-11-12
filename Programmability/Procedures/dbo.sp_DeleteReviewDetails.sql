SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteReviewDetails] (@ReviewQuestionsId INT)
AS
BEGIN
  DELETE ReviewMultimedia
  WHERE ReviewQuestionsId = @ReviewQuestionsId;

  DELETE ReviewQuestions
  WHERE ReviewQuestionsId = @ReviewQuestionsId;
  SELECT
    1;
END;

GO