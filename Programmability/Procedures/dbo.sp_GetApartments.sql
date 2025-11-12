SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Returns apartments list
-- =============================================

-- =============================================
-- Author:      JF
-- Create date: 4/09/2024 6:23 p. m.
-- Database:    developing
-- Description: task 6037  Ampliar los caracteres del campo apartment number
-- =============================================


CREATE PROCEDURE [dbo].[sp_GetApartments] @ApartmentsId INT = NULL,
@PropertiesId INT = NULL
AS
BEGIN

  SELECT DISTINCT
    CASE
      WHEN
        EXISTS (SELECT
            ContractId
          FROM dbo.Contract c
          WHERE c.ApartmentId = a.ApartmentsId
          AND c.Status = (SELECT
              ContractStatusId
            FROM ContractStatus
            WHERE Code = 'C01')) THEN (SELECT TOP 1
            ContractId
          FROM dbo.Contract c
          WHERE c.ApartmentId = a.ApartmentsId
          AND c.Status = (SELECT
              ContractStatusId
            FROM ContractStatus
            WHERE Code = 'C01'))
      ELSE NULL
    END AS ContractId
   ,a.ApartmentsId
   ,a.PropertiesId
   ,a.Number
   ,a.Bathrooms
   ,a.Bedrooms
   ,a.Description
   ,a.Size
   ,a.CreatedBy 
   ,u1.Name AS CreatedByName  
   ,FORMAT(a.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
   ,a.LastUpdatedBy
   ,u.Name AS LastUpdatedByName 
   ,FORMAT(a.LastUpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') UpdatedOnFormat
   ,dbo.Properties.Name AS Property
   ,CASE
      WHEN
        EXISTS (SELECT
            ContractId
          FROM dbo.Contract c
          WHERE c.ApartmentId = a.ApartmentsId
          AND c.Status = (SELECT
              ContractStatusId
            FROM ContractStatus
            WHERE Code = 'C01')) THEN 'YES'
      ELSE 'NO'
    END AS ActiveContract
   ,CASE
      WHEN
        EXISTS (SELECT 
            ContractId
          FROM dbo.Contract c
          WHERE c.ApartmentId = a.ApartmentsId
          AND c.Status = (SELECT
              ContractStatusId
            FROM ContractStatus
            WHERE Code = 'C01')) THEN CAST(1 AS BIT)
      ELSE CAST(0 AS BIT)
    END AS HasContract

  ,CASE
      WHEN
        EXISTS (SELECT 
            ContractId
          FROM dbo.Contract c
          WHERE c.ApartmentId = a.ApartmentsId
          AND c.Status = (SELECT
              ContractStatusId
            FROM ContractStatus
            WHERE Code = 'C01')) THEN CAST(1 AS BIT)
      ELSE CAST(0 AS BIT)
    END AS ExistingContract

   ,(SELECT
        [dbo].[fn_GetTenantsNames](a.ApartmentsId))
    TenantName
   ,dbo.Properties.ZipCode AS ZipCode
   ,ZipCodes.City
   ,ZipCodes.StateAbre AS State
   ,Properties.Address
   ,AddressCorporation
   ,EmailCorporation
   ,PersonInCharge
   ,PersonInChargeTelephone,


 dbo.Properties.Zelle,
        ba.FullAccount,
      dbo.Bank.Name AS BankNameProperty,
        dbo.AccountOwners.Name AS AccountOwnerName,  
         ba.AccountNumber,
         ba.BankAccountId





  FROM dbo.Apartments a
  INNER JOIN dbo.Properties
    ON a.PropertiesId = dbo.Properties.PropertiesId
  INNER JOIN ZipCodes
    ON ZipCodes.ZipCode = Properties.ZipCode

      LEFT JOIN dbo.BankAccountsXProviderBanks ON dbo.Properties.BankAccountId = dbo.BankAccountsXProviderBanks.BankAccountId
      LEFT JOIN dbo.AccountOwners ON dbo.BankAccountsXProviderBanks.AccountOwnerId = dbo.AccountOwners.AccountOwnerId
      LEFT OUTER JOIN dbo.BankAccounts ba ON dbo.Properties.BankAccountId = ba.BankAccountId
      LEFT JOIN dbo.Bank ON ba.BankId = dbo.Bank.BankId
      LEFT JOIN Users u ON a.LastUpdatedBy = u.UserId
      LEFT JOIN Users u1 ON a.CreatedBy = u1.UserId



  WHERE (a.ApartmentsId = @ApartmentsId
  OR @ApartmentsId IS NULL)
  AND (dbo.Properties.PropertiesId = @PropertiesId
  OR @PropertiesId IS NULL)
  ORDER BY a.Number ASC


END



GO