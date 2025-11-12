SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteNewsDetails](@NewQuestionId INT)
AS
     BEGIN
	    

         DELETE NewQuestionDetails
         WHERE NewQuestionId = @NewQuestionId;
         SELECT 1;
     END;
GO