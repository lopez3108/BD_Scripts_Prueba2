SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetUrlState] @UrlId int 
AS
    BEGIN
        SELECT DISTINCT 
             *
       FROM [dbo].urlsxstate a
	   Where a.UrlXStateId = @UrlId
    END;
GO