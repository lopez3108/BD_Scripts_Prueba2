SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCheckTypesByStatus]
@IsActive BIT

AS
    BEGIN
        SELECT CheckTypes.*,
               CASE
                   WHEN Active = 1
                   THEN 'ACTIVE'
                   ELSE 'INACTIVE'
               END StatusDescription,
               ctc.Code
        FROM CheckTypes
                INNER JOIN CheckTypesCategories ctc ON CheckTypes.CategoryCheckTypeId = ctc.CategoryCheckTypeId

		WHERE Active=@IsActive
        ORDER BY CheckTypes.Description;
    END;


GO