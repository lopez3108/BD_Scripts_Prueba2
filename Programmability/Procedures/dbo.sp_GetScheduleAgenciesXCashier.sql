SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetScheduleAgenciesXCashier] 

@IdScheduleXAgenciesXCashier INT = NULL,
@Time DATETIME = NULL,
@DayId INT = NULL, 
@AgencyId INT = NULL,
@UserId INT = NULL

AS
    BEGIN 
	
	SELECT  
	         sac.IdScheduleXAgenciesXCashier,
             d.Description, 
             a.Name ,
			 u.Name        

        FROM ScheduleXAgenciesXCashier sac
             INNER JOIN Days d ON sac.DayId = d.DayId
             INNER JOIN Agencies a ON sac.AgencyId = a.AgencyId
			 INNER JOIN Users u ON sac.UserId = u.UserId

        WHERE(sac.IdScheduleXAgenciesXCashier = @IdScheduleXAgenciesXCashier
              OR @IdScheduleXAgenciesXCashier IS NULL)
             AND ('ScheduleXAgenciesXCashier.Time' = @Time
                  OR @Time IS NULL)
			 AND (sac.DayId = @DayId
                  OR @Time IS NULL)
			 AND (sac.AgencyId = @AgencyId
                  OR @AgencyId IS NULL)
		   AND (sac.UserId = @UserId
                  OR @UserId IS NULL)
        ORDER By IdScheduleXAgenciesXCashier;
    END;
GO