SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetConciliationOtherDescriptions] 

AS
     BEGIN

SELECT  
DISTINCT [Description]
FROM            dbo.ConciliationOthers
WHERE Description IS NOT NULL
ORDER BY Description ASC

END
GO