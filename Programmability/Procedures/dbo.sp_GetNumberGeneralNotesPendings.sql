SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetNumberGeneralNotesPendings]
(@UserId AS   INT, 
 @AgencyId AS INT
)
AS
    BEGIN
        SELECT COUNT(*) Pendings
        FROM dbo.GeneralNotes G
             INNER JOIN GeneralNotesStatus S ON S.GeneralNotesStatusId = G.GeneralNotesStatusId
        WHERE(S.Code = 'C01')
             AND (G.AgencyId = @AgencyId);
    END;
GO