SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-05-14 JT/5889:  Change lenght of parameter @Fraction DECIMAL(18, 7), for calculate the specific hour, minute,second
-- 2024-05-14 DJ/5808: Used to transform decimal fraction (hours) to time format

CREATE FUNCTION [dbo].[fn_CalculateFractionToTimeString] (@Fraction DECIMAL(18, 7))

--Previus version commented by jt in task 5889

RETURNS VARCHAR(20)
AS
BEGIN

  DECLARE @seconds DECIMAL(18, 0) = (@Fraction * 3600)

  IF (@seconds > 0)
  BEGIN
    DECLARE @minutes INT
           ,@hours INT;

    SET @hours = CONVERT(INT, @seconds / 60 / 60);
    SET @minutes = CONVERT(INT, (@seconds / 60) - (@hours * 60));
    SET @seconds = @seconds % 60;

    RETURN
    (
    CASE
      WHEN @hours < 10 THEN '0'
      WHEN @hours = 0 THEN '00'
      ELSE ''
    END +
    CONVERT(VARCHAR(9), CONVERT(INT, @hours)) + ':' +
    RIGHT('00' + CONVERT(VARCHAR(2), CONVERT(INT, @minutes)), 2) + ':' +
    RIGHT('00' + CONVERT(VARCHAR(2), @seconds), 2)
    )

  END

  RETURN '00:00:00'

END;
GO