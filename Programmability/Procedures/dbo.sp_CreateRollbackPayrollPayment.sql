SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-05-21 5880: Manual payroll payment rollback
CREATE PROCEDURE [dbo].[sp_CreateRollbackPayrollPayment] 
@PayrollPaymentIds VARCHAR(max),
@ExpenseId INT
AS
BEGIN

DECLARE @SQL VARCHAR(8000);
DECLARE @SQLOthers VARCHAR(8000);

SET @SQLOthers = 'DELETE dbo.PayrollOthers WHERE PayrollId IN (' + @PayrollPaymentIds + ')';
EXECUTE (@SQLOthers);

SET @SQL = 'DELETE dbo.Payrolls WHERE PayrollId IN (' + @PayrollPaymentIds + ')';
EXECUTE (@SQL);

DELETE dbo.Expenses WHERE ExpenseId  = @ExpenseId

SELECT @ExpenseId


END;
GO