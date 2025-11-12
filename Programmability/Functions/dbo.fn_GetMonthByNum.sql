SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GetMonthByNum]
(@Month INT
)
RETURNS VARCHAR(20)
AS
     BEGIN
         RETURN CASE
                    WHEN @Month = 1
                    THEN 'JANUARY'
                    WHEN @Month = 2
                    THEN 'FEBRUARY'
                    WHEN @Month = 3
                    THEN 'MARCH'
                    WHEN @Month = 4
                    THEN 'APRIL'
                    WHEN @Month = 5
                    THEN 'MAY'
                    WHEN @Month = 6
                    THEN 'JUNE'
                    WHEN @Month = 7
                    THEN 'JULY'
                    WHEN @Month = 8
                    THEN 'AUGUST'
                    WHEN @Month = 9
                    THEN 'SEPTEMBER'
                    WHEN @Month = 10
                    THEN 'OCTOBER'
                    WHEN @Month = 11
                    THEN 'NOVEMBER'
                    WHEN @Month = 12
                    THEN 'DECEMBER'
                END;
     END;
GO