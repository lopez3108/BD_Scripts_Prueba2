SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- Last modification: se agrega un in para el check box de la agencia en kyc-forms
-- by: sergio
-- date: 08/05/2024

CREATE PROCEDURE [dbo].[sp_GetKycxProviderxAgency] @ProviderId VARCHAR(500) = NULL,
@AgencyId VARCHAR(500) = NULL,
@StartDate DATETIME = NULL,
@EndDate DATETIME = NULL,
@OrderNumber VARCHAR(15) = NULL,
@ClientName VARCHAR(40) = NULL,
@GetFiles BIT = NULL,
@UserId INT = NULL,
@Date DATETIME
AS
BEGIN
  DECLARE @PrimeraFecha DATETIME;
  DECLARE @UltimaFecha DATETIME;
  SET NOCOUNT ON;
  SELECT TOP (1)
    @PrimeraFecha = CreationDate
  FROM dbo.Kyc
  ORDER BY CreationDate ASC;
  SELECT TOP (1)
    @UltimaFecha = CreationDate
  FROM dbo.Kyc
  ORDER BY CreationDate DESC;
  SET NOCOUNT OFF;
  --IF(@AgencyId IS NOT NULL) -- CAJERO
  BEGIN


    IF (@GetFiles IS NULL
      OR @GetFiles = CAST(0 AS BIT))
    BEGIN


      SELECT DISTINCT
        k.AgencyId
       ,(SELECT
            CreationDate
          FROM dbo.FN_GetKycCreationInformation(k.ProviderId, k.OrderNumber))
        AS CreationDate
       ,(SELECT
            UserName
          FROM dbo.FN_GetKycCreationInformation(k.ProviderId, k.OrderNumber))
        AS CreatedByName
       ,(SELECT
            LastUpdatedBy
          FROM dbo.FN_GetKycCreationInformation(k.ProviderId, k.OrderNumber))
        AS LastUpdatedBy
       ,(SELECT
            LastUpdatedOn
          FROM dbo.FN_GetKycCreationInformation(k.ProviderId, k.OrderNumber))
        AS LastUpdatedOn
       ,(SELECT
            COUNT(*)
          FROM dbo.Kyc ky
          WHERE ky.ProviderId = k.ProviderId
          AND ky.OrderNumber = k.OrderNumber)
        AS NumberFiles
       ,k.ProviderId
       ,OrderNumber
       ,ClientName
       ,p.Name AS ProviderName
       ,UPPER(A.Code + ' - ' + A.Name) AgencyName
       ,k.Usd
       ,CAST(1 AS BIT) AS IsSaved
       ,CAST(0 AS BIT) AS IsModify
       ,CASE
          WHEN
            CAST((SELECT
                CreationDate
              FROM dbo.FN_GetKycCreationInformation(k.ProviderId, k.OrderNumber))
            AS DATE) <> CAST(@Date AS DATE) THEN CAST(0 AS BIT)
          ELSE CAST(1 AS BIT)
        END AS CanDelete
      FROM dbo.Kyc k
      INNER JOIN dbo.Providers p
        ON p.ProviderId = k.ProviderId
      INNER JOIN Agencies A
        ON A.AgencyId = k.AgencyId

      WHERE ((k.ProviderId IN (SELECT
          item
        FROM dbo.FN_ListToTableInt(@ProviderId))
      OR @ProviderId IS NULL))

      AND

      ((k.AgencyId IN (SELECT
          item
        FROM dbo.FN_ListToTableInt(@AgencyId))
      OR @AgencyId IS NULL))


      AND (k.OrderNumber = @OrderNumber
      OR @OrderNumber IS NULL)
      AND (k.ClientName LIKE '%' + @ClientName + '%'
      OR @ClientName IS NULL)
--      AND (k.AgencyId = @AgencyId
--      OR @AgencyId IS NULL)
      AND ((SELECT
          UserId
        FROM dbo.FN_GetKycCreationInformation(k.ProviderId, k.OrderNumber))
      = @UserId
      OR @UserId IS NULL)
      AND ((CAST(k.CreationDate AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(k.CreationDate AS DATE) <= CAST(@EndDate AS DATE))
      OR @EndDate IS NULL)
      GROUP BY k.AgencyId
              ,k.ProviderId
              ,OrderNumber
              ,ClientName
              ,p.Name
              ,CreationDate
              ,k.LastUpdatedOn
              ,A.Code
              ,A.Name
              ,k.Usd
      ORDER BY p.Name,
      AgencyId,
      CreationDate DESC,
      OrderNumber,
      ClientName

    END

    ELSE

    BEGIN

      SELECT
        k.KycId
       ,k.AgencyId
       ,k.ProviderId
       ,k.OrderNumber
       ,k.ClientName
       ,k.CreationDate
       ,k.LastUpdatedOn
       ,k.UserId AS CreatedBy
       ,u.Name AS CreatedByName
       ,up.Name AS LastUpdatedBy
       ,k.Name
       ,k.Extension
       ,k.Base64
       ,UPPER(A.Code + ' - ' + A.Name) AgencyName
       ,k.Usd
       ,CAST(1 AS BIT) AS IsSaved
       ,CAST(0 AS BIT) AS IsModify
       ,CASE
          WHEN
            CAST(k.CreationDate AS DATE) <> CAST(@Date AS DATE) THEN CAST(0 AS BIT)
          ELSE CAST(1 AS BIT)
        END AS CanDelete
      FROM dbo.Kyc k
      INNER JOIN dbo.Users u
        ON k.UserId = u.UserId
      LEFT JOIN dbo.Users up
        ON k.LastUpdatedBy = up.UserId
      INNER JOIN Agencies A
        ON A.AgencyId = k.AgencyId
      WHERE ((k.ProviderId IN (SELECT
          item
        FROM dbo.FN_ListToTableInt(@ProviderId))
      ))
      AND (k.OrderNumber = @OrderNumber)
      ORDER BY k.CreationDate ASC;



    END



  END;

END;

GO