SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllComplianceRoles]
AS
     SET NOCOUNT ON;
     BEGIN
         SELECT *
         FROM [dbo].RolCompliance
         ORDER BY Code
     END;
GO