SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_GetScheduleXAgenciesXCashier]
AS
     BEGIN
         SELECT* FROM dbo.ScheduleXAgenciesXCashier
        
     END;
GO