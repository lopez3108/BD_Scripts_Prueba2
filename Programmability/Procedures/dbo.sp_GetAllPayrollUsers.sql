SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllPayrollUsers] @StartDate DATETIME,
@PaymentPeriod VARCHAR(10),
@EndingDate DATETIME
AS
BEGIN
  SELECT
    *
  FROM dbo.[FN_GetInfoPayrollUsers](@StartDate, @PaymentPeriod, @EndingDate) q -- obtiene informacion  base del payroll
  WHERE q.TotalToPay <> 0;
END;

GO