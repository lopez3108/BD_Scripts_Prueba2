SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_GetAllValidationMethods]
AS
     SET NOCOUNT ON;
     BEGIN
         SELECT *
         FROM [dbo].ValidationMethods
         ORDER BY Code;
     END;
GO