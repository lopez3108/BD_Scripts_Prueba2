SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllCheckTypes] 
AS
     BEGIN
         SELECT *                             
         FROM [dbo].CheckTypes                      
         ORDER BY Description ASC
     END;



GO