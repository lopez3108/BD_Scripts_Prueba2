SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetPayrollsPaidByUserId]
	@StartingDate datetime,
	@UserId int
AS 

BEGIN

DECLARE @hasPayrollPaid as BIT = 0;
	IF EXISTS(SELECT top 1 * FROM payrolls ps WHERE ps.VacationHours > 0 AND  ps.UserId = @UserId  AND ((cast(ps.PaidOn AS date) <= cast(@StartingDate  AS date)) OR(cast(ps.PaidOn AS date) >= cast(@StartingDate  AS date)) )
  
  )
  BEGIN  
  	SET @hasPayrollPaid = 1 
  END
  
SELECT @hasPayrollPaid AS hasPayrollPaid
END

GO