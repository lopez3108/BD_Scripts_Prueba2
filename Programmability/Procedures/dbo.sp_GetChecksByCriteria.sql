SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetChecksByCriteria] @ClientId INT = NULL,
@MakerId INT = NULL,
@Account VARCHAR(50) = NULL,
@StartDate DATETIME = NULL,
@EndDate DATETIME = NULL,
@AgencyId INT = NULL,
@CheckNumber VARCHAR(15) = NULL,
@CheckTypeId INT = NULL,
@LikeAccount BIT = NULL,
@Routing NVARCHAR(50) = NULL
AS
BEGIN
-- se prioriza  el registro del check
  IF EXISTS (SELECT TOP 1
        *
     
         FROM Checks c
      WHERE c.Number = @CheckNumber
      AND c.Account = @Account
      AND c.Routing = @Routing)
  BEGIN



    SELECT
      dbo.Checks.CheckId
     ,dbo.Checks.ClientId
     ,dbo.Checks.CashierId
     ,dbo.Checks.DateCashed
     ,dbo.Checks.Maker
     ,dbo.Checks.Amount
     ,dbo.Checks.Fee
     ,dbo.Checks.Number
     ,dbo.Checks.Account
     ,dbo.Checks.Routing
     ,dbo.Checks.DateCheck
     ,dbo.Users.Name AS Cliente
     ,dbo.Users.UserId
     ,dbo.Users.Telephone TelephoneClient
     ,Users_1.Name AS Cashier
     ,dbo.Agencies.Name AS Agency
     ,dbo.Makers.Name AS MakerName
     ,dbo.Makers.MakerId
     ,dbo.CheckTypes.Description AS CheckType
     ,dbo.Checks.ValidatedBy
     ,Users_2.Name AS ValidatedByName
     ,
      --r.BankAddress, 
      r.BankName
     ,
      --r.BankCity, 
      --r.BankState, 
      --r.BankZipCode, 
      r.RoutingId
     ,(SELECT
          ISNULL(COUNT(*), 0)
        FROM AddressXClient A
        WHERE A.ClientId = dbo.Checks.ClientId)
      CountAddressClient
     ,(SELECT
          ISNULL(COUNT(*), 0)
        FROM AddressXMaker AM
        WHERE AM.MakerId = dbo.Makers.MakerId)
      CountAddressMaker
     ,a.Address ClientAddress
     ,a.City ClientCity
     ,a.State ClientState
     ,a.ZipCode ClientZipCode
     ,dsc.DocumentStatusId ClientStatusId
     ,dsc.Code ClientStatusCode
     ,ds.DocumentStatusId CheckStatusId
     ,ds.Code CheckStatusCode,
    --am.Address MakerAddress, 
    --am.City MakerCity, 
    --am.State MakerState, 
    --am.ZipCode MakerZipCode
     'CHECK' AS IsSection,
      dbo.Makers.FileNumber AS FileNumber
    FROM dbo.Checks
    INNER JOIN dbo.Cashiers
      ON dbo.Checks.CashierId = dbo.Cashiers.CashierId
    INNER JOIN dbo.Clientes
      ON dbo.Checks.ClientId = dbo.Clientes.ClienteId
    INNER JOIN dbo.Users
      ON dbo.Clientes.UsuarioId = dbo.Users.UserId
    INNER JOIN dbo.Users AS Users_1
      ON dbo.Cashiers.UserId = Users_1.UserId
    INNER JOIN dbo.Makers
      ON dbo.Checks.Maker = dbo.Makers.MakerId
    INNER JOIN dbo.Agencies
      ON dbo.Checks.AgencyId = dbo.Agencies.AgencyId
    INNER JOIN dbo.CheckTypes
      ON dbo.Checks.CheckTypeId = dbo.CheckTypes.CheckTypeId
    LEFT JOIN Routings r
      ON dbo.Checks.Routing = r.Number
    LEFT JOIN AddressXClient A
      ON A.ClientId = dbo.Checks.ClientId
    LEFT JOIN DocumentStatus ds
      ON ds.DocumentStatusId = Checks.CheckStatusId
    LEFT JOIN DocumentStatus dsc
      ON dsc.DocumentStatusId = dbo.Clientes.ClientStatusId

    --LEFT JOIN AddressXMaker AM ON AM.MakerId = dbo.Makers.MakerId
    LEFT OUTER JOIN dbo.Users AS Users_2
      ON dbo.Checks.ValidatedBy = Users_2.UserId
    WHERE Checks.ClientId =
    CASE
      WHEN @ClientId IS NULL THEN Checks.ClientId
      ELSE @ClientId
    END
    AND Checks.Maker =
    CASE
      WHEN @MakerId IS NULL THEN Checks.Maker
      ELSE @MakerId
    END
    --AND Account LIKE CASE
    --                     WHEN @Account IS NULL
    --                     THEN Account
    --                     ELSE 
    --                 END
    -- and	case @LikeAccount
    --when @LikeAccount 
    --then (Account LIKE  '%'+@Account+'%')
    --else  Account = @Account
    --end

    AND (
    --@Account LIKE '%' + @Account + '%'
    --              --AND @LikeAccount = 1
    --              OR @LikeAccount = 0
    --              AND
    Account = @Account
    OR @Account IS NULL)
    AND Checks.AgencyId =
    CASE
      WHEN @AgencyId IS NULL THEN Checks.AgencyId
      ELSE @AgencyId
    END
    AND CAST(DateCashed AS DATE) >=
    CASE
      WHEN @StartDate IS NULL THEN CAST(DateCashed AS DATE)
      ELSE CAST(@StartDate AS DATE)
    END
    AND CAST(DateCashed AS DATE) <=
    CASE
      WHEN @EndDate IS NULL THEN CAST(DateCashed AS DATE)
      ELSE CAST(@EndDate AS DATE)
    END
    AND (dbo.Checks.Number = @CheckNumber
    OR @CheckNumber IS NULL
    OR @CheckNumber = '')
    AND CheckTypes.CheckTypeId =
    CASE
      WHEN @CheckTypeId IS NULL THEN CheckTypes.CheckTypeId
      ELSE @CheckTypeId
    END AND dbo.Checks.Routing = @Routing OR @Routing is NULL
  END

  ELSE -- returned checks 

