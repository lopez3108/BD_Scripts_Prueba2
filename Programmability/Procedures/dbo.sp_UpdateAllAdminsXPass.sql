SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateAllAdminsXPass] @UserXPassId INT  = NULL, 
                                                 @UserPassId  INT  = NULL, 
                                                 @UserId      INT = null, 
                                                 @FromDate    DATE = NULL, 
                                                 @ToDate      DATE = NULL, 
                                                 @Indefined   BIT  = NULL
AS
    BEGIN
        BEGIN
            UPDATE [dbo].AdminsXPass
              SET 
                  
                  FromDate = @FromDate, 
                  ToDate = @ToDate, 
                  Indefined = @Indefined
            WHERE UserPassId = @UserPassId;
        END;
    END;
GO