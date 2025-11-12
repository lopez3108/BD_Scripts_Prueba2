SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetReviewQuestionDetail] @ReviewId INT = NULL,
                                                   @UserId   INT = NULL
AS
     BEGIN
         SELECT [dbo].ReviewQuestions.ReviewQuestionsId,
                [dbo].ReviewQuestions.ReviewId,
                UPPER(Question) AS Question ,
                CAST([dbo].ReviewQuestions.Answer AS BIT) AS Answer,
                CAST(IsMultiple AS BIT) IsMultiple,
                CAST(IsExplanation AS BIT) IsExplanation,
                --CAST(IsExplanation AS BIT) IsExplanation,
                Option1,
                Option2,
                Option3,
                Option4,
                ra.Explain,
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
                [dbo].ReviewQuestions.MultipleAnswer,
                ra.Answer AnswerSimple,
                ra.MultipleAnswer AnswerMultipleAnswer
         FROM [dbo].ReviewQuestions
              LEFT JOIN ReviewAnswer ra ON ra.ReviewQuestionsId = ReviewQuestions.ReviewQuestionsId
                                           AND ra.UserId = @UserId
         WHERE ReviewId = @ReviewId;
     END;

GO