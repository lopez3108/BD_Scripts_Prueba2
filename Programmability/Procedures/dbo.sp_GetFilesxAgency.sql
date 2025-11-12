SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		cmontoya
-- Create date: 12Marzo2020
-- Description:	<Description,,>
-- =============================================
/*
	exec [dbo].[sp_GetFilesxAgency]
	@AgencyId = 1,
	@Window = 1,
	@Section = -1
*/

CREATE PROCEDURE [dbo].[sp_GetFilesxAgency] @AgencyId INT, 
                                           @Window   INT, 
                                           @Section  INT
AS
    BEGIN
        IF(@Section = -1)
            BEGIN
                SELECT f.FilesxAgenciesId, 
                       f.AgencyId, 
                       f.CreationDate, 
                       f.UserId AS CreatedBy, 
                       u.Name AS CreatedByName, 
                       f.Name, 
                       f.Extension, 
                       f.Base64, 
                       f.Window, 
                       f.Section,
					 CAST(1 AS BIT) AS IsSaved,
					  CAST(0 AS BIT) AS IsModify
                FROM dbo.FilesxAgencies f
                     INNER JOIN dbo.Users u ON f.UserId = U.UserId
                WHERE AgencyId = @AgencyId
                      AND Window = @Window
                ORDER BY CreationDate DESC;
            END;
            ELSE
            BEGIN
                SELECT f.FilesxAgenciesId, 
                       f.AgencyId, 
                       f.CreationDate, 
                       f.UserId AS CreatedBy, 
                       u.Name AS CreatedByName, 
                       f.Name, 
                       f.Extension, 
                       f.Base64, 
                       f.Window, 
                       f.Section,
					   CAST(1 AS BIT) AS IsSaved,
					   CAST(0 AS BIT) AS IsModify
                FROM dbo.FilesxAgencies f
                     INNER JOIN dbo.Users u ON f.UserId = U.UserId
                WHERE AgencyId = @AgencyId
                      AND Window = @Window
                      AND Section = @Section
                ORDER BY CreationDate DESC;
            END;
    END;
GO