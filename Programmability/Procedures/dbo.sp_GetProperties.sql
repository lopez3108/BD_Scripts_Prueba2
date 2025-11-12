SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Returns properties list
-- =============================================

-- 2024-07-24 DJ/5973: Adding column ZelleEmail

-- =============================================
-- Author:      sa
-- Create date: 4/09/2024 4:13 p. m.
-- Database:    developing
-- Description: task 6042 Ajustes formulario property
-- =============================================

-- 2025-05-22 DJ/6522: Crear seccion Insurance companies en el modulo Settings de los Properties
-- 2025-06-19 DJ/6592: MODULO PROPIEDADES - URL DETAILS PROPERTIES - SENT 05-27-2025

CREATE PROCEDURE [dbo].[sp_GetProperties] @CurrentDate DATETIME, 
                                         @Code        VARCHAR(5) = NULL,
										 @Name       VARCHAR(40) = NULL
AS
    BEGIN
        SELECT *
        FROM
        (
            SELECT dbo.Properties.PropertiesId, 
                   dbo.Properties.Name, 
                   dbo.Properties.Address, 
                   dbo.Properties.Zipcode, 
                   UPPER(dbo.Properties.City) AS City, 
                   UPPER(dbo.Properties.State) AS State, 
                   dbo.Properties.PropertyValue, 
                   dbo.Properties.PurchaseDate,
                   dbo.Properties.TrustNumber, 
                   dbo.Properties.TrustCompany,
				   FORMAT(Properties.PurchaseDate, 'MM-dd-yyyy', 'en-US')  PurchaseDateFormat,
                   dbo.Properties.PIN, 
                   dbo.Properties.InsuranceContactName, 
                   dbo.Properties.InsuranceContactTelephone, 
            (
                SELECT COUNT(1) AS Expr1
                FROM dbo.Apartments
                WHERE(PropertiesId = dbo.Properties.PropertiesId)
            ) AS NumberApartments, 
                   ISNULL(dbo.Insurance.Name, 'NO INSURANCE') AS Insurance, 
                   dbo.Properties.Telephone, 
                   dbo.Properties.PolicyNumber AS PolicyNumber, 
                   dbo.Properties.PolicyStartDate, 
				   FORMAT(Properties.PolicyStartDate, 'MM-dd-yyyy', 'en-US')  PolicyStartDateFormat,
                   dbo.Properties.PolicyEndDate,
				   FORMAT(Properties.PolicyEndDate, 'MM-dd-yyyy', 'en-US')  PolicyEndDateFormat,
                   dbo.Properties.PersonInCharge, 
                   UPPER(dbo.Properties.County) AS County, 
                   dbo.Properties.InsuranceContactTelephone AS Expr1, 
                   dbo.Properties.InsuranceContactName AS Expr2, 
                   dbo.Insurance.InsuranceId,
                   CASE
                       WHEN DATEDIFF(DAY, CAST(@CurrentDate AS DATE), CAST(dbo.Properties.PolicyEndDate AS DATE)) > 0
                       THEN DATEDIFF(DAY, CAST(@CurrentDate AS DATE), CAST(dbo.Properties.PolicyEndDate AS DATE))
                       ELSE 0
                   END AS PolicyDaysLeft, 
                   ISNULL(dbo.Properties.BillNumber, 'NOT REGISTERED') AS BillNumber, 
                   dbo.Properties.PersonInChargeTelephone, 
                   dbo.Properties.CreationDate, 
				   FORMAT(Properties.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
                   dbo.Properties.CreatedBy, 
				     dbo.Properties.AddressCorporation, 
					   dbo.Properties.EmailCorporation, 
                   UPPER(dbo.Users.Name) AS CreatedByName,
                    CASE
      WHEN dbo.Properties.BillNumber IS NOT NULL AND LEN(dbo.Properties.BillNumber) > 2   THEN CAST(1 AS BIT)

      ELSE CAST(0 AS BIT)

    END AS HasBillNumber,
    case
      WHEN dbo.Insurance.Name IS NOT NULL AND LEN(dbo.Insurance.Name) > 2   THEN CAST(1 AS BIT)

      ELSE CAST(0 AS BIT)

    END AS HasInsurance,
    Zelle,
	ZelleEmail,
    ba.AccountNumber,
dbo.Properties.BankAccountId,

dbo.Bank.BankId, 
dbo.Bank.Name AS BankName ,

  '***' +' '+ ba.AccountNumber +' '+ '('+ dbo.Bank.Name + ')' AS BankAndAccount,
  dbo.Insurance.Telephone as InsuranceCompanyTelephone,
  dbo.Insurance.URL

            FROM dbo.Properties
                 LEFT OUTER JOIN dbo.Users ON dbo.Properties.CreatedBy = dbo.Users.UserId
                 LEFT OUTER JOIN dbo.Insurance ON dbo.Properties.InsuranceId = dbo.Insurance.InsuranceId
                 LEFT OUTER JOIN dbo.BankAccounts ba ON dbo.Properties.BankAccountId = ba.BankAccountId
                 LEFT JOIN dbo.Bank ON ba.BankId = dbo.Bank.BankId
        ) QUERY
        WHERE((@Code = 'C01'
               AND QUERY.PolicyDaysLeft < 0)
              OR (@Code = 'C01'
                  AND QUERY.PolicyDaysLeft <= 30
                  AND QUERY.PolicyDaysLeft >= 0)
              OR (@Code IS NULL))
       AND (@Name IS NULL OR QUERY.Name LIKE '%' + @Name + '%')
        ORDER BY QUERY.Name;
    END;





GO