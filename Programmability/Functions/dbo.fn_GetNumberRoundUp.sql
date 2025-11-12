SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE   FUNCTION [dbo].[fn_GetNumberRoundUp](
 @Number as decimal(18,7))
RETURNS DECIMAL(18, 7)
AS
     BEGIN
         DECLARE @LastNumber as int;
		 DECLARE @NumberString as varchar(20);

		set @LastNumber=  RIGHT(@Number,1)
set @NumberString = CAST(@Number AS varchar(20));
IF(@LastNumber<5 )
BEGIN
SET @LastNumber = 9;
END
--select  REPLACE(@Number,RIGHT(@Number,1),@LastNumber)

RETURN CAST(LEFT(@NumberString, NULLIF(LEN(@NumberString)-1,-1)) + CAST(@LastNumber AS varchar(1)) AS decimal(18,7))
			
			
			
			

     END;
GO