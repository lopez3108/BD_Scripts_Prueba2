SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllSecurityLevel]
AS
     SET NOCOUNT ON;
     BEGIN
         SELECT *
         FROM [dbo].SecurityLevel
         ORDER BY Code;
     END;
GO