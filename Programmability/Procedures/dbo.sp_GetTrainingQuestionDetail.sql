SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetTrainingQuestionDetail] @TrainingId INT = NULL
AS
     BEGIN
         SELECT TrainingQuestionsId,
                TrainingId,
                Question,
                CAST(Answer AS BIT) AS Answer,
                CAST(IsMultiple AS BIT) IsMultiple,
                Option1,
                Option2,
                Option3,
                Option4,
                CAST(CASE
                         WHEN Option3 IS NOT NULL
                              AND Option3 <> ''
                         THEN 1
                         ELSE 0
                     END AS BIT) AS showOptionM3,
				    CAST(CASE
                         WHEN Option3 IS NOT NULL
                              AND Option4 <> ''
                         THEN 1
                         ELSE 0
                     END AS BIT) AS showOptionM4,
                MultipleAnswer
         FROM [dbo].TrainingQuestions
         WHERE TrainingId = @TrainingId;
     END;
GO