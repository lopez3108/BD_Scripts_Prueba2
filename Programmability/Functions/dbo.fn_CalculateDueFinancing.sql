SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CalculateDueFinancing](@FinancingId   INT,
                                            @FinancingDate DATETIME = NULL)
RETURNS DECIMAL(18, 2)
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN
         RETURN
         (
             SELECT F.USD - ISNULL((SUM(P.USD)), 0) Due
             FROM Financing F
                  LEFT JOIN Payments P ON F.FinancingId = P.FinancingId
             WHERE F.FinancingId = @FinancingId
                   AND (CAST(p.CreatedOn AS DATETIME) <= CAST(@FinancingDate AS DATETIME)
                        OR @FinancingDate IS NULL)
             GROUP BY F.FinancingId,
                      F.USD
         );
     END;
GO