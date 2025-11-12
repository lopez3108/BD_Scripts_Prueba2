SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DelteAgency]
 (
	  @AgencyId int

    )
AS 

BEGIN

DELETE Agencies WHERE AgencyId = @AgencyId
SELECT 1

	END

GO