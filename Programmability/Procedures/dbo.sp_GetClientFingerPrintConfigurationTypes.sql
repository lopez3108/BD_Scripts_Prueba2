SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetClientFingerPrintConfigurationTypes]
AS
    BEGIN

	SELECT 
	ClientFingerPrintConfigurationTypeId,
	Code,
	Description
	FROM ClientFingerPrintConfigurationType

       
    END;
GO