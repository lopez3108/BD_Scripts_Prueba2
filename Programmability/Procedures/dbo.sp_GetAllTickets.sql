SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Nombre:  sp_GetAllTickets				    															         
-- Descripcion: Procedimiento Almacenado que consulta todos los tickets.				    					         
-- Creado por: 																				 
-- Fecha: 																									 	
-- Modificado por: Diego León Acevedo Arenas																										 
-- Fecha: 2023-07-28																											 
-- Observación:  Se remueve el campo TicketDate, ClientAddress  
-- Test: EXECUTE [dbo].[sp_GetAllTickets] @Date = 1705                                      
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Juan Felipe 
--2 Mayo 2023

-- 20204-11-06 DJ/6127: Pay Tickets using ACH
-- 20204-11-28 LF/6229: Ajustes formulario traffic tickets
-- 20204-12-09 DJ/6234: Nuevo campo TRANSACTION FEE para los pagos ACH
-- 20204-02-20 JT/5939: Nuevo campo TransactionGuid
-- 20205-03-27 JT/6412: Nuevo campo ClientLanguage

-- 2025-07-31 DJ/6448 La columna TRANSACTION FEE no está ordenando la información

CREATE PROCEDURE [dbo].[sp_GetAllTickets] @TicketStatusId INT = NULL,
--@AgencyId       INT          = NULL,
@Date DATETIME = NULL,
@TicketNumber VARCHAR(30) = NULL,
@ClientName VARCHAR(70) = NULL,
@Telephone VARCHAR(12) = NULL,
@ListAgenciId VARCHAR(500) = NULL,
@TicketStatusCode VARCHAR(4) = NULL,
@UserId INT = NULL,
@ListCashierId VARCHAR(500) = NULL,
@DaysAlert INT = NULL,
@CurrentDate DATETIME = NULL
AS
BEGIN
  IF (@TicketStatusCode IS NOT NULL
    AND @TicketStatusId IS NULL)
  BEGIN
    SET @TicketStatusId = (SELECT TOP 1
        TicketStatusId
      FROM TicketStatus
      WHERE Code = @TicketStatusCode);
  END;
  SELECT
    t.TicketId
   ,t.TicketNumber
   ,t.Usd
   ,t.Usd AS moneyvalue
   ,t.Usd AS Value
   ,'true' NeedEvaluate
   ,'true' 'Set'
   ,t.TicketStatusId
   ,t.Fee1
   ,t.Fee2
    --   ,t.ExpirationDate comentado por task 6229
    --   ,FORMAT(t.ExpirationDate, 'MM-dd-yyyy', 'en-US') ExpirationDateFormat comentado por task 6229
   ,t.CreatedBy
   ,t.CreationDate
   ,FORMAT(t.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
   ,t.CompletedBy
   ,t.CompletedDate
   ,FORMAT(t.CompletedDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CompletedDateFormat
   ,ts.Code StatusCode
   ,ts.Code StatusCodeSaved
   ,ts.Description AS TicketStatusDescription
   ,u.Name UserCretedBy
   ,uc.Name UserCompletedBy
   ,t.AgencyId
   ,a.Code + ' - ' + a.Name AS Agency
   ,t.ClientName
   ,t.ClientTelephone
   ,t.ClientTelephone ClientTelephoneSaved
   ,t.TelIsCheck
   ,t.Fee1
   ,t.Fee2
    --   ,t.ExpirationDate comentado por task 6229
   ,t.UpdateToPendingDate
   ,FORMAT(t.UpdateToPendingDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') UpdateToPendingDateFormat
   ,t.UpdateToPendingBy
   ,up.Name UserUpdateToPendingBy
   ,t.UpdateToPendingShippingDate
   ,FORMAT(t.UpdateToPendingShippingDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') UpdateToPendingShippingDateFormat
   ,t.UpdateToPendingShippingBy
   ,ups.Name UserUpdateToPendingShippingBy
   ,t.MoneyOrderNumber
   ,t.MoneyOrderFee
   ,t.CardBankId
   ,t.BankAccountId
   ,t.CityCompletedDate
   ,FORMAT(t.CityCompletedDate, 'MM-dd-yyyy', 'en-US') CityCompletedDateFormat
   ,t.ChangedToPendingByAgency
   ,ac.Code + ' - ' + ac.Name ChangedToPendingByAgencyName
   ,tp.Code AS TicketsPaymentTypeCodePending
   ,t.LastUpdatedOn
   ,FORMAT(t.LastUpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') LastUpdatedOnFormat
   ,uL.Name AS LastUpdatedByName
   ,t.Cash
   ,'MODULE' Origin
   ,0 AS Plus
   ,t.AchUsd
   ,t.TransactionId
   ,tp.Description AS TicketPaymentTypeDescription
   ,CASE
      WHEN t.BankAccountId IS NOT NULL THEN '**** ' + b.AccountNumber + ' (' + bk.Name + ')'
      ELSE NULL
    END AS BankAccountName
   ,t.Usd + ISNULL(t.Fee1, 0) + ISNULL(t.Fee2, 0) AS TotalToPay
   ,t.UpdatedToPendingByAdmin
   ,t.TransactionFee TransactionFee
   ,TransactionGuid
, CASE WHEN ClientLanguage = 1 THEN 'true' ELSE 'false' END AS ClientLanguage  
,CASE WHEN t.TransactionFee IS NULL THEN 0 ELSE t.TransactionFee END TransactionFeeUI
FROM Tickets t
  INNER JOIN TicketStatus ts
    ON t.TicketStatusId = ts.TicketStatusId
  INNER JOIN Users u
    ON u.UserId = t.CreatedBy
  INNER JOIN Agencies a
    ON a.AgencyId = t.AgencyId
  LEFT JOIN TicketPaymentTypes tp
    ON t.TicketPaymentTypeId = tp.TicketPaymentTypeId
  LEFT JOIN Agencies ac
    ON ac.AgencyId = t.ChangedToPendingByAgency
  LEFT JOIN Users uc
    ON uc.UserId = t.CompletedBy
  LEFT JOIN Users up
    ON up.UserId = t.UpdateToPendingBy
  LEFT JOIN Users ups
    ON ups.UserId = t.UpdateToPendingShippingBy
  LEFT JOIN Users uL
    ON uL.UserId = t.LastUpdatedBy
  LEFT JOIN Cashiers c
    ON u.UserId = c.UserId
  LEFT JOIN dbo.BankAccounts b
    ON b.BankAccountId = t.BankAccountId
  LEFT JOIN dbo.Bank bk
    ON bk.BankId = b.BankId
  WHERE
  --Con este primer where lo que se pretende es hacer la búsqueda para los tikcects pending del QA, por 
  --lo mismo solo se tiene en cuetna cuando llega esta variable @DaysAlert y @CurrentDate y @TicketStatusCode
  (((t.TicketStatusId = @TicketStatusId
  AND @DaysAlert IS NOT NULL
  AND @TicketStatusCode = 'C01'
  AND CAST(@CurrentDate AS DATE) >= DATEADD(DAY, @DaysAlert, CAST(t.UpdateToPendingDate AS DATE)))
  --Con este primer where lo que se pretende es hacer la búsqueda para los tikcects pending del QA, por 
  --lo mismo solo se tiene en cuetna cuando llega esta variable @DaysAlert y @CurrentDate y @TicketStatusCode
  OR
  --Si no se quiere consultar los tickets pending del QA, entonces hacemos la consulta normal por el estado que llaga
  (t.TicketStatusId = @TicketStatusId
  AND @DaysAlert IS NULL)
  OR @TicketStatusId IS NULL))
  AND ((CAST(t.CreationDate AS DATE) = CAST(@Date AS DATE)
  OR @Date IS NULL))    --AND (t.AgencyId = @AgencyId
  --     OR @AgencyId IS NULL)
  AND (t.TicketNumber LIKE '%' + @TicketNumber + '%'
  OR @TicketNumber IS NULL)
  AND (t.ClientName LIKE '%' + @ClientName + '%'
  OR @ClientName IS NULL)
  AND (t.ClientTelephone = @Telephone
  OR @Telephone IS NULL)
  AND (t.AgencyId IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@ListAgenciId))
  OR @ListAgenciId IS NULL)

  AND (t.CreatedBy = @UserId
  OR @UserId IS NULL)

  AND (c.CashierId IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@ListCashierId))
  OR @ListCashierId IS NULL)
  --AND CreatedBy = CASE WHEN @UserId IS NOT NULL THEN @UserId ELSE CreatedBy
  --END

  UNION ALL
  SELECT
    NULL TicketId
   ,TD.TicketNumber
   ,0 Usd
   ,NULL AS moneyvalue
   ,NULL AS Value
   ,'true' NeedEvaluate
   ,'true' 'Set'
   ,(SELECT TOP 1
        TicketStatusId
      FROM TicketStatus
      WHERE Code = 'C02')
    TicketStatusId
   ,TD.Usd Fee1
   ,0 Fee2
    --   ,NULL ExpirationDate comentado por task 6229
    --   ,NULL ExpirationDateFormat comentado por task 6229
   ,TD.CreatedBy
   ,T.CreationDate
   ,FORMAT(T.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
   ,TD.CompletedBy
   ,TD.CompletedOn
   ,FORMAT(TD.CompletedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CompletedDateFormat
   ,(SELECT TOP 1
        Code
      FROM TicketStatus
      WHERE Code = 'C02')
    StatusCode
   ,(SELECT TOP 1
        Code
      FROM TicketStatus
      WHERE Code = 'C02')
    StatusCodeSaved
   ,(SELECT TOP 1
        Description
      FROM TicketStatus
      WHERE Code = 'C02')
    AS TicketStatusDescription
   ,uc.Name UserCretedBy
   ,uo.Name UserCompletedBy
   ,TD.AgencyId
   ,a.Code + ' - ' + a.Name AS Agency
   ,NULL ClientName
   ,NULL ClientTelephone
   ,NULL ClientTelephoneSaved
   ,NULL TelIsCheck
   ,TD.Usd Fee1
   ,0 Fee2
    --   ,NULL ExpirationDate comentado por task 6229
   ,NULL UpdateToPendingDate
   ,NULL UpdateToPendingDateFormat
   ,NULL UpdateToPendingBy
   ,NULL UserUpdateToPendingBy
   ,NULL UpdateToPendingShippingDate
   ,NULL UpdateToPendingShippingDateFormat
   ,NULL UpdateToPendingShippingBy
   ,NULL UserUpdateToPendingShippingBy
   ,NULL MoneyOrderNumber
   ,NULL MoneyOrderFee
   ,NULL CardBankId
   ,NULL BankAccountId
   ,NULL CityCompletedDate
   ,NULL CityCompletedDateFormat
   ,NULL ChangedToPendingByAgency
   ,NULL ChangedToPendingByAgencyName
   ,NULL AS TicketsPaymentTypeCodePending
   ,TD.LastUpdatedOn
   ,FORMAT(TD.LastUpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') LastUpdatedOnFormat
   ,uL.Name AS LastUpdatedByName
   ,NULL Cash
   ,'DAILY' Origin
   ,ISNULL(T.Plus, 0) Plus
   ,NULL
   ,NULL
   ,NULL
   ,NULL
   ,ISNULL(TD.Usd, 0) AS TotalToPay
   ,NULL
   ,NULL TransactionFee
   ,NULL TransactionGuid
   ,NULL ClientLanguage
   ,0 TransactionFeeUI
  FROM TicketFeeServiceDetails TD
  INNER JOIN TicketFeeServices T
    ON T.TicketFeeServiceId = TD.TicketFeeServiceId
  INNER JOIN Agencies a
    ON a.AgencyId = T.AgencyId
  LEFT JOIN Users uc
    ON uc.UserId = TD.CreatedBy
  LEFT JOIN Users uo
    ON uo.UserId = TD.CompletedBy
  LEFT JOIN Users uL
    ON uL.UserId = TD.LastUpdatedBy
  LEFT JOIN Cashiers c
    ON uc.UserId = c.UserId

  WHERE ((SELECT TOP 1
      TicketStatusId
    FROM TicketStatus
    WHERE Code = 'C02')
  = @TicketStatusId
  OR @TicketStatusId IS NULL)
  AND ((CAST(T.CreationDate AS DATE) = CAST(@Date AS DATE)
  OR @Date IS NULL))

  AND (TD.TicketNumber = @TicketNumber
  OR @TicketNumber IS NULL)
  --      AND (t.ClientName LIKE '%' + @ClientName + '%'
  --        OR @ClientName IS NULL)
  --      AND (t.ClientTelephone = @Telephone
  --        OR @Telephone IS NULL)
  AND (TD.AgencyId IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@ListAgenciId))
  OR @ListAgenciId IS NULL)

  AND (TD.CreatedBy = @UserId
  OR @UserId IS NULL)

  AND (c.CashierId IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@ListCashierId))
  OR @ListCashierId IS NULL)
  --  Se aplica el union all solamente si alguno de estos filtros llega, ya que son campos que comparten las 2 tablas 
  --  ( Ejemplo si trae el telefono no debe incluir el union all ya que no está incluido en la segunda tabla )  
  AND (@TicketStatusId IS NOT NULL
  OR @Date IS NOT NULL
  OR @TicketNumber IS NOT NULL
  OR @ListAgenciId IS NOT NULL
  OR @ListCashierId IS NOT NULL)
  AND (@Telephone IS NULL
  AND @ClientName IS NULL)

END;






GO