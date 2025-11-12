SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetStatesAbre] 
AS
    BEGIN
        SELECT DISTINCT 
               a.UrlXStateId, 
			   a.StateAbre,
             UPPER(a.state + ' - ' + a.StateAbre) AS StateNameAbre,
             upper(a.state) AS State
       FROM [dbo].urlsxstate a
    END;
        
GO