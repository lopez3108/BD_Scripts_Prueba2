SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created by Juan Felipe Oquendo lopez..
--17-Mayo-2023  Task 5067 Icono Check Fraud Alerts ..

CREATE PROCEDURE [dbo].[sp_GetAllCheckFraudAlert] (@FraudId INT)
AS
BEGIN

  SELECT
    fa.FraudId
   ,FORMAT(fa.TransactionDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') TransactionDateFormat
   ,fa.ClientName
   ,fa.Maker
   ,fa.CheckType
   ,fa.FileNumber
   ,fa.MakerAddress
   ,fa.NumberRouting
   ,fa.Account
   ,fa.CheckNumber
   ,fa.Telephone
   ,fa.ClientAddress
   ,fa.DOB
   ,FORMAT(fa.DOB, 'MM-dd-yyyy', 'en-US') DOBFormat
   ,fa.Country
   ,fa.IdentificacionNumber AS NumberId
   ,fa.CreationDate
   ,FORMAT(fa.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
   ,fa.CreatedName
   ,fa.LastUpdatedOn
   ,FORMAT(fa.LastUpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') LastUpdatedOnFormat
   ,
    --                           
    fa.LastUpdatedName
   ,fa.AgencyName
   ,fa.AgencyId
   ,fa.State
   ,fa.StateAbreviation
   ,fa.BankName
   ,fa.CreatedBy
   ,fa.Foto
   ,fa.IsNotFraud
   ,(SELECT TOP 1
        IsSafe
      FROM CheckFraudExceptions AS ce
      WHERE ce.Account = fa.Account
      AND ce.Maker = fa.Maker)
    AS IsAccountSafe
   ,(SELECT TOP 1
        CheckFraudExceptionId
      FROM CheckFraudExceptions AS ce
      WHERE ce.Account = fa.Account
      AND ce.Maker = fa.Maker)
    AS CheckFraudExceptionId
  --				  CASE
  --				 WHEN ce.CheckFraudExceptionId IS NOT NULL AND CAST(ce.IsSafe as BIT)  = CAST(1 as BIT) THEN 
  --				 CAST(1 as BIT) ELSE
  --				 CAST(0 as BIT) END AS IsAccountSafe,
  --				 CASE
  --				 WHEN ce.CheckFraudExceptionId IS NOT NULL THEN 
  --				 ce.CheckFraudExceptionId ELSE
  --				 NULL END AS CheckFraudExceptionId
  FROM FraudAlert fa
  LEFT JOIN CheckFraudExceptions ce
    ON ce.Account = fa.Account
  WHERE (fa.FraudId = @FraudId)



  ORDER BY fa.TransactionDate DESC;



END;













GO