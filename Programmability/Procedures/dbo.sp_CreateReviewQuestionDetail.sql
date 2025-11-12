SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateReviewQuestionDetail] 
@ReviewQuestionsId INT = NULL,
@ReviewId INT,
@Question Varchar(3000),
@Answer bit = null,
@IsMultiple bit = null,
@Option1 varchar(300) =null,
@Option2 varchar(300) =null,
@Option3 varchar(300) =null,
@Option4 varchar(300) =null,
@MultipleAnswer varchar(5) =null,
@IsExplanation bit = null,
@IdCreated      INT OUTPUT

AS
    
     BEGIN
        IF(@ReviewQuestionsId IS NULL)
             BEGIN
                 INSERT INTO [dbo].ReviewQuestions
                 (ReviewId,
                  Question,
				  Answer,
				  IsMultiple,
				  Option1,
				  Option2,
				  Option3,
				  Option4,
				  MultipleAnswer,
				  IsExplanation
				 
                 
                 )
                 VALUES
                 (@ReviewId,
				 @Question,
				 @Answer,
				 @IsMultiple,
				 @Option1,
				 @Option2,
				 @Option3,
				 @Option4,
				 @MultipleAnswer,
				 @IsExplanation
				 
		  
                 );
				  SET @IdCreated = @@IDENTITY;
				 
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].ReviewQuestions
                   SET
                  ReviewId = @ReviewId,
                  Question= @Question,
				  Answer = @Answer,
				  IsMultiple=  @IsMultiple,
				  Option1=@Option1,
				  Option2= @Option2,
				  Option3= @Option3,
				  Option4=@Option4,
				  MultipleAnswer= @MultipleAnswer,
				  IsExplanation= @IsExplanation
				 
                  
                 WHERE ReviewQuestionsId = @ReviewQuestionsId;
				  SET @IdCreated = @ReviewQuestionsId;
				   
         END;
     END;
GO