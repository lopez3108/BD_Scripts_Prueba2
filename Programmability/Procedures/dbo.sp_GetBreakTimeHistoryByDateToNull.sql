SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetBreakTimeHistoryByDateToNull]
( @UserId     INT,
 @DateFrom DATE = NULL
 )
AS
     BEGIN
			 SELECT *
			 FROM BreakTimeHistory
		 WHERE  UserId =  @UserId AND cast(DateFrom AS DATE) = cast (@DateFrom AS DATE) 
		  AND(DateTo IS NULL )
                
     END;
GO