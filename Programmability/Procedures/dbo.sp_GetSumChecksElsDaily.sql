SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetSumChecksElsDaily] @UserId       INT      = NULL,
                                                @AgencyId     INT      = NULL,
                                                @CreationDate DATETIME = NULL
AS
     BEGIN
         SELECT CAST(ISNULL(SUM(query.Suma), 0) AS DECIMAL(18, 2)) Suma
         FROM
         (
             SELECT SUM(ROUND(CAST((b.Amount) AS DECIMAL(18, 2)) - CAST((b.Amount) AS DECIMAL(18, 2)) * (CAST(b.Fee AS DECIMAL(18, 2)) / 100), 2 )) AS Suma
             FROM ChecksEls b
                  LEFT JOIN ProviderTypes pt ON pt.ProviderTypeId = B.ProviderTypeId
                  LEFT JOIN Providers p ON p.ProviderTypeId = pt.ProviderTypeId
             WHERE b.AgencyId = @AgencyId
                   AND (CAST(b.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
                   AND b.CreatedBy = @UserId
                   AND P.Active = 1
                   AND pt.Code = 'C04'
             GROUP BY b.Amount,
                      b.Fee
             UNION ALL
             SELECT SUM(ROUND(CAST((b.Amount) AS DECIMAL(18, 2)) - CAST((b.Amount) AS DECIMAL(18, 2)) * (CAST(b.Fee AS DECIMAL(18, 2)) / 100),2)) AS Suma
             FROM ChecksEls b
                  LEFT JOIN ProviderTypes pt ON pt.ProviderTypeId = B.ProviderTypeId
                  LEFT JOIN Providers p ON p.ProviderTypeId = pt.ProviderTypeId
             WHERE b.AgencyId = @AgencyId
                   AND (CAST(b.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
                   AND (b.CreatedBy = @UserId
                        OR @UserId IS NULL)
                   AND P.Active = 1
                   AND pt.Code = 'C03'
             GROUP BY b.Amount,
                      b.Fee
         ) query;
     END;
GO