IF EXISTS (SELECT TOP 1
        *
     
         FROM ReturnedCheck c
      WHERE c.CheckNumber = @CheckNumber
      AND c.Account = @Account
      AND c.Routing = @Routing)
  BEGIN



    SELECT TOP 1
      NULL CheckId
     , -- no hay checkid
      dbo.ReturnedCheck.ClientId
     ,dbo.ReturnedCheck.CreatedBy AS CashierId
     ,dbo.ReturnedCheck.CreationDate AS DateCashed
     ,dbo.ReturnedCheck.MakerId
     ,dbo.ReturnedCheck.USD Amount
     ,dbo.ReturnedCheck.Fee
     ,dbo.ReturnedCheck.CheckNumber AS Number
     ,dbo.ReturnedCheck.Account
     ,dbo.ReturnedCheck.Routing
     ,dbo.ReturnedCheck.CheckDate AS DateCheck
     ,dbo.Users.Name AS Cliente
     ,dbo.Users.UserId
     ,dbo.Users.Telephone TelephoneClient
     ,Users_1.Name AS Cashier
     ,dbo.Agencies.Name AS Agency
     ,dbo.Makers.Name AS MakerName
     ,dbo.Makers.MakerId
     ,'' AS CheckType
     ,dbo.ReturnedCheck.LastModifiedBy AS ValidatedBy
     ,Users_2.Name AS ValidatedByName
     ,r.BankName
     ,r.RoutingId
     ,(SELECT
          ISNULL(COUNT(*), 0)
        FROM AddressXClient A
        WHERE A.ClientId = dbo.ReturnedCheck.ClientId)
      CountAddressClient
     ,(SELECT
          ISNULL(COUNT(*), 0)
        FROM AddressXMaker AM
        WHERE AM.MakerId = dbo.Makers.MakerId)
      CountAddressMaker
     ,a.Address ClientAddress
     ,a.City ClientCity
     ,a.State ClientState
     ,a.ZipCode ClientZipCode
     ,0 ClientStatusId
     ,'' ClientStatusCode
     ,0 CheckStatusId
     ,'' CheckStatusCode,
       'RETURNCHECK' AS IsSection,
     dbo.Makers.FileNumber as  FileNumber
