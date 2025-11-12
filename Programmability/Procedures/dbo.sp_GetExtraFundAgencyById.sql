SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetExtraFundAgencyById](@ExtraFundId INT)
AS
     BEGIN
         SELECT  e.ExtraFundId,
                      e.CreationDate,
                      e.Usd,
                      e.CreatedBy,
                      e.LastUpdated,
                      e.LastUpdatedBy,
					  c.CashierId CashierIdAssignedTo,
					  c.CashierId CashierIdAssignedToSaved,
					  cc.CashierId CashierIdCreated,
					  e.IsCashier,
					  e.CashAdmin,
                      e.AssignedTo,
                      e.AssignedTo AssignedToOld,
                      e.AgencyId,
                      CAST(0 AS BIT) AcceptNegative,
                      'true' 'Disabled',
                      e.Usd 'moneyvalue',
                      CAST(1 AS BIT) 'Set',
                      e.Usd,
                      u.Name UserCretedBy,
                      ul.Name UserLastUpdatedBy,
                      ua.Name UserAssignedTo,
                      a.Name Agency
         FROM ExtraFund e
              INNER JOIN Agencies a ON a.AgencyId = e.AgencyId
              INNER JOIN Users u ON u.UserId = e.CreatedBy
              INNER JOIN Users ua ON ua.UserId = e.AssignedTo
			  INNER JOIN Cashiers c ON c.UserId = e.AssignedTo
			  LEFT JOIN Cashiers cc ON cc.UserId = e.CreatedBy
              LEFT JOIN Users uL ON uL.UserId = e.LastUpdatedBy
         WHERE e.ExtraFundId = @ExtraFundId;
     END;
GO