SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-03-07 5668: Created to add initial balance to report


-- =============================================
-- Author:      JF
-- Create date: 21/06/2024 12:26 p. m.
-- Database:    copiaDevtest
-- Description: task 5905 Comisión pagada en 0.00 debe reflejarse en el reporte
-- =============================================


CREATE FUNCTION [dbo].[FN_GetTopUpPaymentsCommissionReport](
@AgencyId   INT, 
 @ProviderId INT, 
 @FromDate   DATETIME = NULL, 
 @ToDate     DATETIME = NULL)
RETURNS @result TABLE
([Index]        INT, 
         [Type]         VARCHAR(100), 
         [CreationDate] DATETIME, 
         [Description]  VARCHAR(300), 
         [Debit]        DECIMAL(18, 2) NULL, 
         [Credit]       DECIMAL(18, 2) NULL,
		 [Balance]       DECIMAL(18, 2) NULL
		 
)
AS
     BEGIN

				 INSERT INTO @result
                SELECT 2,
                       t.Type,
                       t.CreationDate,
                       UPPER(t.Description) as Description,
                       SUM(t.Usd) AS Usd,
                       NULL,
					    SUM(t.Usd) AS Balance
                FROM
                (
                    SELECT 'CLOSING DAILY' AS Type,
                           CAST(dbo.Daily.CreationDate AS DATE) AS CreationDate,
                           'CLOSING DAILY' AS Description,
                           ISNULL(dbo.BillPayments.Commission, 0) AS Usd
                    FROM dbo.Daily
                         INNER JOIN dbo.Cashiers ON dbo.Cashiers.CashierId = dbo.Daily.CashierId
                         INNER JOIN dbo.BillPayments ON dbo.Daily.AgencyId = dbo.BillPayments.AgencyId
                                                        AND CAST(billpayments.CreationDate AS DATE) = CAST(daily.CreationDate AS DATE)
                                                        AND dbo.Cashiers.UserId = billpayments.CreatedBy
                    WHERE dbo.Daily.AgencyId = @AgencyId
                          AND CAST(dbo.Daily.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                          AND CAST(dbo.Daily.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                          AND dbo.BillPayments.ProviderId = @ProviderId
						  AND (dbo.BillPayments.Commission IS NOT NULL AND dbo.BillPayments.Commission <> 0)
                ) t
                GROUP BY t.CreationDate,
                         t.Type,
                         t.Description;

-- Closing commissions

         INSERT INTO @result
                SELECT 1,
                       'COMMISSION',
                       dbo.[fn_GetNextDayPeriod](ProviderCommissionPayments.Year, ProviderCommissionPayments.Month) CreationDate ,
                        'COMM. ' + dbo.[fn_GetMonthByNum](ProviderCommissionPayments.Month) + '-' + CAST(ProviderCommissionPayments.Year AS CHAR(4)) Description,
--                       'CLOSING COMMISSION',
                       NULL,
                       Usd,
					            - Usd
                FROM dbo.ProviderCommissionPayments
                WHERE AgencyId = @AgencyId
                        AND ProviderId = @ProviderId
                        AND (dbo.[fn_GetNextDayPeriod](Year, Month) >= CAST(@FromDate AS date)
                        OR @FromDate IS NULL) AND
                        (dbo.[fn_GetNextDayPeriod](Year, Month) <= CAST(@ToDate AS date)
                        OR @ToDate IS NULL)
--                      AND CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                      AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
					  AND (Usd IS NOT NULL )


         RETURN;
     END;






GO