SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCategoriesCheckTypes]


AS
    BEGIN
        SELECT *
               
        FROM CheckTypesCategories
	
        ORDER BY Code;
    END;


GO