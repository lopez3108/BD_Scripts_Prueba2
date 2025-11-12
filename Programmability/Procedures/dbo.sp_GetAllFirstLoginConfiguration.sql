SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllFirstLoginConfiguration]
AS
     SET NOCOUNT ON;
     BEGIN
         SELECT *
         FROM [dbo].FirstLoginSecurity
        
     END;
GO