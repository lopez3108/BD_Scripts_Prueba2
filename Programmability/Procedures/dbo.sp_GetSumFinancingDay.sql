SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSumFinancingDay] @UserId       INT      = NULL,
                                              @AgencyId     INT      = NULL,
                                              @CreationDate DATETIME = NULL
AS
     SET NOCOUNT OFF;
     BEGIN
         SELECT ISNULL(SUM(p.USD), 0) AS moneyvalue,
                'true' AS Disabled,
                'true' 'Set'
         FROM Financing f
              INNER JOIN FinancingStatus fs ON f.FinancingStatusId = fs.FinancingStatusId
              INNER JOIN Payments p ON f.FinancingId = p.FinancingId
         WHERE CAST(P.CreatedOn AS DATE) = CAST(@CreationDate AS DATE)
               AND F.AgencyId = @AgencyId
               AND (p.CreatedBy = @UserId OR @UserId IS NULL);
			--AND fs.Code <> 'C03';
     END;
GO