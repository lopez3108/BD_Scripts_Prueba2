SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      JF
-- Create date: 28/07/2024 3:25 p. m.
-- Database:    devCopySecure
-- Description: task 5960 Varios ajustes payroll
-- =============================================

CREATE PROCEDURE [dbo].[sp_GetDateClosedOnDaily] ( @AgencyId INT = NULL, @UserId INT = NULL, @LoginDate DATETIME = NULL ) 
AS
BEGIN
 DECLARE @cashierId INT;
  SET @cashierId = (SELECT TOP 1
      CashierId
    FROM Cashiers
    WHERE UserId = @UserId);

SELECT d.DailyId,d.CreationDate,d.ClosedOn,u.Name,a.Code + ' - ' + a.Name AS AgencyCodeName FROM Daily d
INNER JOIN Cashiers c ON c.CashierId = d.CashierId
INNER JOIN Users u ON u.UserId = c.UserId
INNER JOIN Agencies a ON a.AgencyId = d.AgencyId

WHERE cast (d.CreationDate AS DATE) = CAST(@LoginDate AS DATE) AND d.CashierId = @cashierId AND d.AgencyId = @AgencyId
  
END;

GO