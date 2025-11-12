SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPropertiesBillOtherDescription]

AS 

BEGIN

SELECT        
DISTINCT dbo.PropertiesBillOthers.Description
FROM            dbo.PropertiesBillOthers 
ORDER BY dbo.PropertiesBillOthers.Description
	
	
	END
GO