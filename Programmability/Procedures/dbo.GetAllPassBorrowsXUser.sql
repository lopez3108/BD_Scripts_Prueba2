SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetAllPassBorrowsXUser] @UserId INT, 
                                                @DateNow    DATE
AS
    BEGIN
        SELECT *
        FROM AdminsXPass a
             INNER JOIN UserPass p ON p.UserPassId = a.UserPassId
        WHERE a.UserId = @UserId
              --AND ((CAST(a.FromDate AS DATE) >= CAST(@DateNow AS DATE)
              --      OR @FromDate IS NULL)
              --     AND (CAST(gn.ToDate AS DATE) <= CAST(@DateNow AS DATE))
              --     OR @ToDate IS NULL);
    END;
GO