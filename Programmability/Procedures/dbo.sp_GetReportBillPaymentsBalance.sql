SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetReportBillPaymentsBalance]
(@AgencyId   INT, 
 @ProviderId INT, 
 @FromDate   DATETIME = NULL, 
 @ToDate     DATETIME = NULL, 
 @Date       DATETIME
)
AS
    BEGIN
       
	   IF(@FromDate IS NULL)
            BEGIN
                SET @FromDate = DATEADD(day, -10, @Date);
                SET @ToDate = @Date;
            END;

			CREATE TABLE #Temp 
(
[ID] INT IDENTITY(1,1),
[Index]        INT, 
         [Type]         VARCHAR(100), 
         [CreationDate] DATETIME, 
         [Description]  VARCHAR(300), 
         [Debit]        DECIMAL(18, 2) NULL, 
         [Credit]       DECIMAL(18, 2) NULL,
		 [Balance]       DECIMAL(18, 2) NULL
		 
)

			 -- INITIAL BALANCE

			  -- Agency Initial balance
	 DECLARE @agencyInitialBalance DECIMAL(18,2)
SET @agencyInitialBalance = ISNULL((SELECT TOP 1 InitialBalance 
FROM BillPaymentxAgencyInitialBalances 
WHERE AgencyId = @AgencyId AND ProviderId = @providerId),0)

DECLARE @initialBalanceFinalDate DATETIME
SET @initialBalanceFinalDate = DATEADD(day, -1, @FromDate)

SET @agencyInitialBalance = @agencyInitialBalance +  ISNULL((SELECT SUM(CAST(Balance AS DECIMAL(18,2))) FROM dbo.FN_GenerateTopUpPaymentsReport(@AgencyId, @ProviderId, '1985-01-01', @initialBalanceFinalDate, @Date)),0)
		

		INSERT INTO #Temp
               SELECT 1 [Index], 
                      'INITIAL BALANCE' Type, 
                      CAST(@initialBalanceFinalDate AS DATE) CreationDate, 
                      'INITIAL BALANCE' Description, 
                   @agencyInitialBalance Debit, 
                      NULL Credit,
					  @agencyInitialBalance Balance
       UNION ALL
        SELECT *
        FROM [dbo].[FN_GenerateTopUpPaymentsReport](@AgencyId, @ProviderId, @FromDate, @ToDate, @Date)
        ORDER BY CreationDate, 
                 [Index];

				
				
				SELECT 
				 *,
				 (
            SELECT ISNULL (SUM(CAST(Balance AS DECIMAL(18,2))),0)
            FROM    #Temp T2
            WHERE T2.ID <= T1.ID
        ) RunningSum
				 FROM #Temp T1

				 DROP TABLE #Temp

    END;






GO