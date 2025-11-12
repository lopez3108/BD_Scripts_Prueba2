SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteConfigurationPhonePlansById]
@PhonePlanId INT
AS
BEGIN
	 DELETE PhonePlans
     WHERE PhonePlanId = @PhonePlanId;
	 SELECT 1;
END
GO