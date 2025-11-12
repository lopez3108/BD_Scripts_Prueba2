SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteScheduleRanges](@ScheduleConfigurationId INT)
AS
     BEGIN
	    

         DELETE ConfigurationScheduleRangesAgencies
         WHERE ScheduleConfigurationId = @ScheduleConfigurationId;
         
     END;
GO