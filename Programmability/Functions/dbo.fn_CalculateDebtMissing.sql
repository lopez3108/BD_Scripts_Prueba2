SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CalculateDebtMissing](@AgencyId     INT,
                                               @CashierId    INT,
                                               @Missing      DECIMAL(18, 2),
                                               @CreationDate DATETIME,
                                               @StartingDate DATETIME)
RETURNS DECIMAL(18, 2)
AS
     BEGIN
         RETURN
         (
             SELECT ISNULL((@Missing) - SUM(QUERY.USD), 0)
             FROM
             (
                 SELECT DISTINCT
                        ISNULL(SUM(ABS(d.Missing)), 0) USD
                 FROM Daily D
                      INNER JOIN Cashiers C ON C.CashierID = D.CashierId
                 WHERE CAST(D.CreationDate AS DATE) >= CAST(@StartingDate AS DATE)
                       AND CAST(D.CreationDate AS DATE) <= CAST(@CreationDate AS DATE)
                       AND (D.AgencyId = @AgencyId
                            OR @AgencyId IS NULL)
                       AND (C.UserId = @CashierId
                            OR @CashierId IS NULL)
             ) AS QUERY
         );
     END;
GO