SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetNumberReturnedChecksPendings](@AgencyId INT = NULL)
AS
    BEGIN
        SELECT COUNT(*) ReturnedchecksPendings
        FROM dbo.ReturnedCheck r
             INNER JOIN ReturnStatus rs ON rs.ReturnStatusId = r.StatusId
        WHERE rs.Code = 'C01'
              AND (R.ReturnedAgencyId = @AgencyId
                   OR @AgencyId IS NULL);
    END;

GO