SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Nombre:  sp_GetFraudAlert				    															         
-- Descripcion: Procedimiento Almacenado que consulta los fraud alerts.				    					         
-- Creado por: 	JOHAN																			 
-- Fecha: 		17-05-2023																							 	
-- Modificado por: Diego León Acevedo Arenas																										 
-- Fecha: 2023-08-03																											 
-- Observación:  Consulta los fraud alerts por account, NumberRouting, CheckNumber, ClientName, Telephone, Address
-- Test: EXECUTE [dbo].[sp_GetFraudAlert] @Account = '8484', @Routing = '011001234', @CheckNumber = '84848', @ClientName = 'TEST  NEW C', @Telephone = '3225099025', @Address = 'CALLE 13', @ClientId = 1405, @Maker = 'PANAMERICANA', @FileNumber = ''                              
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[sp_GetFraudAlert] @Account VARCHAR(50) = NULL,
@Routing VARCHAR(15) = NULL,
@CheckNumber VARCHAR(50) = NULL,
@ClientName VARCHAR(50) = NULL,
@Telephone VARCHAR(20) = NULL,
@Address VARCHAR(100) = NULL,
--@ClientId INT = NULL,
@Doc1Number VARCHAR(100) = NULL,
@Doc2Number VARCHAR(100) = NULL,
@Maker VARCHAR(80) = NULL,
@FileNumber VARCHAR(20) = NULL

AS
BEGIN
  SELECT
  fa.IsNotFraud,
    fa.FraudId
   ,fa.TransactionDate
   ,FORMAT(fa.TransactionDate, 'MM-dd-yyyy', 'en-US') TransactionDateFormat
   ,
    --fa.TransactionNumber,
    fa.ClientName
   ,CASE
      WHEN (fa.ClientName = @ClientName AND
        @ClientName IS NOT NULL) THEN CAST(1 AS BIT)
      ELSE CAST(0 AS BIT)
    END AS HasCoincidenceClientName
   ,fa.Maker
   ,CASE
      WHEN (fa.Maker = @Maker AND
        @Maker IS NOT NULL) THEN CAST(1 AS BIT)
      ELSE CAST(0 AS BIT)
    END AS HasCoincidenceMaker
   ,fa.FileNumber
   ,CASE
      WHEN (fa.FileNumber = @FileNumber AND
        @FileNumber IS NOT NULL) THEN CAST(1 AS BIT)
      ELSE CAST(0 AS BIT)
    END AS HasCoincidenceFileNumber
   ,fa.Account
   ,
    --If  the account is registered by safe in CheckFraudExceptions table with the same maker, then this case mean that the account and maker are not a coincidence for alert fraud
    --CASE WHEN (fa.Account = @Account AND @Account NOT IN(SELECT Account FROM CheckFraudExceptions WHERE IsSafe = 1) AND @Account IS NOT NULL)
    CASE
      WHEN (fa.Account = @Account AND
        @Account IS NOT NULL) THEN CAST(1 AS BIT)
      ELSE CAST(0 AS BIT)
    END AS HasCoincidenceAccount
   ,fa.NumberRouting AS Routing
   ,fa.CheckNumber
   ,CASE
      WHEN (fa.CheckNumber = @CheckNumber AND
        @CheckNumber IS NOT NULL) THEN CAST(1 AS BIT)
      ELSE CAST(0 AS BIT)
    END AS HasCoincidenceCheckNumber
   ,fa.Telephone
   ,CASE
      WHEN (fa.Telephone = @Telephone AND
        @Telephone IS NOT NULL) THEN CAST(1 AS BIT)
      ELSE CAST(0 AS BIT)
    END AS HasCoincidenceTelephone
   ,fa.ClientAddress
   ,CASE
      WHEN (fa.ClientAddress = @Address AND
        @Address IS NOT NULL) THEN CAST(1 AS BIT)
      ELSE CAST(0 AS BIT)
    END AS HasCoincidenceClientAddress
   ,fa.IdentificacionNumber
   ,CASE
      WHEN (fa.IdentificacionNumber = @Doc1Number AND
        @Doc1Number IS NOT NULL) OR
        (fa.IdentificacionNumber = @Doc2Number AND
        @Doc2Number IS NOT NULL) THEN CAST(1 AS BIT)
      ELSE CAST(0 AS BIT)
    END AS HasCoincidenceIdentificacionNumber
   ,fa.StateAbreviation
   ,UPPER(ux.State) AS State
  --fa.ClientId
  FROM [dbo].[FraudAlert] fa
  JOIN UrlsXState ux ON fa.[StateAbreviation ] = ux.StateAbre
  WHERE ((fa.ClientName = @ClientName
  AND @ClientName IS NOT NULL)
  OR (fa.Telephone = @Telephone
  AND @Telephone IS NOT NULL)
  OR (fa.ClientAddress = @Address
  AND @Address IS NOT NULL)
  OR (fa.IdentificacionNumber = @Doc1Number
  AND @Doc1Number IS NOT NULL)
  OR (fa.IdentificacionNumber = @Doc2Number
  AND @Doc2Number IS NOT NULL))
  OR
  --TASK 5423 La cuenta y el maker se entienden como combinación segura, justamente cuando esta mismá combinación está en la tabla  CheckFraudExceptions marcada como segura
  (fa.Account = @Account
  AND ((@Maker IS NOT NULL
  AND (@Account NOT IN (SELECT
      Account
    FROM CheckFraudExceptions CF
    WHERE CF.IsSafe = 1
    AND CF.Maker = @Maker
    AND CF.Account = @Account)
  AND (fa.IsNotFraud = CAST(0 AS BIT)
  OR fa.IsNotFraud IS NULL))
  )
  OR @Maker IS NULL))
  OR (fa.Maker = @Maker
  AND ((@Account IS NOT NULL
  AND (@Maker NOT IN (SELECT
      Maker
    FROM CheckFraudExceptions CF
    WHERE CF.IsSafe = 1
    AND CF.Maker = @Maker
    AND CF.Account = @Account)
  AND (fa.IsNotFraud = CAST(0 AS BIT)
  OR fa.IsNotFraud IS NULL))
  )
  OR @Account IS NULL))
  OR (fa.CheckNumber = @CheckNumber
  AND @CheckNumber IS NOT NULL)
  OR
  --(fa.Maker = @Maker AND @Maker IS NOT NULL) OR 
  (fa.FileNumber = @FileNumber
  AND (fa.IsNotFraud = CAST(0 AS BIT)
  OR fa.IsNotFraud IS NULL)
  AND @FileNumber IS NOT NULL)

END;
GO