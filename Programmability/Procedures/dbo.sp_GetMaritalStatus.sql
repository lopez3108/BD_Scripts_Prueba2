SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-02-23 CB/6365: Insurance quot

CREATE PROCEDURE [dbo].[sp_GetMaritalStatus]

AS 

BEGIN

SELECT 
g.MaritalStatusId,
g.Description,
g.Code
FROM dbo.MaritalStatus g ORDER BY g.Code ASC




	END
GO