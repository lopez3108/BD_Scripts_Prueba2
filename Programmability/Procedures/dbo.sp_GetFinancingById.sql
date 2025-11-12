SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetFinancingById] @FinancingId INT
AS
     BEGIN
         SELECT f.FinancingId,
                f.FinancingStatusId,
                f.Trp,
                f.Name,
                f.Telephone,
                f.USD,
                f.Note,
			 f.CreatedBy,
                f.ExpirationDate,
                f.CreatedOn,
                f.CompletedBy,
                f.CompletedOn,
                f.CanceledBy,
                f.CanceledOn,
                f.Dealer,
                f.DealerName,
			 f.DealerNumber,
			 f.DealerAddress,
                dbo.fn_CalculateDueFinancing(f.FinancingId, NULL) AS Due,
                fs.Code StatusCode,
                fs.Description AS FinancingStatusDescription,
                fs.Color AS FinancingStatusColor,
                u.Name UserCretedBy,
			  cc.CashierId UserCretedByCashierId,
                uc.Name UserCompletedBy,
                ucancel.Name UserCanceledBy,
                a.Name Agency,
			 a.AgencyId
         FROM Financing f
              INNER JOIN FinancingStatus fs ON f.FinancingStatusId = fs.FinancingStatusId
              INNER JOIN Users u ON u.UserId = f.CreatedBy
		    LEFT JOIN Cashiers cc ON cc.UserId = u.UserId
              INNER JOIN Agencies a ON a.AgencyId = f.AgencyId
              LEFT JOIN Users uc ON uc.UserId = f.CompletedBy
              LEFT JOIN Users ucancel ON ucancel.UserId = f.CanceledBy
         WHERE f.FinancingId = @FinancingId;
     END;
GO