SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-04-23 JF/5817: Inactive cashiers should continue to appear on the different payroll lists

CREATE PROCEDURE [dbo].[sp_GetAllCashiersActivesAndInactives]
AS
     BEGIN
         SELECT Users.Name,
                Cashiers.CashierId
              
         FROM Cashiers
              INNER JOIN Users ON Cashiers.UserId = Users.UserId
--              
         WHERE Cashiers.IsActive = 1 OR Users.UserId IN (SELECT ts.UserId FROM TimeSheet ts)
         ORDER BY Users.Name;
     END;
GO