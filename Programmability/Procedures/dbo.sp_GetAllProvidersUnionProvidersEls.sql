SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllProvidersUnionProvidersEls]
AS
     BEGIN
	SELECT LOWER(Name) value , Name display FROM (
         SELECT Name
		 FROM ProvidersEls
		  UNION 
		      SELECT Name
		 FROM Providers) AS QUERY ORDER BY Name
     END;
GO