SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetNewQuestionDetailsByNews] @NewsId INT = NULL
AS
     BEGIN
         SELECT *,
                CASE
                    WHEN Yes = 1
                    THEN 'true'
                    ELSE 'false'
                END AS Answer
         FROM [dbo].[NewQuestionDetails]
         WHERE NewsId = @NewsId;
     END;
GO