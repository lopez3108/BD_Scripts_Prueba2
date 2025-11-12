SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteTrainingDetails] (@TrainingQuestionsId INT)
AS
BEGIN
  DELETE TrainingMultimedia
  WHERE TrainingQuestionsId = @TrainingQuestionsId;

  DELETE TrainingQuestions
  WHERE TrainingQuestionsId = @TrainingQuestionsId;


  SELECT
    1;
END;

GO