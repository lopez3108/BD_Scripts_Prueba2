SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllRentPaymentsAndDepositsByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN
         SELECT ISNULL(SUM(QUERY.USD), 0) AS USD,
                CAST(QUERY.Date AS DATE) AS Date,
                'RENT PAYMENTS' AS Name
         FROM
         (
             SELECT SUM(ISNULL(RP.FeeDue, 0)) USD,
                    CAST(RP.CreationDate AS DATE) AS Date
             FROM RentPayments RP
                  INNER JOIN Agencies a ON RP.AgencyId = a.AgencyId
                  INNER JOIN Users u ON RP.CreatedBy = u.UserId
             WHERE CAST(RP.CreationDate AS DATE) >= CAST(@From AS DATE)
                   AND CAST(RP.CreationDate AS DATE) <= CAST(@To AS DATE)
                   AND RP.AgencyId = @AgencyId
                   AND RP.CreatedBy = @CreatedBy
             GROUP BY CAST(RP.CreationDate AS DATE)
             UNION ALL
             SELECT SUM(ISNULL(RP.Usd, 0)) USD,
                    CAST(RP.CreationDate AS DATE) AS Date
             FROM RentPayments RP
                  INNER JOIN Agencies a ON RP.AgencyId = a.AgencyId
                  INNER JOIN Users u ON RP.CreatedBy = u.UserId
             WHERE CAST(RP.CreationDate AS DATE) >= CAST(@From AS DATE)
                   AND CAST(RP.CreationDate AS DATE) <= CAST(@To AS DATE)
                   AND RP.AgencyId = @AgencyId
                   AND RP.CreatedBy = @CreatedBy
             GROUP BY CAST(RP.CreationDate AS DATE)
             UNION ALL
             SELECT SUM(ISNULL(DP.Usd, 0)) USD,
                    CAST(DP.CreationDate AS DATE) AS Date
             FROM DepositFinancingPayments DP
                  INNER JOIN Agencies a ON DP.AgencyId = a.AgencyId
                  INNER JOIN Users u ON DP.CreatedBy = u.UserId
             WHERE CAST(DP.CreationDate AS DATE) >= CAST(@From AS DATE)
                   AND CAST(DP.CreationDate AS DATE) <= CAST(@To AS DATE)
                   AND DP.AgencyId = @AgencyId
                   AND DP.CreatedBy = @CreatedBy
             GROUP BY CAST(DP.CreationDate AS DATE)
             UNION ALL
             SELECT SUM(ISNULL(c.RefundUsd, 0) * (-1)) USD,
                    CAST(c.RefundDate AS DATE) AS Date
             FROM Contract c
                  INNER JOIN Agencies a ON c.AgencyId = a.AgencyId
                  INNER JOIN Users u ON c.CreatedBy = u.UserId
             WHERE CAST(C.RefundDate AS DATE) >= CAST(@From AS DATE)
                   AND CAST(C.RefundDate AS DATE) <= CAST(@To AS DATE)
                   AND c.AgencyRefundId = @AgencyId
                   AND c.RefundBy = @CreatedBy
             GROUP BY CAST(c.RefundDate AS DATE)
         ) QUERY
         GROUP BY CAST(QUERY.DATE AS DATE);

         --SELECT SUM(dbo.OtherPayments.Usd) AS USD,
         --       CAST(dbo..CreationDate AS DATE) AS Date,
         --       'RENT PAYMENTS' AS Name
         --FROM dbo.OtherPayments
         --WHERE CAST(dbo.OtherPayments.CreationDate AS DATE) >= CAST(@From AS DATE)
         --      AND CAST(dbo.OtherPayments.CreationDate AS DATE) <= CAST(@To AS DATE)
         --      AND CreatedBy = @CreatedBy
         --      AND AgencyId = @AgencyId
         --GROUP BY CAST(dbo.OtherPayments.CreationDate AS DATE);

         --SELECT ISNULL((SUM(QUERY.RentPayments) + SUM(QUERY.DepositPayments) + SUM(QUERY.DepositRefunds)), 0) AS USD,
         --       CAST(GETDATE() AS DATE) AS Date,
         --       'RENT PAYMENTS' AS Name
         --FROM
         --(
         --    SELECT ISNULL(
         --                 (
         --                     SELECT SUM(ISNULL(RP.Usd, 0))
         --                     FROM RentPayments RP
         --                          INNER JOIN Agencies a ON RP.AgencyId = a.AgencyId
         --                          INNER JOIN Users u ON RP.CreatedBy = u.UserId
         --                     WHERE CAST(RP.CreationDate AS DATE) >= CAST(@From AS DATE)
         --                           AND CAST(RP.CreationDate AS DATE) <= CAST(@To AS DATE)
         --                           AND RP.AgencyId = @AgencyId
         --                           AND RP.CreatedBy = @CreatedBy
         --                     GROUP BY CAST(RP.CreationDate AS DATE)
         --                 ), 0) RentPayments,
         --           ISNULL(
         --                 (
         --                     SELECT SUM(ISNULL(DP.Usd, 0))
         --                     FROM DepositFinancingPayments DP
         --                          INNER JOIN Agencies a ON DP.AgencyId = a.AgencyId
         --                          INNER JOIN Users u ON DP.CreatedBy = u.UserId
         --                     WHERE CAST(DP.CreationDate AS DATE) >= CAST(@From AS DATE)
         --                           AND CAST(DP.CreationDate AS DATE) <= CAST(@To AS DATE)
         --                           AND DP.AgencyId = @AgencyId
         --                           AND DP.CreatedBy = @CreatedBy
         --                     GROUP BY CAST(DP.CreationDate AS DATE)
         --                 ), 0) DepositPayments,
         --           ISNULL(
         --                 (
         --                     SELECT SUM(ISNULL(c.RefundUsd, 0))
         --                     FROM Contract c
         --                          INNER JOIN Agencies a ON c.AgencyId = a.AgencyId
         --                          INNER JOIN Users u ON c.CreatedBy = u.UserId
         --                     WHERE CAST(C.RefundDate AS DATE) >= CAST(@From AS DATE)
         --                           AND CAST(C.RefundDate AS DATE) <= CAST(@To AS DATE)
         --                           AND c.AgencyRefundId = @AgencyId
         --                           AND c.RefundBy = @CreatedBy
         --                     GROUP BY CAST(c.RefundDate AS DATE)
         --                 ), 0) DepositRefunds
         --) QUERY;
     END;
GO