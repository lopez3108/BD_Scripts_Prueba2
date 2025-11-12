SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllProviderElsTypes]
AS
     BEGIN
         SELECT *
         FROM ProviderElsTypes
         ORDER BY Description;
     END;


GO