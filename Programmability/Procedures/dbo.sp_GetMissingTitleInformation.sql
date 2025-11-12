SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetMissingTitleInformation]
(@CreationDate DATE = NULL, 
 @AgencyId     INT, 
 @UserId       INT  = NULL
)
AS
    BEGIN
        SELECT T.TitleId
        FROM Titles T
             LEFT JOIN ProcessStatus ps ON T.ProcessStatusId = ps.ProcessStatusId
        WHERE CAST(T.CreationDate AS DATE) <= CAST(@CreationDate AS DATE)
              AND T.AgencyId = @AgencyId
              AND (T.CreatedBy = @UserId
                   OR @UserId IS NULL)
              AND (ps.Code = 'C00');
    END;
GO