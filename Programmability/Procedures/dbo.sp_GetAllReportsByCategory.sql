SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllReportsByCategory] @Code CHAR(4) = NULL
AS
     SET NOCOUNT ON;
     BEGIN
         SELECT *
         FROM ReportCategories rc
              INNER JOIN Reports r ON rc.ReportCategoryId = r.ReportCategoryId
         WHERE rc.CategoryCode = @Code
               OR @Code IS NULL OR @Code = ''
			   ORDER BY ReportName
     END;
GO