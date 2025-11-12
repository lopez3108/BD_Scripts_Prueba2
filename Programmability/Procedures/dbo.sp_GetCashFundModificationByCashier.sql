SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- Nombre:  sp_GetCashFundModificationByCashier				    															         
-- Descripcion: Procedimiento Almacenado que consulta los cash fund de un cajero	    					         
-- Creado por: 	JT																			 
-- Fecha: 		2-10-2023																							 	
-- Modificado por: JT																								 
-- Fecha: 2023-11-1																											 
-------------
CREATE PROCEDURE [dbo].[sp_GetCashFundModificationByCashier] 
@CashierId INT,
@CurrentDate AS DATE = NULL,
@IsReturned AS BIT = NULL
AS
BEGIN
  SELECT 
  ISNULL(CF.IsReturned, 0 ) IsReturned ,
  ISNULL(CF.IsReturned, 0 ) IsReturnedSaved ,
  CF.AgencyId,
  CF.AgencyId AgencyIdSaved,
  A.Code +' - '+ a.Name AgencyCodName,
  CF.CashFundModificationsId,CF.CashierId,CF.CreatedBy,CF.CreationDate,
  CF.CreditCashFund, -ABS(CF.DebitCashFund) DebitCashFund,
  CASE WHEN DebitCashFund IS NOT NULL AND DebitCashFund > 0  THEN
  CAST(1 AS bit)
  ELSE
  CAST(0 AS bit)
  END AcceptNegative,
  --'true' AcceptNegative,
  'true' [Set],
  CASE WHEN DebitCashFund IS NOT NULL AND DebitCashFund > 0 OR
  CAST(CF.CreationDate AS date) < CAST(@CurrentDate AS date) OR CF.IsReturned = 1 THEN
  CAST(1 AS bit)
  ELSE
  CAST(0 AS bit)
  END Disabled,
  CASE WHEN CreditCashFund IS NOT NULL AND CreditCashFund > 0
  THEN CreditCashFund
  ELSE -DebitCashFund
  END AS [Value],
    CASE WHEN CreditCashFund IS NOT NULL AND CreditCashFund > 0
  THEN CreditCashFund
  ELSE -DebitCashFund
  END AS ValueSaved,
  CASE WHEN CreditCashFund IS NOT NULL   AND CreditCashFund > 0
   THEN CreditCashFund
  ELSE -DebitCashFund
  END AS moneyvalue,
  U.Name UserNameCreate FROM [CashFundModifications] CF 
  INNER JOIN Users U ON CF.CreatedBy = U.UserId
  INNER JOIN Agencies A ON A.AgencyId = CF.AgencyId
  WHERE CF.CashierId = @CashierId AND 
  (CF.IsReturned = @IsReturned OR @IsReturned IS NULL)
END

GO