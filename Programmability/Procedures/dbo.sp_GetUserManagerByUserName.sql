SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetUserManagerByUserName] @User VARCHAR(1000)
AS
     BEGIN
         SELECT u.* ,c.IsManager
         FROM [dbo].[Users] u 
              left JOIN Cashiers c ON c.UserId = u.UserId AND C.IsManager = 1
         WHERE UPPER(u.[User]) = UPPER(@User) 
               ;
     END;
GO