SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetReportBillPaymentsCommission]
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
            [Type]         VARCHAR(30),
            [CreationDate] DATETIME,
            [Description]  VARCHAR(50),
            [Debit]        DECIMAL(18, 2) NULL,
            [Credit]       DECIMAL(18, 2) NULL,
            [Balance]       DECIMAL(18, 2)
         );

		  -- Agency Initial balance
	 DECLARE @agencyInitialBalance DECIMAL(18,2)

DECLARE @initialBalanceFinalDate DATETIME
SET @initialBalanceFinalDate = DATEADD(day, -1, @FromDate)


SET @agencyInitialBalance = ISNULL((SELECT SUM(CAST(Balance AS DECIMAL(18,2))) FROM dbo.FN_GetTopUpPaymentsCommissionReport(@AgencyId, @ProviderId, '2018-01-01', @initialBalanceFinalDate)),0)
		

		INSERT INTO #Temp
               SELECT 0 [Index], 
                      'INITIAL BALANCE' Type, 
                      CAST(@initialBalanceFinalDate AS DATE) CreationDate, 
                      'INITIAL BALANCE' Description, 
                   NULL Debit, 
                      NULL Credit,
					  @agencyInitialBalance Balance

UNION ALL

                SELECT * FROM 
				dbo.FN_GetTopUpPaymentsCommissionReport(@AgencyId, @ProviderId, @FromDate, @ToDate)
        ORDER BY   [CreationDate],[Index]

        

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