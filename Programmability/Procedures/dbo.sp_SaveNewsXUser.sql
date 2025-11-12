SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveNewsXUser]
(@NewsId   INT           ,
 @UserId      INT
)
AS
     BEGIN
         IF NOT EXISTS
         (
             SELECT 1
             FROM NewsXUsers
             WHERE NewsId = @NewsId and UserId= @UserId
         )
             BEGIN
                 INSERT INTO [dbo].NewsXUsers
                 (NewsId              ,
					UserId      
                 )
                 VALUES
                 (@NewsId              ,
 @UserId      
                 );
         END;
             
     END;
GO