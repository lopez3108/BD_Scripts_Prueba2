SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Nombre:  sp_GetAllTicketsByTransactionGuid				    															         
-- Descripcion: Procedimiento Almacenado que consulta el ticket por Id.				    					         
-- Creado por: JT					
-- Fecha: 2025-02-21																											
-- Observación:  El sp está dispuesto a recibir el ticketid, o el @TransactionGuid, y esto es porque los registros viejos, no cuentan con el campo @TransactionGuid
-- Test: EXECUTE [dbo].[sp_GetAllTicketsByTransactionGuid] @TicketId = 1705  , @TransactionGuid = ''                                     
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 20205-03-10 JT/5939: Fix error in lasdt updated by 
-- 20205-03-27 JT/6412: Nuevo campo ClientLanguage
-- 2025-04-22  JF/6447: Permitir editar tickets usd
-- 2025-04-29  JF/6486: Traffict ticket no, está Actualizar en la grid Last update on - Last update by

CREATE PROCEDURE [dbo].[sp_GetAllTicketsByTransactionGuid] (@TicketId INT = NULL, @TransactionGuid UNIQUEIDENTIFIER = NULL)
AS
BEGIN
  SELECT
    t.TicketId
   ,t.TicketNumber
   ,t.Usd
   ,t.Usd UsdSaved 
   ,t.Usd AS moneyvalue
   ,t.Usd AS moneyvalueSaved
   ,t.Usd AS Value
   ,'true' AS NeedEvaluate
   ,'true' AS [Set]
   ,t.TicketStatusId
   ,t.TicketStatusId AS TicketStatusIdSaved