FROM dbo.ReturnedCheck
    INNER JOIN dbo.Cashiers
      ON dbo.ReturnedCheck.CreatedBy = dbo.Cashiers.UserId -- no hay cashier id
    INNER JOIN dbo.Clientes
      ON dbo.ReturnedCheck.ClientId = dbo.Clientes.ClienteId
    INNER JOIN dbo.Users
      ON dbo.Clientes.UsuarioId = dbo.Users.UserId

    INNER JOIN dbo.Users AS Users_1
      ON dbo.Cashiers.UserId = Users_1.UserId

    INNER JOIN dbo.Makers
      ON dbo.ReturnedCheck.MakerId = dbo.Makers.MakerId
    INNER JOIN dbo.Agencies
      ON dbo.ReturnedCheck.ReturnedAgencyId = dbo.Agencies.AgencyId
    LEFT JOIN Routings r
      ON dbo.ReturnedCheck.Routing = r.Number
    LEFT JOIN AddressXClient A
      ON A.ClientId = dbo.ReturnedCheck.ClientId
    --             LEFT JOIN DocumentStatus ds ON ds.DocumentStatusId = Checks.CheckStatusId 
    --             LEFT JOIN DocumentStatus dsc ON dsc.DocumentStatusId = dbo.Clientes.ClientStatusId
    LEFT OUTER JOIN dbo.Users AS Users_2
      ON dbo.ReturnedCheck.LastModifiedBy = Users_2.UserId
    WHERE dbo.ReturnedCheck.ClientId =
    CASE
      WHEN @ClientId IS NULL THEN dbo.ReturnedCheck.ClientId
      ELSE @ClientId
    END
    AND dbo.ReturnedCheck.MakerId =
    CASE
      WHEN @MakerId IS NULL THEN dbo.ReturnedCheck.MakerId
      ELSE @MakerId
    END
    AND (

    Account = @Account
    OR @Account IS NULL)
    AND dbo.ReturnedCheck.ReturnedAgencyId =
    CASE
      WHEN @AgencyId IS NULL THEN dbo.ReturnedCheck.ReturnedAgencyId
      ELSE @AgencyId
    END
    AND CAST(dbo.ReturnedCheck.CreationDate AS DATE) >=
    CASE
      WHEN @StartDate IS NULL THEN CAST(dbo.ReturnedCheck.CreationDate AS DATE)
      ELSE CAST(@StartDate AS DATE)
    END
    AND CAST(dbo.ReturnedCheck.CreationDate AS DATE) <=
    CASE
      WHEN @EndDate IS NULL THEN CAST(dbo.ReturnedCheck.CreationDate AS DATE)
      ELSE CAST(@EndDate AS DATE)
    END
    AND (dbo.ReturnedCheck.CheckNumber = @CheckNumber
    OR @CheckNumber IS NULL
    OR @CheckNumber = '') AND dbo.ReturnedCheck.Routing = @Routing OR @Routing is NULL


  END;

ELSE
BEGIN -- check els

