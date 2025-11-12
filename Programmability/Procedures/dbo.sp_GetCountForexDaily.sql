SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCountForexDaily] @AgencyId INT,
                                           @UserId   INT,
										   @Date	DATETIME
AS
     BEGIN
         
		 SELECT COUNT(*)
		 FROM Providers p
      INNER JOIN MoneyTransferxAgencyNumbers mt ON p.ProviderId = mt.ProviderId
                                                           AND mt.AgencyId = @AgencyId
		 WHERE p.Active = CAST(1 AS BIT)
		 AND p.ForexType IS NOT NULL
		 AND p.ForexType = 1



     END;
GO