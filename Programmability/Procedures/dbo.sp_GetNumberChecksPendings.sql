SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetNumberChecksPendings](@CashierId AS INT = NULL, @AgencyId AS INT = NULL)
AS
    BEGIN
        SELECT COUNT(*) checksPendings
        FROM dbo.Checks r
	    LEFT JOIN dbo.Clientes cc ON r.ClientId = cc.ClienteId
		LEFT JOIN DocumentStatus rs on rs.DocumentStatusId = r.CheckStatusId
	    LEFT JOIN DocumentStatus dsc ON dsc.DocumentStatusId = cc.ClientStatusId 
        WHERE (rs.Code = 'C02'  OR dsc.Code = 'C02')
              AND ( ( R.CashierId = @CashierId OR @CashierId IS NULL ) AND ( r.AgencyId = @AgencyId OR @AgencyId IS NULL ) );
    END;
GO