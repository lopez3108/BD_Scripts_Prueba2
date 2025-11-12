SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteTrainingWithQuestionsAndMultimedia] (@TrainingId INT)
AS
BEGIN

  DECLARE @Id AS INT;


  --QUESTION
  DELETE TrainingMultimedia
  WHERE TrainingQuestionsId IN (SELECT
        TrainingQuestionsId
      FROM TrainingQuestions
      WHERE TrainingId = @TrainingId);

  SET @Id = (SELECT TOP 1
      tq.TrainingQuestionsId
    FROM TrainingQuestions tq
    WHERE tq.TrainingId = @TrainingId);

  DELETE TrainingMultimedia
  WHERE TrainingId = @TrainingId
   

  DELETE TrainingQuestions
  WHERE TrainingId = @TrainingId;

  DELETE Training
  WHERE TrainingId = @TrainingId;

  SELECT
    @Id;

END;


GO