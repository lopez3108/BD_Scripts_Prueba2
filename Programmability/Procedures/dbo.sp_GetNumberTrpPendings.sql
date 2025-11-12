SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetNumberTrpPendings]
(@UserId AS   INT, 
 @AgencyId AS INT
)
AS
    BEGIN
        SELECT COUNT(*) Pendings
      FROM dbo.Trp
        WHERE(AgencyId = @AgencyId)
		AND(CreatedBy = @UserId)
             AND ((
			 --(dbo.TRP.FileIdNamePermit = ''
    --                OR dbo.TRP.FileIdNamePermit IS NULL)
                    (dbo.TRP.PermitNumber = ''
                       OR dbo.TRP.PermitNumber IS NULL)
                   OR (dbo.TRP.ClientName = ''
                       OR dbo.TRP.ClientName IS NULL)
                   OR (dbo.TRP.PermitTypeId <= 0
                       OR dbo.TRP.PermitTypeId IS NULL)));
    END;
GO