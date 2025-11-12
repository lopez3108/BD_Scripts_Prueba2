SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetConfigurationEls]
AS
BEGIN
  SELECT TOP 1
    *
   ,cf.ClientFingerPrintConfigurationTypeId
   ,cf.Code
  FROM [dbo].[ConfigurationELS]
  LEFT JOIN [dbo].ClientFingerPrintConfigurationType cf
    ON cf.ClientFingerPrintConfigurationTypeId = [dbo].[ConfigurationELS].ClientFingerPrintConfigurationTypeId;
END;
GO