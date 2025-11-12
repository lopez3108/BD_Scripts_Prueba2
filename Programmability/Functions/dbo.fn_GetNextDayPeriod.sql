SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GetNextDayPeriod]
(
@Year INT,
@Month INT
)
RETURNS DATE
AS
     BEGIN
         RETURN 	 DATEADD(day, 1 , DATEADD(month, ((YEAR(CONCAT(@Year,'-',@Month,'-',1)) - 1900) * 12) + MONTH(CONCAT(@Year,'-',@Month,'-',1)), -1)) 

     END;
GO