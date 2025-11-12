SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-02-23 CB/6365: Insurance quot

CREATE PROCEDURE [dbo].[sp_GetGender]

AS 

BEGIN

SELECT 
g.GenderId,
g.Description,
g.Code
FROM dbo.Gender g ORDER BY g.Code ASC




	END
GO