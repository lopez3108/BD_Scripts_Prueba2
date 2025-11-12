SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllProviderTypes]
AS
     BEGIN
         SELECT *                
         FROM ProviderTypes
         ORDER BY Description;
     END;


GO