SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetLastPayrollUsers] 
AS
     BEGIN
		SELECT TOP 1 PayrollId,FromDate, ToDate, PaidOn  from Payrolls ORDER BY ToDate DESC

     END;
GO