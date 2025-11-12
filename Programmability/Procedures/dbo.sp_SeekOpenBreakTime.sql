SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SeekOpenBreakTime] (@DateNow DATETIME, @UserId INT)
AS
BEGIN
DECLARE @result BIT = 0;
IF EXISTS (SELECT TOP 1 * FROM BreakTimeHistory bth  WHERE bth.DateTo IS NULL AND bth.UserId = @UserId AND  CAST(bth.DateFrom AS DATE) = CAST(@DateNow AS DATE) )
BEGIN  
	set @result =1;
END
ELSE
BEGIN
SET  @result = 0;
END

SELECT @result;

END

GO