--   ,0 AS Disabled
,CAST(
  CASE
    WHEN ts.Code = 'C00' OR ts.Code = 'C03' THEN 0
    ELSE 1
  END AS BIT
) AS Disabled

   ,t.CreatedBy
   ,t.CreationDate
   ,t.CompletedBy
   ,t.CompletedDate
   ,ts.Code AS StatusCode
   ,ts.Code AS StatusCodeSavedDb
   ,ts.Description AS TicketStatusDescription
   ,u.Name AS UserCretedBy
   ,uc.Name AS UserCompletedBy
   ,t.AgencyId
   ,a.Name AS Agency
   ,a.Address
   ,a.ZipCode
   ,a.Address AgencyAddress
   ,a.Address AgencyAddress
   ,CASE
      WHEN ZipCodes.StateAbre IS NULL THEN ' '
      ELSE ' ' + ZipCodes.StateAbre
    END AS AgencyStateAbreviation
   ,a.ZipCode AgencyZipCode
   ,a.Telephone AgencyPhone
   ,a.Telephone
   ,t.ClientName
   ,t.ClientName AS ClientNameSaved
   ,t.ClientTelephone
   ,t.ClientTelephone AS ClientTelephoneSaved
   ,t.Fee1
   ,t.Fee2
   ,t.UpdateToPendingDate
   ,t.UpdateToPendingBy
   ,t.ChangedToPendingByAgency
   ,t.UpdateToPendingShippingDate
   ,t.UpdateToPendingShippingBy
   ,t.MoneyOrderNumber
   ,t.MoneyOrderFee
   ,t.CardBankId
   ,t.BankAccountId
   ,t.CityCompletedDate
   ,t.FileImageName
   ,t.FileImageName FileImageNameSaved
   ,t.MoFileImageName
   ,t.ChangedToPendingByAgency
   ,tp.Code AS TicketsPaymentTypeCodePending
   ,t.CardPayment
   ,t.CardPayment AS CardPaymentSaved
   ,t.CardPaymentFee
   ,t.CardPaymentFee CardPaymentFeeSaved
   ,t.TelIsCheck
   ,t.LastUpdatedOn
   ,t.LastUpdatedBy
   ,uL.Name AS LastUpdatedByName
   ,t.Cash
   ,t.Cash CashSaved
   ,t.Tollway
   ,t.Others
   ,t.Tollway AS TollwaySaved
   ,t.Others AS OthersSaved
   ,t.PlateNumber
   ,t.PlateNumber PlateNumberSaved
   ,t.StateAbre
   ,t.StateAbre StateAbreSaved
   ,t.FileNameOthers
   ,t.FileNameOthers FileNameOthersSaved
   ,tp.Description AS TicketPaymentTypeDescription
   ,t.AchUsd
   ,t.TransactionId
   ,CASE
      WHEN t.BankAccountId IS NOT NULL THEN '**** ' + b.AccountNumber + ' (' + bk.Name + ')'
      ELSE NULL
    END AS BankAccountName
   ,t.TicketPaymentTypeId
   ,aa.Code + ' - ' + aa.Name AS ChangedToPendingByAgencyName
   ,t.UpdatedToPendingByAdmin
   ,c.CashierId
   ,t.TransactionGuid
   ,CASE
      WHEN t.TransactionFee IS NULL AND
        t.TransactionId IS NOT NULL THEN CAST(0 AS DECIMAL(18, 2))
      ELSE t.TransactionFee
    END AS TransactionFee
   ,
    -- Funciones de ventana para los totales por grupo
    --    SUM(t.Usd) OVER (PARTITION BY 
    --      CASE 
    --        WHEN t.TransactionGuid IS NOT NULL THEN CAST(t.TransactionGuid AS NVARCHAR(50))
    --        ELSE CAST(t.TicketId AS NVARCHAR(50))
    --      END
    --    ) AS TotalUsd,
    --    SUM(t.Fee1) OVER (PARTITION BY 
    --      CASE 
    --        WHEN t.TransactionGuid IS NOT NULL THEN CAST(t.TransactionGuid AS NVARCHAR(50))
    --        ELSE CAST(t.TicketId AS NVARCHAR(50))
    --      END
    --    ) AS TotalFee1,
    --    SUM(t.Fee2) OVER (PARTITION BY 
    --      CASE 
    --        WHEN t.TransactionGuid IS NOT NULL THEN CAST(t.TransactionGuid AS NVARCHAR(50))
    --        ELSE CAST(t.TicketId AS NVARCHAR(50))
    --      END
    --    ) AS TotalFee2,
    -- Identificador de grupo para referencia
    CASE
      WHEN t.TransactionGuid IS NOT NULL THEN CAST(t.TransactionGuid AS NVARCHAR(50))
      ELSE CAST(t.TicketId AS NVARCHAR(50))
    END AS GroupIdentifier
   ,(SELECT TOP 1
        Name
      FROM CompanyInformation)
    AS Corporation
    , CASE WHEN ClientLanguage = 1 THEN 'true' ELSE 'false' END AS ClientLanguage
    ,t.Fee2DefaultUsd
    ,t.UsdGreaterValue
    ,t.UsdLessEqualValue
  FROM Tickets t
  INNER JOIN TicketStatus ts
    ON t.TicketStatusId = ts.TicketStatusId
  INNER JOIN Users u
    ON u.UserId = t.CreatedBy
  INNER JOIN Cashiers c
    ON c.UserId = u.UserId
  INNER JOIN Agencies a
    ON a.AgencyId = t.AgencyId
  LEFT JOIN ZipCodes
    ON a.ZipCode = ZipCodes.ZipCode
  LEFT JOIN TicketPaymentTypes tp
    ON t.TicketPaymentTypeId = tp.TicketPaymentTypeId
  LEFT JOIN Users uc
    ON uc.UserId = t.CompletedBy
  LEFT JOIN Users uL
    ON uL.UserId = t.LastUpdatedBy
  LEFT JOIN dbo.BankAccounts b
    ON b.BankAccountId = t.BankAccountId
  LEFT JOIN dbo.Bank bk
    ON bk.BankId = b.BankId
  LEFT JOIN dbo.Agencies aa
    ON aa.AgencyId = t.ChangedToPendingByAgency
  --Consultamos la informción por el guid que agrupa todos los tickets de una misma transaction, o para los registros viejos
  --que no tiene el GUID, se consutla la información directamente por el ticketId
  WHERE (CAST(@TransactionGuid AS NVARCHAR(50)) IS NOT NULL
  AND t.TransactionGuid = @TransactionGuid)
--  OR ((CAST(@TransactionGuid AS NVARCHAR(50)) IS NULL
--  AND t.TicketId = @TicketId OR @TicketId IS NULL))


END;









GO