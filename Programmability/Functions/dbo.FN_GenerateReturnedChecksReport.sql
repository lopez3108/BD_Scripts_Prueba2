SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:24-10-2023
--CAMBIOS EN 5463, cambiar fecha de  pago de comisiones

--LASTUPDATEDBY: Felipe
--LASTUPDATEDON:17-10-2023
--CAMBIOS EN 5377,Refactorizacion de reporte Returned Checks

-- =============================================
-- Author:      JF
-- Create date: 25/06/2024 11:34 a. m.
-- Database:    devtest
-- Description: task 5643 Ajustes reportes con commission automatic
-- =============================================




CREATE   FUNCTION [dbo].[FN_GenerateReturnedChecksReport] (@AgencyId INT, @FromDate DATETIME = NULL, @ToDate DATETIME = NULL, @CodeFilter VARCHAR(3) = NULL)
RETURNS @result TABLE (
  [Index] INT
 ,[Type] VARCHAR(30)
 ,[CreationDate] DATETIME
 ,[Provider] VARCHAR(30)
 ,[Number] VARCHAR(50)
 ,[Reason] VARCHAR(50)
 ,[Client] VARCHAR(50)
 ,[Usd] DECIMAL(18, 2) NULL
 ,[ProviderFee] DECIMAL(18, 2) NULL
 ,[LauyeUsd] DECIMAL(18, 2) NULL
 ,[CourtUsd] DECIMAL(18, 2) NULL
 ,[Status] VARCHAR(50)
 ,[Debit] DECIMAL(18, 2) NULL
 ,[Credit] DECIMAL(18, 2) NULL
 ,[BalanceUsd] DECIMAL(18, 2) NULL
)


