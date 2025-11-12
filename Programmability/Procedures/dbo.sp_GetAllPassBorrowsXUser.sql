SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- date 03-06-2025 task 6553 Ajustes módulo USERS JF

CREATE PROCEDURE [dbo].[sp_GetAllPassBorrowsXUser] @UserId  INT, 
                                                  @DateNow DATE
AS
    BEGIN
        SELECT a.*, 
               p.*, 
               u.Name OwnerPassword
        FROM UserPass p
             INNER JOIN AdminsXPass a ON p.UserPassId = a.UserPassId
             LEFT JOIN users u ON p.UserId = u.UserId
        WHERE a.UserId = @UserId
              AND (A.Indefined = 1
                   OR CAST(@DateNow AS DATE) >= CAST(a.FromDate AS DATE)
                   AND CAST(@DateNow AS DATE) <= CAST(a.ToDate AS DATE))
                    ORDER BY p.Company ASC;
    END;
GO