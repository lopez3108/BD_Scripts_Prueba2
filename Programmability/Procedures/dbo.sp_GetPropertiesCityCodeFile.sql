SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-08-14 CB/6005: Added Properties city code files section

CREATE PROCEDURE [dbo].[sp_GetPropertiesCityCodeFile]

AS
    BEGIN

SELECT 
p.PropertiesCityCodeFilesId,
p.FileName, 
p.LastUpdatedBy, 
p.LastUpdatedOn,
u.Name as LastUpdatedByName
FROM dbo.PropertiesCityCodeFiles p
LEFT JOIN dbo.Users u ON u.UserId = p.LastUpdatedBy


      

    END;
GO