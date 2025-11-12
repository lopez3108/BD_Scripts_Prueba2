SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      JF
-- Create date: 11/08/2024 5:41 p. m.
-- Database:    developing
-- Description: task 5421 Ajustes TRP (TO DO punto 1)
-- =============================================

CREATE PROCEDURE [dbo].[sp_GetTRP] @PermitNumber VARCHAR(20) = NULL,
@PermitTypeId INT = NULL,
@ClientName VARCHAR(70) = NULL,
@Telephone VARCHAR(10) = NULL,
@ProcessStatusCode VARCHAR(10) = NULL,
@UserId INT = NULL,
@AgencyId INT = NULL,
@FromDate DATE = NULL,
@ToDate DATE = NULL,
@VinNumber VARCHAR(17) = NULL,
@Paid BIT = NULL
AS
BEGIN
  SELECT
    ISNULL(TRP.LaminationFee, 0) LaminationFee
   ,*
   ,dbo.TRP.FileIdNamePermit AS FileIdNameEls
   ,dbo.TRP.PermitNumber AS PermitNumberSaved
   ,dbo.PermitTypes.Description
   ,uL.Name AS UpdatedByName
   ,uc.Name AS CreatedByName
   ,ISNULL(TRP.LaminationFee, 0) LaminationFee1
   ,c.CashierId
   ,a.Code + ' - ' + a.Name AS Agency
   ,dbo.TRP.Telephone AS TelephoneSaved
   ,ISNULL(TRP.TelIsCheck, CAST(0 AS BIT)) TelIsCheck
   ,dbo.TRP.VinNumber AS VinNumberSaved
   ,v.Code AS VinCodeSaved
   ,
    --          convert(varchar, trp.CreatedOn, 22)	CreatedOn 
    FORMAT(dbo.TRP.CreatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreatedOnFormat
   ,FORMAT(dbo.TRP.UpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') UpdatedOnFormat
   ,FORMAT(dbo.TRP.PaymentDate, 'MM-dd-yyyy', 'en-US') PaymentDateFormat
   ,CAST(dbo.TRP.Paid AS BIT) AS Paid
   ,up.Name AS PaidByName
   ,CASE
      WHEN dbo.TRP.Paid = 1 THEN 'PAID'
      ELSE 'PENDING PAYMENT'
    END AS PermitPayment
   ,FORMAT(IdExpirationDate, 'MM-dd-yyyy', 'en-US') IdExpirationDateFormat

   , CASE WHEN EXISTS (
                SELECT 1
                FROM TRP t               
                WHERE t.PermitNumber = sx.SerialNumber
            ) THEN CAST(1 as BIT)
            ELSE CAST(0 AS BIT)
        END AS SerialNumberExists

  FROM dbo.TRP
  LEFT JOIN dbo.PermitTypes  ON dbo.TRP.PermitTypeId = dbo.PermitTypes.PermitTypeId
  LEFT JOIN Users uL  ON uL.UserId = dbo.TRP.UpdatedBy
  LEFT JOIN Users uc ON uc.UserId = dbo.TRP.CreatedBy
  LEFT JOIN Users up ON up.UserId = dbo.TRP.PaidBy
  LEFT JOIN VinPertmitStatus v ON v.VinPertmitTrpId = dbo.TRP.VinPertmitTrpId
  INNER JOIN dbo.Cashiers c   ON c.UserId = uc.UserId
  INNER JOIN dbo.Agencies a  ON a.AgencyId = dbo.TRP.AgencyId
   LEFT JOIN SerialsXReturn sx ON TRP.PermitNumber = sx.SerialNumber

  WHERE (dbo.TRP.PermitNumber LIKE '%' + @PermitNumber + '%'
  OR @PermitNumber IS NULL)
  AND (dbo.TRP.ClientName LIKE '%' + @ClientName + '%'
  OR @ClientName IS NULL)
  AND (dbo.TRP.VinNumber LIKE '%' + @VinNumber + '%'
  OR @VinNumber IS NULL)
  AND (dbo.TRP.Telephone LIKE '%' + @Telephone + '%'
  OR @Telephone IS NULL)
  AND (dbo.TRP.PermitTypeId = @PermitTypeId
  OR @PermitTypeId IS NULL)
  AND (dbo.TRP.CreatedBy = @UserId
  OR @UserId IS NULL)
  AND (dbo.TRP.AgencyId = @AgencyId
  OR @AgencyId IS NULL)
  AND (CAST(dbo.TRP.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
  OR @FromDate IS NULL)
  AND (CAST(dbo.TRP.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
  OR @ToDate IS NULL)
  AND (((dbo.TRP.PermitNumber = ''
  OR dbo.TRP.PermitNumber IS NULL)
  OR (dbo.TRP.ClientName = ''
  OR dbo.TRP.ClientName IS NULL)
  OR (dbo.TRP.PermitTypeId <= 0
  OR dbo.TRP.PermitTypeId IS NULL)
  AND (@ProcessStatusCode = 'C01'))
  OR @ProcessStatusCode IS NULL)
  AND (dbo.TRP.Paid = @Paid
  OR @Paid IS NULL)
  ORDER BY dbo.TRP.CreatedOn ASC
END;

GO