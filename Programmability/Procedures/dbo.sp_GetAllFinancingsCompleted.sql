SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllFinancingsCompleted] @AgencyId INT      = NULL,
                                                     @Date     DATETIME = NULL
AS
     BEGIN
         SELECT f.FinancingId,
                f.FinancingStatusId,
                f.Trp,
                f.Name,
                f.Name+'-'+f.Trp ClientTrp,
                f.Telephone,
                f.USD,
                f.Note,
                f.ExpirationDate,
                f.CreatedBy,
                f.CreatedOn,
                f.CompletedBy,
                f.CompletedOn,
                f.CanceledBy,
                f.CanceledOn,
                f.Dealer,
                f.DealerName,
                fs.Code StatusCode,
                fs.Description AS FinancingStatusDescription,
                a.Name Agency,
                t.TitleId
         FROM Financing f
              INNER JOIN FinancingStatus fs ON f.FinancingStatusId = fs.FinancingStatusId
              INNER JOIN Users u ON u.UserId = f.CreatedBy
              INNER JOIN Agencies a ON a.AgencyId = f.AgencyId
              LEFT JOIN Titles t ON t.FinancingId = f.FinancingId
              LEFT JOIN Users uc ON uc.UserId = f.CompletedBy
              LEFT JOIN Users ucancel ON ucancel.UserId = f.CanceledBy
         WHERE(f.AgencyId = @AgencyId
               OR @AgencyId IS NULL)
              AND (fs.Code = 'C02')
              AND (CAST(f.CreatedOn AS DATE) = CAST(@Date AS DATE)
                   OR @Date IS NULL)        
              AND t.FinancingId IS NULL;
     END;
GO