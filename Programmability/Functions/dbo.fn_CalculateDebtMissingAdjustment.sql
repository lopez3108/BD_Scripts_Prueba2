SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CalculateDebtMissingAdjustment](@AgencyId     INT,
                                                         @CashierId    INT,
                                                         @Missing      DECIMAL(18, 2),
                                                         @CreationDate DATETIME,
                                                         @StartingDate DATETIME)
RETURNS DECIMAL(18, 2)
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN
         RETURN
         (
             SELECT -ISNULL( ABS(@Missing) + QUERY.USD, 0)
             FROM
             (  
             --    --UNION ALL

             SELECT  ISNULL(
                          (
                              SELECT ISNULL(SUM(ABS(DA.FinalMissing)), 0) USD
                 --DA.FinalMissing USD
                              FROM DailyAdjustments DA
                                   LEFT JOIN Daily D ON D.DailyId = DA.DailyId
                                   INNER JOIN Cashiers C ON C.CashierId = D.CashierId
                                   INNER JOIN Agencies A ON A.AgencyId = D.AgencyId
                              WHERE CAST(DA.CreationDate AS DATE) >= CAST(@StartingDate AS DATE)
                                    AND CAST(DA.CreationDate AS DATE) <= CAST(@CreationDate AS DATE)
                                    AND (D.AgencyId = @AgencyId
                                         OR @AgencyId IS NULL)
                                    AND (C.UserId = @CashierId
                                         OR @CashierId IS NULL)
                              GROUP BY DA.FinalMissing
                          ) -
                          (
                              SELECT DISTINCT
                                     ABS(P.Missing) USD
                              FROM Payrolls P
                                   LEFT JOIN
                              (
                                  SELECT TOP 1 au.AgencyId,
                                               au.UserId
                                  FROM AgenciesxUser au
                                  WHERE((AU.AgencyId = @AgencyId
                                         AND @CashierId IS NULL)
                                        OR ((@CashierId IS NOT NULL
                                             AND au.UserId = @CashierId))
                                        OR (@CashierId IS NULL
                                            AND @AgencyId IS NULL))
                                  GROUP BY au.UserId,
                                           au.AgencyId
                              ) auquery ON auquery.UserId = P.UserId
                                   INNER JOIN AgenciesxUser AU ON AU.UserId = P.UserId
                              WHERE CAST(P.FromDate AS DATE) >= CAST(@StartingDate AS DATE)
                                    AND CAST(P.ToDate AS DATE) <= CAST(@CreationDate AS DATE)
                                    AND ((AU.AgencyId = @AgencyId
                                          AND @CashierId IS NULL)
                                         OR ((@CashierId IS NOT NULL
                                              AND P.UserId = @CashierId))
                                         OR (@CashierId IS NULL
                                             AND @AgencyId IS NULL))
                          ), 0) AS USD
             ) AS QUERY
         );
     END;
GO