--SELECT 
--      NULL CheckId
--     , -- no hay checkid
--      NULL ClientId
--     ,ce.CreatedBy AS CashierId
--     ,ce.CreationDate AS DateCashed
--     ,ce.MakerId
--     ,ce.Amount
--     ,ce.Fee
--     ,ce.CheckNumber AS Number
--     ,ce.Account
--     ,ce.Routing
--     ,ce.CheckDate AS DateCheck
--     ,NULL Cliente
--     ,NULL UserId
--     ,NULL TelephoneClient
--     ,Users_1.Name AS Cashier
--     ,dbo.Agencies.Name AS Agency
--     ,dbo.Makers.Name AS MakerName
--     ,dbo.Makers.MakerId
--     ,'' AS CheckType
--     ,ce.LastUpdatedBy AS ValidatedBy
--     ,Users_2.Name AS ValidatedByName
--     ,r.BankName
--     ,r.RoutingId
--     ,NULL CountAddressClient
--     ,NULL CountAddressMaker
--     ,NULL ClientAddress
--     ,NULL ClientCity
--     ,NULL ClientState
--     ,NULL ClientZipCode
--     ,0 ClientStatusId
--     ,'' ClientStatusCode
--     ,0 CheckStatusId
--     ,'' CheckStatusCode,
--    cast(1 AS bit) AS IsReturnedcheck
-- FROM dbo.ChecksEls ce
-- 
--
--    INNER JOIN dbo.Users AS Users_1
--      ON ce.CreatedBy = Users_1.UserId
--
--    INNER JOIN dbo.Makers
--      ON ce.MakerId = dbo.Makers.MakerId
--    INNER JOIN dbo.Agencies
--      ON ce.AgencyId= dbo.Agencies.AgencyId
--    LEFT JOIN Routings r
--      ON ce.Routing = r.Number
----    LEFT JOIN AddressXClient A
----      ON A.ClientId = dbo.ReturnedCheck.ClientId
--    --             LEFT JOIN DocumentStatus ds ON ds.DocumentStatusId = Checks.CheckStatusId 
--    --             LEFT JOIN DocumentStatus dsc ON dsc.DocumentStatusId = dbo.Clientes.ClientStatusId
--    LEFT OUTER JOIN dbo.Users AS Users_2
--      ON ce.LastUpdatedBy = Users_2.UserId
--    WHERE 
--    ce.MakerId =
--    CASE
--      WHEN @MakerId IS NULL THEN ce.MakerId
--      ELSE @MakerId
--    END
--    AND (
--
--    ce.Account = @Account
--    OR @Account IS NULL)
--    AND ce.AgencyId =
--    CASE
--      WHEN @AgencyId IS NULL THEN ce.AgencyId
--      ELSE @AgencyId
--    END
--    AND CAST(ce.CreationDate AS DATE) >=
--    CASE
--      WHEN @StartDate IS NULL THEN CAST(ce.CreationDate AS DATE)
--      ELSE CAST(@StartDate AS DATE)
--    END
--    AND CAST(ce.CreationDate AS DATE) <=
--    CASE
--      WHEN @EndDate IS NULL THEN CAST(ce.CreationDate AS DATE)
--      ELSE CAST(@EndDate AS DATE)
--    END
--    AND (ce.CheckNumber = @CheckNumber
--    OR @CheckNumber IS NULL
--    OR @CheckNumber = '') AND ce.Routing = @Routing OR @Routing is NULL

SELECT
      NULL CheckId
     , -- no hay checkid
      NULL ClientId
     ,ce.CreatedBy AS CashierId
     ,ce.CreationDate AS DateCashed
     ,ce.MakerId
     ,ce.Amount
     ,ce.Fee
     ,ce.CheckNumber AS Number
     ,ce.Account
     ,ce.Routing
     ,ce.CheckDate AS DateCheck
--     ,NULL Cliente
     ,NULL UserId
     ,NULL TelephoneClient
     ,Users.Name AS Cashier
     ,dbo.Agencies.Name AS Agency
        ,dbo.Makers.Name AS MakerName
--     ,dbo.Makers.MakerId
     ,'' AS CheckType
     ,ce.LastUpdatedBy AS ValidatedBy
     ,Users_2.Name AS ValidatedByName
     ,r.BankName
     ,r.RoutingId
     ,0 CountAddressClient
     ,0 CountAddressMaker
     ,NULL ClientAddress
     ,NULL ClientCity
     ,NULL ClientState
     ,NULL ClientZipCode
     ,0 ClientStatusId
     ,'' ClientStatusCode
     ,0 CheckStatusId
     ,'' CheckStatusCode,
         'CHECKELS' AS IsSection,
         dbo.Makers.FileNumber AS FileNumber



 FROM ChecksEls ce
 INNER JOIN dbo.Users AS Users ON ce.CreatedBy = Users.UserId
 INNER JOIN dbo.Agencies ON ce.AgencyId= dbo.Agencies.AgencyId
 LEFT OUTER JOIN dbo.Users AS Users_2 ON ce.LastUpdatedBy = Users_2.UserId
  LEFT JOIN Routings r ON ce.Routing = r.Number
   left JOIN dbo.Makers ON ce.MakerId = dbo.Makers.MakerId
WHERE ce.Account = @Account AND ce.CheckNumber = @CheckNumber AND ce.Routing = @Routing

END

END;


GO