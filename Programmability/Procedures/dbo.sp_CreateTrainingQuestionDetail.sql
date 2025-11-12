SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      JF
-- Create date: 20/09/2024 7:12 p. m.
-- Database:    developing
-- Description: task 6076 Ajuste tamaño preguntas trainings 
-- =============================================



CREATE PROCEDURE [dbo].[sp_CreateTrainingQuestionDetail] 
@TrainingQuestionsId INT = NULL,
@TrainingId INT,
@Question nVarchar(3000),
@Answer bit = null,
@IsMultiple bit = null,
@Option1 varchar(300) =null,
@Option2 varchar(300) =null,
@Option3 varchar(300) =null,
@Option4 varchar(300) =null,
@MultipleAnswer varchar(5) =null,
@IdCreated      INT OUTPUT

AS
    
     BEGIN
        IF(@TrainingQuestionsId IS NULL)
             BEGIN
                 INSERT INTO [dbo].TrainingQuestions
                 (TrainingId,
                  Question,
				  Answer,
				  IsMultiple,
				  Option1,
				  Option2,
				  Option3,
				  Option4,
				  MultipleAnswer
				 
                 
                 )
                 VALUES
                 (@TrainingId,
				 @Question,
				 @Answer,
				 @IsMultiple,
				 @Option1,
				 @Option2,
				 @Option3,
				 @Option4,
				 @MultipleAnswer
				 
		  
                 );
				  SET @IdCreated = @@IDENTITY;
				 
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].TrainingQuestions
                   SET
                  TrainingId = @TrainingId,
                  Question= @Question,
				  Answer = @Answer,
				  IsMultiple=  @IsMultiple,
				  Option1=@Option1,
				  Option2= @Option2,
				  Option3= @Option3,
				  Option4=@Option4,
				  MultipleAnswer= @MultipleAnswer
				 
                  
                 WHERE TrainingQuestionsId = @TrainingQuestionsId;
				  SET @IdCreated = @TrainingQuestionsId;
				   
         END;
     END;
GO