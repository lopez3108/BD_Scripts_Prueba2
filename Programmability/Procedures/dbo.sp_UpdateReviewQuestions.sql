SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateReviewQuestions]
 @MultipleAnswer  VARCHAR(5) = NULL,
 @Answer BIT = NULL,
 @Explain VARCHAR(450) = NULL,
 @ReviewQuestionsId INT,
 @ReviewAnswerId INT = NULL,
 @UserId INT ,
 @IdCreated      INT  OUTPUT 

AS
    BEGIN
	
        IF(@ReviewAnswerId IS NULL)
             BEGIN
                 INSERT INTO [dbo].ReviewAnswer
                 (ReviewQuestionsId,
				  MultipleAnswer,	
				  Answer,
				  Explain,
				  UserId
                 )
                 VALUES
                 (@ReviewQuestionsId,
				  @MultipleAnswer,	
				  @Answer,
				  @Explain,
				  @UserId
                 );
				  SET @IdCreated = @@IDENTITY;
				 
         END;
             ELSE
             BEGIN
                  UPDATE [dbo].ReviewAnswer
                   SET
				  ReviewQuestionsId	= @ReviewQuestionsId,
				  MultipleAnswer = @MultipleAnswer,	
				  Answer = @Answer,
				  Explain= @Explain	

				  
                 WHERE ReviewQuestionsId = @ReviewQuestionsId;

	SET  @IdCreated  = -1

END;
END;
GO