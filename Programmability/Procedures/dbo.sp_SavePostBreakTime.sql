SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SavePostBreakTime]
(@BreakTimeId   INT            = NULL, 
 @DurationBreakTime INT 
)
AS
    BEGIN
        IF(@BreakTimeId  IS NULL)
            BEGIN
                INSERT INTO [dbo].[BreakTime]
                (DurationBreakTime
                )
                VALUES
                (@DurationBreakTime
                );
            END;
            ELSE
            BEGIN
                UPDATE [dbo].[BreakTime]
                  SET 
                      DurationBreakTime = @DurationBreakTime                    
                WHERE BreakTimeId  = @BreakTimeId ;
            END;
    END;
GO