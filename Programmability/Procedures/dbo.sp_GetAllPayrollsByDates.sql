SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-05-09 DJ/5813: Paynet column not calculating correctly

CREATE PROCEDURE [dbo].[sp_GetAllPayrollsByDates] (
@StartingDate DATETIME,
@EndingDate DATETIME,
@CashierId INT = NULL,
@AgencyId INT = NULL,
@SearchByRangePeriod BIT = NULL)
AS
BEGIN

SELECT * FROM [dbo].[FN_GetPayrollPaymentsData] (@StartingDate, @EndingDate, @CashierId, @AgencyId, @SearchByRangePeriod)
  



END;
GO