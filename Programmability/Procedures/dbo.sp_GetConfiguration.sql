SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetConfiguration]
AS 

BEGIN
SELECT [ConfigurationId]
      ,[MinimumFee]
      ,[MaximumFee]
	  ,(SELECT TOP 1 DaysToCashCheck FROM ConfigurationELS) as DaysToCashCheck
	  ,(SELECT TOP 1 PostdatedChecks FROM ConfigurationELS) as PostdatedChecks
	  ,(SELECT TOP 1 CheckRangeRegistering FROM ConfigurationELS) as CheckRangeRegistering
	  ,[MakerConfigurationUrl]
  FROM [dbo].[Configuration] 
	END
GO