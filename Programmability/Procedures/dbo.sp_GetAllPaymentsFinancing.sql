SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllPaymentsFinancing] @FinancingId INT      = NULL,
                                                   @Date        DATETIME = NULL
AS
     BEGIN
         SELECT p.PaymentId,
                p.USD,
                p.FinancingId,
                p.CreatedBy,
                P.CreatedOn,
                u.Name UserCretedBy,
                dbo.fn_CalculateDueFinancing(p.FinancingId, p.CreatedOn) AS Due,
                p.CardPayment,
                p.CardPaymentFee
         FROM Payments p
              INNER JOIN Financing f ON p.FinancingId = f.FinancingId
              INNER JOIN FinancingStatus fs ON f.FinancingStatusId = fs.FinancingStatusId
              INNER JOIN Users u ON u.UserId = p.CreatedBy
         WHERE(CAST(p.CreatedOn AS DATETIME) = CAST(@Date AS DATETIME)
               OR @Date IS NULL)
              AND P.FinancingId = @FinancingId
         ORDER BY p.CreatedOn;
     END;
GO