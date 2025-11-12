SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetNumberReviewWithoutRead](@UserId AS INT)
AS
     BEGIN
      
         SELECT COUNT(*) ReviewCount
         FROM dbo.Reviews r
         WHERE r.Status = 2
           
		      AND NOT EXISTS
         (
             SELECT ReviewXUserId
             FROM ReviewXUsers ru
             WHERE ru.UserId = @UserId
                   AND rU.ReviewId = R.ReviewId
         )
               
     END;
GO