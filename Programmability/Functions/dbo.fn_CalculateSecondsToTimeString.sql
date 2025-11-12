SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-04-19 DJ/5808: Used to calculate timesheet
CREATE FUNCTION [dbo].[fn_CalculateSecondsToTimeString](@Seconds   decimal(18,0))
RETURNS VARCHAR(20)
AS
     BEGIN

	 declare @minutes int, @hours int;

	set @hours = convert(int, @Seconds /60 / 60);
    set @minutes = convert(int, (@Seconds / 60) - (@hours * 60 ));
    set @seconds = @Seconds % 60;

         RETURN
         (
		 CASE WHEN @hours < 10 THEN '0' WHEN @hours = 0 THEN '00' ELSE '' END + 
             convert(varchar(9), convert(int, @hours)) + ':' +
        right('00' + convert(varchar(2), convert(int, @minutes)), 2) + ':' +
        right('00' + convert(varchar(2), @seconds), 2)
         )
     END;
GO