SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCashiersKyc] @AgencyId   INT         = NULL
AS
    BEGIN

	select DISTINCT k.UserId, u.Name from Kyc k INNER JOIN
	Users u ON u.UserId = k.UserId
	WHERE (@AgencyId IS NULL OR k.AgencyId = @AgencyId)
	ORDER BY u.Name





       
    END;

GO