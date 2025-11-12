SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-03-17 DJ/5475: Adding initial balance + report refactoring

CREATE   FUNCTION [dbo].[fn_CalculateCashierCommissions]( @StartDate  DATETIME,
                                                @EndingDate DATETIME,
                                                @UserId     INT = NULL,
												@AgencyId INT)
RETURNS DECIMAL(18, 2)

AS
     BEGIN

	 DECLARE @initialBalanceFinalDate DATETIME
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @StartDate)

  DECLARE @initialBalance DECIMAL(18,2)
  SET @initialBalance = (SELECT ISNULL(SUM(ISNULL(CAST([Balance] AS DECIMAL(18,2)),0)),0) FROM dbo.FN_GetReportEmployeeCommissions ('2018-01-01', @initialBalanceFinalDate, @AgencyId, @UserId, 1))
         
		SET @initialBalance = @initialBalance + (SELECT ISNULL(SUM(Balance),0) FROM dbo.FN_GetReportEmployeeCommissions (@StartDate, @EndingDate, @AgencyId, @UserId, 1))

		 RETURN @initialBalance
--		 (SELECT 
--		 ISNULL(ComissionNotary,0) +
--		 ISNULL(ComissionTelephones,0) +
--		 ISNULL(ComissionTitlesAndPlates,0) +
----		 ISNULL(ComissionTitlesAndPlatesManual,0) +
--		 ISNULL(ComissionTrp730,0) +
--		 ISNULL(ComissionFinancing,0) +
--		 ISNULL(ComissionCitySticker,0) +
--		 ISNULL(ComissionPlateSticker,0) +
--		 ISNULL(ComissionParkingTicket,0) +
--		 ISNULL(ComissionParkingTicketCard,0) +
--		 ISNULL(ComissionLendify,0) +
--		 ISNULL(ComissionTickets,0) FROM [FN_GetComissionsCashier] (@StartDate, @EndingDate, @UserId, @AgencyId))

     END;
GO