SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteNews](@NewsId INT)
AS
     BEGIN
	    DELETE NewsXUsers
         WHERE NewsId = @NewsId;

		 DELETE NewQuestionDetails
         WHERE NewsId = @NewsId;

         DELETE News
         WHERE NewsId = @NewsId;
         SELECT 1;
     END;
GO