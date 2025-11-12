SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetSumReturnedChecksDay] @UserId       INT      = NULL, 
                                                   @AgencyId     INT      = NULL, 
                                                   @CreationDate DATETIME = NULL
AS
    BEGIN
        SELECT ISNULL(SUM(Usd), 0) AS moneyvalue, 
		 (
            SELECT ISNULL(SUM(CardPaymentFee), 0) + ISNULL(SUM(Usd), 0)
            FROM ReturnPayments r
                 INNER JOIN ReturnPaymentMode rm ON r.ReturnPaymentModeId = rm.ReturnPaymentModeId
            WHERE CAST(CreationDate AS DATE) = CAST(@CreationDate AS DATE)
                  AND (rm.Code = 'C02')  --'C02' CASH 
                  AND (CreatedBy = @UserId
                       OR @UserId IS NULL)
                  AND AgencyId = @AgencyId
        ) AS usdPay,
        (
            SELECT ISNULL(SUM(CardPaymentFee), 0) + ISNULL(SUM(Usd), 0)
            FROM ReturnPayments r
                 INNER JOIN ReturnPaymentMode rm ON r.ReturnPaymentModeId = rm.ReturnPaymentModeId
            WHERE CAST(CreationDate AS DATE) = CAST(@CreationDate AS DATE)
                  AND (rm.Code = 'C03')--C03' CARD PAYMENT
                  AND (CreatedBy = @UserId
                       OR @UserId IS NULL)
                  AND AgencyId = @AgencyId
        ) AS fee
        FROM ReturnPayments rp
             INNER JOIN ReturnPaymentMode rm ON rp.ReturnPaymentModeId = rm.ReturnPaymentModeId
        WHERE CAST(CreationDate AS DATE) = CAST(@CreationDate AS DATE)
        --rm.Code = 'C02' CASH 
        --rm.Code = 'C03' CARD PAYMENT
              AND (rm.Code = 'C02' OR rm.Code = 'C03' --Change in task 5357   En la seccion de Returned checks cuando se hacen pagos con tarjeta no se ve reflejado en los Details. Al igual que el punto 1 revisar que dichos pagos con tarjeta se vean reflejados en los Details y Total del Daily.
                  )
              AND (CreatedBy = @UserId
                   OR @UserId IS NULL)
              AND AgencyId = @AgencyId;
    END;
        --SELECT *
        --FROM ReturnPaymentMode;
GO