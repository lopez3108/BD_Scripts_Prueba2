SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[FN_SubstractZeros]
(
                 @sumRegularHoursFormatTime varchar(20)
)
RETURNS varchar(20)
AS
BEGIN

  IF (LEN(@sumRegularHoursFormatTime) > 8 )
  BEGIN
    RETURN SUBSTRING(@sumRegularHoursFormatTime, PATINDEX('%[^0]%', @sumRegularHoursFormatTime), LEN(@sumRegularHoursFormatTime))

  END
--  ELSE
--  BEGIN

    RETURN @sumRegularHoursFormatTime
--  END;

END;



GO