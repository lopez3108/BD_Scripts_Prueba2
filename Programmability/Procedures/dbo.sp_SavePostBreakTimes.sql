SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_SavePostBreakTimes]
(@TimeBreakHistoryId  INT            = NULL, 
 @UserId INT = NULL,
 @DateFrom DATETIME = NULL,
 @DateTo DATETIME = NULL,
 @AgencyId INT = NULL,
 @Rol varchar(20)
)
AS

DECLARE @RolId INT;
SET @RolId = (SELECT ut.UsertTypeId FROM UserTypes ut WHERE ut.Code = @Rol)

    BEGIN
        IF(@TimeBreakHistoryId  IS NULL)
            BEGIN
                INSERT INTO [dbo].[BreakTimeHistory]
                (UserId,
				 DateFrom,
				 DateTo,
         AgencyId,
         Rol 
                )
                VALUES
                (@UserId,
				 @DateFrom,
				 @DateTo,
         @AgencyId,
         @RolId
                );
            END;
            ELSE
            BEGIN
                UPDATE [dbo].[BreakTimeHistory]
                  SET 
                      UserId = @UserId,
					  DateFrom = @DateFrom,
					  DateTo = @DateTo          
                WHERE TimeBreakHistoryId  = @TimeBreakHistoryId ;
            END;
    END;
GO