SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CalculatePropertyControlValidThrough](
@PropertyControlId INT,
@CurrentDate DATETIME)
RETURNS DATETIME
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN


	 declare @numMonths INT
	 set @numMonths = (SELECT TOP 1 MonthNumberValid FROM PropertyControls
	 WHERE PropertyControlId = @PropertyControlId)


	 return DATEADD(month, @numMonths, @CurrentDate)


 
     END;
GO