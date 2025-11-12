SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCheckTypes]
AS
    BEGIN
        SELECT CheckTypeId,
		UPPER(CheckTypes.[Description]) as [Description],
		DefaultFee,
		Active,
		ctc.Code,
		MaxCheckAmount,
               CASE
                   WHEN Active = 1
                   THEN 'ACTIVE'
                   ELSE 'INACTIVE'
               END StatusDescription,
               CheckTypes.CategoryCheckTypeId
  FROM CheckTypes
        INNER JOIN CheckTypesCategories ctc ON CheckTypes.CategoryCheckTypeId = ctc.CategoryCheckTypeId
        ORDER BY Description;
    END;


GO