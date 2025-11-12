SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportReturnedChecksPendingPayment]
(@AgencyId   INT, 
 @FromDate   DATETIME   = NULL, 
 @ToDate     DATETIME   = NULL, 
 @Date       DATETIME, 
 @CodeFilter VARCHAR(3) = NULL
)
AS
    BEGIN
        IF(@FromDate IS NULL)
            BEGIN
                SET @FromDate = DATEADD(day, -10, @Date);
                SET @ToDate = @Date;
            END;
        CREATE TABLE #Temp
        ([Index]        INT, 
         [Type]         VARCHAR(30), 
         [CreationDate] DATETIME, 
         [Provider]     VARCHAR(30), 
         [Number]       VARCHAR(50), 
         [Reason]       VARCHAR(50), 
         [Client]       VARCHAR(50), 
         [Usd]          DECIMAL(18, 2) NULL, 
         [ProviderFee]  DECIMAL(18, 2) NULL, 
         [Debit]        DECIMAL(18, 2) NULL, 
         [Credit]       DECIMAL(18, 2) NULL, 
         Balance        DECIMAL(18, 2) NULL
        );

        -- Return checks
        INSERT INTO #Temp
               SELECT 2, 
                      'RETURNED CHECKS', 
                      CAST(dbo.ReturnedCheck.ReturnDate AS DATE), 
                      SUBSTRING(dbo.Providers.Name, 1, 18), 
                      dbo.ReturnedCheck.CheckNumber, 
                      ( CASE when (LEN(dbo.ReturnReason.Description) > 15)
				 THEN SUBSTRING(dbo.ReturnReason.Description, 1, 15) + '...'
				 ELSE dbo.ReturnReason.Description end),  
                      SUBSTRING(dbo.Users.Name, 1, 18), 
                      dbo.ReturnedCheck.USD, 
                      dbo.ReturnedCheck.Fee, 
                      dbo.ReturnedCheck.USD + dbo.ReturnedCheck.Fee Debit, 
                      [dbo].[fn_CalculatePaidReturned](dbo.ReturnedCheck.ReturnedCheckId) Credit, 
                      [dbo].[fn_CalculateDueReturned](dbo.ReturnedCheck.ReturnedCheckId) Balance
               FROM dbo.ReturnedCheck
                    INNER JOIN dbo.Providers ON dbo.ReturnedCheck.ProviderId = dbo.Providers.ProviderId
                    INNER JOIN dbo.ReturnReason ON dbo.ReturnedCheck.ReturnReasonId = dbo.ReturnReason.ReturnReasonId
                    INNER JOIN dbo.Clientes ON dbo.ReturnedCheck.ClientId = dbo.Clientes.ClienteId
                    INNER JOIN dbo.Users ON dbo.Clientes.UsuarioId = dbo.Users.UserId
                    LEFT JOIN dbo.ReturnStatus RS ON dbo.ReturnedCheck.StatusId = RS.ReturnStatusId
               WHERE
               --@CodeFilter = 'C01' pending
               ((@CodeFilter = 'C01'
                 AND RS.Code = 'C01')
                OR (@CodeFilter = 'C02' AND  RS.CODE !='C02' AND  RS.CODE !='C03'
                    AND CAST(ReturnDate AS DATE) >= CAST(@FromDate AS DATE)
                    AND CAST(ReturnDate AS DATE) <= CAST(@ToDate AS DATE)))
               --RS.Code=
               --			    ( CASE
               --                                              WHEN  @Code = 'C01'
               --                                              THEN  'C01'
               --                                              ELSE 	(CAST(ReturnDate as DATE) > CAST(@FromDate as DATE))
               --											  --AND
               --													-- CAST(ReturnDate as DATE) <= CAST(@ToDate as DATE)
               --                                          END)
               --						 CAST(ReturnDate as DATE) >= CAST(@FromDate as DATE) AND
               --CAST(ReturnDate as DATE) <= CAST(@ToDate as DATE) AND
               AND ReturnedAgencyId = @AgencyId;
        --AND  (RS.Code = 'C01' OR dbo.ReturnedCheck.StatusId IS NULL)

        SELECT *
        FROM #Temp
        ORDER BY CreationDate, 
                 [Index];
        DROP TABLE #Temp;
    END;
GO