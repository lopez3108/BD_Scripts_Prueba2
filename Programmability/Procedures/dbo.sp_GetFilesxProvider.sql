SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		cmontoya
-- Create date: 16Marzo2020
-- Description:	<Description,,>
-- =============================================
/*
	exec [dbo].[sp_GetFilesxProvider]
	@ProviderId = 1
*/

CREATE PROCEDURE [dbo].[sp_GetFilesxProvider] @ProviderId INT
AS
    BEGIN
        SELECT f.FilesxProviderId, 
               f.ProviderId, 
               f.CreationDate, 
               f.UserId AS CreatedBy, 
               u.Name AS CreatedByName, 
               f.Name, 
               f.Extension, 
               f.Base64, 
               CAST(1 AS BIT) AS IsSaved, 
               CAST(0 AS BIT) AS IsModify
        FROM dbo.FilesxProvider f
             INNER JOIN dbo.Users u ON f.UserId = U.UserId
        WHERE ProviderId = @ProviderId
        ORDER BY CreationDate DESC;
    END;
GO