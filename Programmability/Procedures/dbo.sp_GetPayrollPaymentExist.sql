SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Last update by jt/25-07-2024 looks to see if the cashier already has a payroll payment made
CREATE PROCEDURE [dbo].[sp_GetPayrollPaymentExist] (@UserId INT)
AS
BEGIN

SELECT TOP 1
        pr.PayrollId
      FROM Payrolls pr
      INNER JOIN Users u
        ON pr.UserId = u.UserId
      INNER JOIN Cashiers c
        ON u.UserId = c.UserId
      WHERE 
       u.UserId = @UserId
END;
GO