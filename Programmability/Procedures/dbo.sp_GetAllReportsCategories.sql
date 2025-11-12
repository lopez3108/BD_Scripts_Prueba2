SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllReportsCategories] @Code CHAR(4) = NULL
AS
     SET NOCOUNT ON;
     BEGIN
         SELECT *
         FROM ReportCategories 
     END;
GO