SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateNewQuestionDetail] 
@NewQuestionId INT = NULL,
@NewsId INT,
@Question Varchar(400),
@Yes bit

AS
    
     BEGIN
        IF(@NewQuestionId IS NULL)
             BEGIN
                 INSERT INTO [dbo].NewQuestionDetails
                 (NewsId,
                  Question,
				  Yes		  
				 
                 
                 )
                 VALUES
                 (@NewsId,
				 @Question,
		   @Yes
		  
                 );
				 
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].NewQuestionDetails
                   SET
                 NewsId = @NewsId,
                  Question= @Question,
				  Yes = @Yes		  
				 
                  
                 WHERE NewQuestionId = @NewQuestionId;
				   
         END;
     END;
GO