SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*CREADO POR ROMARIO JIMENEZ 26/12/2023 TASK:5521
*/
CREATE PROCEDURE [dbo].[sp_GetCompleteCashFormAdminV]
@ExtraFundId INT
AS
BEGIN
  SELECT
    ef.*
   ,a.Code +'-'+a.Name AS agency
   ,u.Name AS adminName
   ,u1r.Name as cashier
  FROM ExtraFund ef
 LEFT JOIN Agencies a
    ON ef.AgencyId = a.AgencyId
 left JOIN Cashiers c
    ON ef.CreatedBy = c.CashierId
 left JOIN Users u
    ON ef.AssignedTo = u.UserId
    LEFT JOIN Users u1r ON ef.CreatedBy = u1r.UserId
  WHERE ef.ExtraFundId = @ExtraFundId AND ef.completed = 1 AND ef.CashAdmin = 1
END


GO