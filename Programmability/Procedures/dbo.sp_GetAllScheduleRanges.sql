SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllScheduleRanges]
AS
    BEGIN
        SELECT *
        FROM dbo.ConfigurationScheduleRangesAgencies;
    END;
GO