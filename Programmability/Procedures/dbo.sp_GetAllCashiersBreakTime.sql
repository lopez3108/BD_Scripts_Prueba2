SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-04-23 JF/5817: Inactive cashiers should continue to appear on the different payroll lists
-- =============================================
-- Author:      JF
-- Create date: 29/07/2024 3:51 p. m.
-- Database:    devCopySecure
-- Description: task 5961 Error filtros consulta break time 
-- =============================================

CREATE PROCEDURE [dbo].[sp_GetAllCashiersBreakTime]
AS
     BEGIN
         SELECT Users.Name,
                Cashiers.CashierId,
                Users.UserId 
              
         FROM Cashiers
              INNER JOIN Users ON Cashiers.UserId = Users.UserId
--              
         WHERE Cashiers.IsActive = 1 OR Users.UserId IN (SELECT bth.UserId FROM BreakTimeHistory bth)
         ORDER BY Users.Name;
     END;
GO