AS
BEGIN

  -- Return checks

  INSERT INTO @result
    SELECT
      1
     ,'RETURNED CHECKS'
     ,CAST(dbo.ReturnedCheck.ReturnDate AS DATE)
     ,SUBSTRING(dbo.Providers.Name, 1, 18)
     ,dbo.ReturnedCheck.CheckNumber
     ,(CASE
        WHEN (LEN(dbo.ReturnReason.Description) > 15) THEN SUBSTRING(dbo.ReturnReason.Description, 1, 15) + '...'
        ELSE dbo.ReturnReason.Description
      END)
     ,SUBSTRING(dbo.Users.Name, 1, 18)
     ,dbo.ReturnedCheck.USD
     ,dbo.ReturnedCheck.ProviderFee
     ,ISNULL(LY.USD, 0) AS LauyeUsd
     ,ISNULL(CP.USD, 0) AS CourtUsd
     ,RS.Description AS Status
     ,dbo.ReturnedCheck.USD + dbo.ReturnedCheck.ProviderFee + ISNULL(LY.USD, 0) + ISNULL(CP.USD, 0)
     ,0
     ,
      --         0 + ISNULL(SUM(dbo.ReturnedCheck.Usd ), 0)
      0 + SUM(ISNULL(dbo.ReturnedCheck.USD, 0) + ISNULL(dbo.ReturnedCheck.ProviderFee, 0) + ISNULL(CP.USD, 0) + ISNULL(LY.USD, 0)) AS BalanceUsd


    FROM dbo.ReturnedCheck
    INNER JOIN dbo.Providers
      ON dbo.ReturnedCheck.ProviderId = dbo.Providers.ProviderId
    INNER JOIN dbo.ReturnReason
      ON dbo.ReturnedCheck.ReturnReasonId = dbo.ReturnReason.ReturnReasonId
    INNER JOIN dbo.Clientes
      ON dbo.ReturnedCheck.ClientId = dbo.Clientes.ClienteId
    INNER JOIN dbo.Users
      ON dbo.Clientes.UsuarioId = dbo.Users.UserId
    LEFT JOIN dbo.ReturnStatus RS
      ON dbo.ReturnedCheck.StatusId = RS.ReturnStatusId
    LEFT JOIN dbo.LawyerPayments LY
      ON dbo.ReturnedCheck.ReturnedCheckId = LY.ReturnedCheckId
    LEFT JOIN dbo.CourtPayment CP
      ON dbo.ReturnedCheck.ReturnedCheckId = CP.ReturnedCheckId
    WHERE (

    (@CodeFilter = 'C01'
    AND RS.Code = 'C01')
    OR (@CodeFilter = 'C02'
    AND CAST(ReturnDate AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(ReturnDate AS DATE) <= CAST(@ToDate AS DATE))
    OR (@CodeFilter = 'C03'
    AND RS.Code = 'C03')
    )
    AND ReturnedAgencyId = @AgencyId

    GROUP BY CAST(dbo.ReturnedCheck.ReturnDate AS DATE)
            ,SUBSTRING(dbo.Providers.Name, 1, 18)
            ,dbo.ReturnedCheck.CheckNumber
            ,dbo.ReturnReason.Description
            ,SUBSTRING(dbo.Users.Name, 1, 18)
            ,dbo.ReturnedCheck.Usd
            ,dbo.ReturnedCheck.ProviderFee
            ,ISNULL(LY.Usd, 0)
            ,ISNULL(CP.Usd, 0)
            ,RS.Description

  INSERT INTO @result
    SELECT
      2
     ,'PAYMENT'
     ,CAST(dbo.ReturnPayments.CreationDate AS DATE)
     ,'PAYMENT'
     ,dbo.ReturnedCheck.CheckNumber
     ,'-'
     ,SUBSTRING(dbo.Users.Name, 1, 18)
     ,0
     ,0
     ,0
     ,0
     ,'-'
     ,0
     ,dbo.ReturnPayments.Usd
     ,0 - ISNULL(SUM(dbo.ReturnPayments.Usd), 0)
    FROM dbo.ReturnPayments
    INNER JOIN dbo.ReturnedCheck
      ON dbo.ReturnPayments.ReturnedCheckId = dbo.ReturnedCheck.ReturnedCheckId
    INNER JOIN dbo.Clientes
      ON dbo.ReturnedCheck.ClientId = dbo.Clientes.ClienteId
    INNER JOIN dbo.Users
      ON dbo.Clientes.UsuarioId = dbo.Users.UserId
    LEFT JOIN dbo.ReturnStatus RS
      ON dbo.ReturnedCheck.StatusId = RS.ReturnStatusId
    WHERE  --@CodeFilter = 'C01' pending
    ((@CodeFilter = 'C01'
    AND RS.Code = 'C01')
    OR (@CodeFilter = 'C02'
    AND CAST(ReturnPayments.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(ReturnPayments.CreationDate AS DATE) <= CAST(@ToDate AS DATE))
    OR (@CodeFilter = 'C03'
    AND RS.Code = 'C03')
    )
    --CAST(dbo.ReturnPayments.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    --               AND CAST(dbo.ReturnPayments.CreationDate AS DATE) <= CAST(@ToDate AS DATE)  AND
    AND dbo.ReturnedCheck.ReturnedAgencyId = @AgencyId
    --AND  (RS.Code = 'C01' OR dbo.ReturnedCheck.StatusId IS NULL)
    -- Provider commission

    GROUP BY CAST(dbo.ReturnPayments.CreationDate AS DATE)
            ,dbo.ReturnedCheck.CheckNumber
            ,SUBSTRING(dbo.Users.Name, 1, 18)
            ,dbo.ReturnPayments.Usd

  IF (@CodeFilter = 'C02')
  BEGIN
    INSERT INTO @result
      SELECT
        3
       ,'COMMISSIONS'
       ,
        --           CAST(CreationDate AS date),
        dbo.[fn_GetNextDayPeriod](Year, Month)
       ,
        --           UPPER(CAST('C.P. ' + DATENAME(MONTH, DATEADD(MONTH, [Month], -1)) + '-' + CAST([Year] AS varchar) AS varchar)),
        'COMM. ' + dbo.[fn_GetMonthByNum](ProviderCommissionPayments.Month) + '-' + CAST(ProviderCommissionPayments.Year AS CHAR(4)) Description
       ,'-'
       ,'-'
       ,'-'
       ,0
       ,0
       ,0
       ,0
       ,'-'
       ,dbo.ProviderCommissionPayments.Usd
       ,0
       ,0 + ISNULL(SUM(dbo.ProviderCommissionPayments.Usd), 0)
      FROM dbo.ProviderCommissionPayments
      INNER JOIN dbo.Providers
        ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId
      INNER JOIN dbo.ProviderTypes
        ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
      WHERE
      --           CAST(CreationDate AS date) >= CAST(@FromDate AS date) AND
      --                 CAST(CreationDate AS date) <= CAST(@ToDate AS date) 
      (dbo.[fn_GetNextDayPeriod](Year, Month) >= CAST(@FromDate AS DATE)
      OR @FromDate IS NULL)
      AND (dbo.[fn_GetNextDayPeriod](Year, Month) <= CAST(@ToDate AS DATE)
      OR @ToDate IS NULL)
      AND AgencyId = @AgencyId
      AND dbo.ProviderTypes.Code = 'C08'
      GROUP BY CAST(CreationDate AS DATE)
              ,dbo.ProviderCommissionPayments.Month
              ,dbo.ProviderCommissionPayments.Year
              ,dbo.ProviderCommissionPayments.Usd
  END;

  -----


  RETURN;
END;
GO