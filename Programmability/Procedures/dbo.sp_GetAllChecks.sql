SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--2024-03-22 DJ/5695: Added parameter @Date
-- 2025-06-09 JF/6571: Guardar valor de descuento aplicado en el momento del registro y no por referencia a configuración

CREATE PROCEDURE [dbo].[sp_GetAllChecks] @ClientId INT = NULL,
@ClientName VARCHAR(80) = NULL,
@Maker VARCHAR(80) = NULL,
@Account VARCHAR(50) = NULL,
@Routing VARCHAR(50) = NULL,
@BankName VARCHAR(60) = NULL,
@StartDate DATETIME = NULL,
@EndDate DATETIME = NULL,
@AgencyId INT = NULL,
@CheckNumber VARCHAR(50) = NULL,
@CheckTypeId INT = NULL,
@ClientBlocked BIT = NULL,
@MakerBlocked BIT = NULL,
@AccountBlocked BIT = NULL,
@CheckStatusId INT = NULL,
@CashierId INT = NULL,
@CodeTypeDate VARCHAR(5) = NULL,
@CheckAmount DECIMAL(18, 2) = NULL,
@Date DATETIME = NULL
AS
BEGIN

  IF (@StartDate IS NULL
    AND @Date IS NOT NULL)
  BEGIN

    SET @StartDate = DATEADD(DAY, -10, @Date)
    SET @EndDate = @Date

  END

  DECLARE @blockStatus INT

  IF (@ClientBlocked IS NULL
    AND @MakerBlocked IS NULL
    AND @AccountBlocked IS NULL)
  BEGIN

    SET @blockStatus = 1


  END


  DECLARE @StatusCode VARCHAR(10)
         ,@StatusPendingId VARCHAR(10)
  SET @StatusCode = (CASE
    WHEN @CheckStatusId = NULL THEN NULL
    ELSE (SELECT
          Code
        FROM DocumentStatus
        WHERE DocumentStatusId = @CheckStatusId)
  END)
  SET @StatusPendingId = (SELECT
      DocumentStatusId
    FROM DocumentStatus
    WHERE Code = 'C02')


  SELECT
    ce1.CheckId RealCheckId
   ,CASE
      WHEN ce1.CheckId IS NOT NULL THEN ce1.CheckId
      ELSE rt.ReturnedCheckId
    END AS CheckId
   ,ISNULL(rt.ClientBlocked, 0) AS ClientBlocked
   ,ISNULL(rt.MakerBlocked, 0) AS MakerBlocked
   ,ISNULL(rt.AccountBlocked, 0) AS AccountBlocked
   ,CASE
      WHEN c.CheckId IS NOT NULL AND
        ce1.IsCheckParent = 1 THEN UPPER(ct.Description)
      ELSE (SELECT TOP 1
            UPPER(CTY.Description)
          FROM ProviderTypes pt
          LEFT JOIN CheckTypesCategories ctc
            ON ctc.Code =
            CASE
              WHEN pt.Code = 'C04' --provider type tax 
              THEN 'C03' --check type tax
              WHEN pt.Code = 'C03' --provider type payrroll
              THEN 'C02' --check type payrroll

            END
          LEFT JOIN CheckTypes CTY
            ON CTY.CategoryCheckTypeId = ctc.CategoryCheckTypeId
          WHERE pt.ProviderTypeId = ce1.ProviderTypeId)
    END AS CheckType
   ,CASE
      WHEN ce1.CheckElsId IS NOT NULL THEN ce1.CreationDate
      ELSE rt.CreationDate
    END AS CreationDate
   ,CASE
      WHEN ce1.CheckElsId IS NOT NULL THEN FORMAT(ce1.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')
      ELSE FORMAT(rt.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')
    END AS CreationDateFormat2
   ,CASE
      WHEN ce1.CheckElsId IS NOT NULL THEN ce1.CheckNumber ---se cambio a check els
      ELSE rt.CheckNumber
    END AS Number
   ,CASE
      WHEN ce1.CheckElsId IS NOT NULL THEN ce1.CheckDate ---se cambio a check els
      ELSE rt.CheckDate
    END AS CheckDate
   ,CASE
      WHEN ce1.CheckElsId IS NOT NULL THEN FORMAT(ce1.CheckDate, 'MM-dd-yyyy ', 'en-US')
      ELSE FORMAT(rt.CheckDate, 'MM-dd-yyyy ', 'en-US')
    END AS CheckDateFormat
   ,CASE
      WHEN rt.ReturnedCheckId IS NOT NULL THEN CASE
          WHEN rt.ClientBlocked = 1 AND
            rt.MakerBlocked = 1 AND
            rt.AccountBlocked = 1 THEN 'CLIENT,MAKER,ACCOUNT'
          WHEN rt.ClientBlocked = 1 AND
            rt.MakerBlocked = 1 THEN 'CLIENT,MAKER'
          WHEN rt.ClientBlocked = 1 AND
            rt.AccountBlocked = 1 THEN 'CLIENT,ACCOUNT'
          WHEN rt.MakerBlocked = 1 AND
            rt.AccountBlocked = 1 THEN 'MAKER,ACCOUNT'
          WHEN rt.ClientBlocked = 1 THEN 'CLIENT'
          WHEN rt.MakerBlocked = 1 THEN 'MAKER'
          WHEN rt.AccountBlocked = 1 THEN 'ACCOUNT'
        END
    END AS BlockType
   ,CASE
      WHEN ce1.CheckElsId IS NOT NULL THEN r.BankName
      ELSE rr.BankName
    END AS Bank
   ,rt.ReturnDate ReturnedDate
   ,FORMAT(rt.ReturnDate, 'MM-dd-yyyy', 'en-US') ReturnedDateFormat
   ,dbo.ReturnReason.ReturnReasonId
   ,dbo.ReturnReason.Description AS ReturnReason
   ,dbo.ReturnStatus.ReturnStatusId
   ,dbo.ReturnStatus.Description AS ReturnStatusName
   ,dbo.ReturnStatus.Code
   ,rt.ReturnedAgencyId
   ,ar.Code + ' - ' + ar.Name ReturnedAgencyName
   ,ur.Name ReturnedBy
   ,CASE
      WHEN ce1.CheckElsId IS NOT NULL THEN ce1.ClientId
      ELSE rt.ClientId
    END AS ClientId
   ,CASE
      WHEN ce1.CheckElsId IS NOT NULL THEN uc.Name
      ELSE ucr.Name
    END AS ClientName
   ,CASE
      WHEN ce1.CheckElsId IS NOT NULL THEN m.Name
      ELSE mr.Name
    END AS MakerName
   ,CASE
      WHEN ce1.CheckElsId IS NOT NULL THEN m.MakerId
      ELSE mr.MakerId
    END AS MakerId
   ,CASE
      WHEN ce1.CheckElsId IS NOT NULL THEN ce1.Account
      ELSE rt.Account
    END AS Account
   ,CASE
      WHEN ce1.CheckElsId IS NOT NULL THEN ce1.Routing
      ELSE rt.Routing
    END AS Routing
   ,CASE
      WHEN ce1.CheckElsId IS NOT NULL THEN ulu.Name
      ELSE ulurt.Name
    END AS UserLastUpdated
   ,CASE
      WHEN ce1.CheckElsId IS NOT NULL THEN ce1.LastUpdatedOn
      ELSE rt.LastModifiedDate
    END AS LastUpdatedOn
   ,CASE
      WHEN ce1.CheckElsId IS NOT NULL THEN FORMAT(ce1.LastUpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')
      ELSE FORMAT(rt.LastModifiedDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')
    END AS LastUpdatedOnFormat
   ,CASE
      WHEN rt.AccountBlocked = 0 OR
        rt.AccountBlocked IS NULL OR
        rt.ClientBlocked = 0 OR
        rt.ClientBlocked IS NULL OR
        rt.AccountBlocked = 0 OR
        rt.AccountBlocked IS NULL THEN CAST(0 AS BIT)
      ELSE CAST(1 AS BIT)
    END AS Status
   ,rt.ReturnedCheckId
   ,ac.Code + ' - ' + ac.Name RegisteredInAgency
   ,ac.Address AgencyAddress
   ,ac.Telephone AgencyPhone
   ,ac.Name AgencyName
   ,CASE
      WHEN
        rt.ReturnedCheckId IS NOT NULL THEN 0
      WHEN ds.Code = 'C02' OR
        dsc.Code = 'C02' THEN @StatusPendingId
      ELSE ds.DocumentStatusId
    END AS CheckStatusId
   ,CASE
      WHEN
        rt.ReturnedCheckId IS NOT NULL THEN 'C0'
      WHEN ds.Code = 'C02' OR
        dsc.Code = 'C02' THEN 'C02'
      ELSE ds.Code
    END AS CheckStatusCode
   ,CASE
      WHEN
        rt.ReturnedCheckId IS NOT NULL THEN 'RETURNED'
      ELSE CASE
          WHEN ds.Code = 'C02' OR
            dsc.Code = 'C02' THEN 'PENDING INFORMATION'
          ELSE ds.Description
        END
    END AS CheckStatusName
   ,dsc.DocumentStatusId ClientStatusId
   ,dsc.Code ClientStatusCode
   ,ce1.AgencyId
   ,CASE
      WHEN
        ca.CashierId IS NULL THEN crt.CashierId
      ELSE ca.CashierId
    END AS CashierId
   ,UPPER(Countries_2.Name) AS Doc2CountryName
   ,UPPER(Countries_1.Name) AS Doc1CountryName
   ,cc.Doc1Number
   ,cc.Doc1Expire
   ,cc.Doc2Number
   ,cc.Doc2Expire
   ,cc.Doc1State
   ,cc.Doc2State
   ,cc.Doc1Front
   ,cc.Doc1Back
   ,cc.Doc2Front
   ,cc.Doc2Back
   ,tid1.Description Doc1TypeDescription
   ,tid2.Description Doc2TypeDescription
   ,CASE
      WHEN
        rt.ReturnedCheckId IS NOT NULL THEN rt.USD
      ELSE ce1.Amount
    END AS Amount
   ,ISNULL(ce1.Amount, 0) * (ISNULL(ce1.Fee, 0) / 100) AS Fee
   ,ISNULL(p.Usd, 0) AS Discount
   ,(ISNULL(ce1.Amount, 0) - (ISNULL(ce1.Amount, 0) * (ISNULL(ce1.Fee, 0) / 100))) + ISNULL(pc.Usd, 0) AS Total

   ,CASE
      WHEN u.[Name] IS NOT NULL THEN u.[Name]
      ELSE ur.[Name]
    END
    AS CreatedBy
   ,ds.Code
  FROM ChecksEls ce1
  LEFT JOIN dbo.Checks c
    ON c.CheckId = ce1.CheckId
  INNER JOIN dbo.Users u
    ON u.UserId = ce1.CreatedBy
  INNER JOIN Cashiers ca
    ON ca.UserId = u.UserId
  LEFT JOIN dbo.CheckTypes ct
    ON c.CheckTypeId = ct.CheckTypeId
  FULL OUTER JOIN dbo.ReturnedCheck rt
    ON rt.CheckNumber = ce1.CheckNumber
      AND rt.Account = ce1.Account
  LEFT JOIN Routings r
    ON ce1.Routing = r.Number
  LEFT JOIN Routings rr
    ON rt.Routing = rr.Number
  LEFT JOIN dbo.ReturnReason
    ON rt.ReturnReasonId = dbo.ReturnReason.ReturnReasonId
  LEFT JOIN dbo.ReturnStatus
    ON rt.StatusId = dbo.ReturnStatus.ReturnStatusId
  LEFT JOIN dbo.Agencies ar
    ON ar.AgencyId = rt.ReturnedAgencyId
  LEFT JOIN dbo.Agencies ac
    ON ac.AgencyId = ce1.AgencyId
  LEFT JOIN dbo.Clientes cc
    ON ce1.ClientId = cc.ClienteId
  LEFT JOIN dbo.Users AS uc
    ON cc.UsuarioId = uc.UserId
  LEFT JOIN dbo.Clientes
    ON rt.ClientId = dbo.Clientes.ClienteId
  LEFT JOIN dbo.Users AS ucr
    ON dbo.Clientes.UsuarioId = ucr.UserId
  LEFT JOIN Countries Countries_1
    ON cc.Doc1Country = Countries_1.CountryId
  LEFT JOIN Countries AS Countries_2
    ON cc.Doc2Country = Countries_2.CountryId
  LEFT JOIN TypeID tid1
    ON tid1.TypeId = cc.Doc1Type
  LEFT JOIN TypeID tid2
    ON tid2.TypeId = cc.Doc2Type
  LEFT JOIN dbo.Makers m
    ON m.MakerId = ce1.MakerId
  LEFT JOIN dbo.Makers mr
    ON mr.MakerId = rt.MakerId
  LEFT JOIN dbo.Users AS ur
    ON rt.CreatedBy = ur.UserId
  LEFT JOIN dbo.Users AS ulu
    ON ce1.LastUpdatedBy = ulu.UserId
  LEFT JOIN dbo.Users AS ulurt
    ON rt.LastModifiedBy = ulurt.UserId
  LEFT JOIN DocumentStatus ds
    ON ds.DocumentStatusId = c.CheckStatusId
  LEFT JOIN DocumentStatus dsc
    ON dsc.DocumentStatusId = cc.ClientStatusId
  LEFT JOIN dbo.Cashiers crt
    ON crt.UserId = ur.UserId
  LEFT JOIN PromotionalCodesStatus P
    ON ce1.CheckElsId = P.CheckId
  LEFT JOIN PromotionalCodes pc
    ON pc.PromotionalCodeId = P.PromotionalCodeId
  WHERE ((ce1.CheckElsId IS NOT NULL
  AND ce1.ClientId = @ClientId
  OR ce1.CheckElsId IS NULL
  AND rt.ClientId = @ClientId)
  OR @ClientId IS NULL)
  AND ((ce1.CheckElsId IS NOT NULL
  AND uc.Name LIKE '%' + @ClientName + '%'
  OR ce1.CheckElsId IS NULL
  AND ucr.Name LIKE '%' + @ClientName + '%')
  OR @ClientName IS NULL)
  AND ((ce1.CheckElsId IS NOT NULL
  AND m.Name LIKE '%' + @Maker + '%'
  OR ce1.CheckElsId IS NULL
  AND mr.Name LIKE '%' + @Maker + '%')
  OR @Maker IS NULL)
  AND ((ce1.CheckElsId IS NOT NULL
  AND ce1.Account LIKE '%' + @Account + '%'
  OR ce1.CheckId IS NULL
  AND rt.Account LIKE '%' + @Account + '%')
  OR @Account IS NULL)
  AND ((ce1.CheckElsId IS NOT NULL
  AND ce1.CheckNumber = @CheckNumber
  OR ce1.CheckElsId IS NULL
  AND rt.CheckNumber = @CheckNumber)
  OR @CheckNumber IS NULL)
  AND ((ce1.CheckElsId IS NOT NULL
  AND ce1.Routing = @Routing
  OR ce1.CheckElsId IS NULL
  AND rt.Routing LIKE @Routing)
  OR @Routing IS NULL)
  AND ((rt.ReturnedCheckId IS NOT NULL
  AND rt.USD = @CheckAmount
  OR rt.ReturnedCheckId IS NULL
  AND ce1.Amount = @CheckAmount)
  OR @CheckAmount IS NULL)
  AND ((ce1.CheckElsId IS NOT NULL
  AND r.BankName LIKE '%' + @BankName + '%'
  OR ce1.CheckElsId IS NULL
  AND rr.BankName LIKE '%' + @BankName + '%')
  OR @BankName IS NULL)
  AND ((
  ce1.CheckElsId IS NOT NULL
  --este es el bloque cuando no se requiere buscar por tipo de fecha
  AND ((@CodeTypeDate IS NULL
  OR @CodeTypeDate = '')
  AND (
  (CAST(ce1.CheckDate AS DATE) >= CAST(@StartDate AS DATE)
  OR @StartDate IS NULL)
  AND (CAST(ce1.CheckDate AS DATE) <= CAST(@EndDate AS DATE)
  OR @EndDate IS NULL)))
  --este es el bloque cuando si se requiere buscar por tipo de fecha task 5695
  OR (((@CodeTypeDate IS NOT NULL
  OR @CodeTypeDate != '')
  AND ((@CodeTypeDate = 'C01'
  AND CAST(ce1.CreationDate AS DATE) >= CAST(@StartDate AS DATE)
  AND CAST(ce1.CreationDate AS DATE) <= CAST(@EndDate AS DATE))
  OR (@CodeTypeDate = 'C02'
  AND CAST(ce1.CheckDate AS DATE) >= CAST(@StartDate AS DATE)
  AND CAST(ce1.CheckDate AS DATE) <= CAST(@EndDate AS DATE))))))
  --busca el los cheques retornados
  OR ce1.CheckElsId IS NULL
  AND (CAST(rt.CreationDate AS DATE) >= CAST(@StartDate AS DATE)
  OR @StartDate IS NULL)
  AND (CAST(rt.CreationDate AS DATE) <= CAST(@EndDate AS DATE)
  OR @EndDate IS NULL))
  AND (@CashierId IS NULL
  OR @CashierId = CASE
    WHEN
      ca.CashierId IS NOT NULL THEN ca.CashierId
    ELSE crt.CashierId
  END
  )
  AND (
  ((@StatusCode = 'C02'
  AND (ds.Code = @StatusCode
  OR dsc.Code = @StatusCode))--pendings
  )
  OR (@StatusCode IS NULL)--all status
  )
  AND (@blockStatus = 1
  OR ((rt.AccountBlocked = @AccountBlocked
  AND (rt.MakerBlocked = 1
  OR rt.MakerBlocked = 0)
  AND (rt.ClientBlocked = 1
  OR rt.ClientBlocked = 0))
  OR (rt.MakerBlocked = @MakerBlocked
  AND (rt.AccountBlocked = 1
  OR rt.AccountBlocked = 0)
  AND (rt.ClientBlocked = 1
  OR rt.ClientBlocked = 0))
  OR (rt.ClientBlocked = @ClientBlocked
  AND (rt.AccountBlocked = 1
  OR rt.AccountBlocked = 0)
  AND (rt.MakerBlocked = 1
  OR rt.MakerBlocked = 0))))


  AND ((ce1.CheckElsId IS NOT NULL
  AND ac.AgencyId = @AgencyId)
  OR (rt.ReturnedAgencyId = @AgencyId)
  OR @AgencyId IS NULL)

  --Cuando existe un cheque id, el type se toma de la relacion entre cheques y types
  AND (((ce1.CheckId IS NOT NULL
  AND ce1.IsCheckParent = 1
  AND c.CheckTypeId = @CheckTypeId)
  OR @CheckTypeId IS NULL)
  OR (            --Cuando es un cheque del daily, entonces el type se filtra mediante la relación entre la tabla provider type y check type
  (ce1.IsCheckParent = 0
  OR ce1.IsCheckParent IS NULL)
  AND ce1.ProviderTypeId = (SELECT TOP 1
      pt.ProviderTypeId
    FROM ProviderTypes pt
    INNER JOIN CheckTypesCategories ctc
      ON ctc.Code =
      CASE
        WHEN pt.Code = 'C04' --provider type tax 
        THEN 'C03' --check type tax
        WHEN pt.Code = 'C03' --provider type payrroll
        THEN 'C02' --check type payrroll							 
      END
    INNER JOIN CheckTypes CTY
      ON CTY.CategoryCheckTypeId = ctc.CategoryCheckTypeId
    WHERE CTY.CheckTypeId = @CheckTypeId)
  )
  )

  ORDER BY CASE
    WHEN ce1.CheckElsId IS NOT NULL THEN ce1.CreationDate
    ELSE rt.CreationDate
  END ASC
END;




GO