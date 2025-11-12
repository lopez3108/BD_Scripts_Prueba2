SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Nombre:  sp_GetTicketById				    															         
-- Descripcion: Procedimiento Almacenado que consulta el ticket por Id.				    					         
-- Creado por: 																				 
-- Fecha: 																									 	
-- Modificado por: Diego León Acevedo Arenas																										 
-- Fecha: 2023-07-21																											 
-- Observación:  Se agregan los campos Tollway, Others, PlateNumber, StateAbre, FileNameOthers y se remueve el campo TicketDate, ClientAddress 
-- Test: EXECUTE [dbo].[sp_GetTicketById] @TicketId = 1705                                      
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:      JF
-- Create date: 28/08/2024 11:14 a. m.
-- Database:    developing
-- Description: task 5937  Permitir editar campos para los traffic tickets 
-- =============================================

-- 20204-11-06 DJ/6127: Pay Tickets using ACH
-- 20204-11-12 JF/6186: Validar pagos de Traffic tickets de PENDING SHIPPING A PENDIG
-- 20204-11-18 JF/6185: Admin o manager editar un Traffic ticket se desborda la API
-- 20204-11-28 LF/6229: Ajustes formulario traffic tickets

CREATE PROCEDURE [dbo].[sp_GetTicketById] @TicketId INT
AS
BEGIN
    SELECT t.TicketId,
           t.TicketNumber,       
           t.Usd,
           t.Usd            AS moneyvalue,
           t.Usd            AS Value,
           'true'              NeedEvaluate,
           'true'              'Set',
           t.TicketStatusId,
           t.TicketStatusId AS TicketStatusIdSaved,
           'true'              Disabled,
           t.CreatedBy,
           t.CreationDate,
           t.CompletedBy,
           t.CompletedDate,
           ts.Code             StatusCode,
           ts.Description   AS TicketStatusDescription,
           u.Name              UserCretedBy,
           uc.Name             UserCompletedBy,
           t.AgencyId,
           a.Name              Agency,
           a.Address,
           a.ZipCode,
           a.Telephone,
           t.ClientName,
           t.ClientTelephone,
           t.ClientTelephone   ClientTelephoneSaved,
           t.Fee1,
           t.Fee2,
--           t.ExpirationDate,  comentado por task 6229
--           t.ExpirationDate as ExpirationDateSaved, comentado por task 6229
           t.UpdateToPendingDate,
           t.UpdateToPendingBy,
    		   t.ChangedToPendingByAgency,
    		   t.UpdateToPendingShippingDate,
           t.UpdateToPendingShippingBy,
           t.MoneyOrderNumber,
           t.MoneyOrderFee,
           t.CardBankId,
           t.BankAccountId,
           t.CityCompletedDate,
           t.FileImageName,
           t.MoFileImageName,
           t.ChangedToPendingByAgency,
           tp.Code          AS TicketsPaymentTypeCodePending,
           t.CardPayment,
           t.CardPayment AS CardPaymentSaved,
           t.CardPaymentFee,
           t.TelIsCheck,
           t.LastUpdatedOn,
           ul.Name as LastUpdatedByName,
           t.Cash,
           t.Tollway,
           t.Others,
           t.Tollway AS TollwaySaved,
           t.Others  AS OthersSaved,
           t.PlateNumber,
           t.StateAbre,
           T.FileNameOthers,
		   tp.Description as TicketPaymentTypeDescription,
		   t.AchUsd,
		   t.TransactionId,
		   CASE WHEN t.BankAccountId IS NOT NULL THEN
			'**** ' + b.AccountNumber + ' (' + bk.Name + ')' ELSE NULL END as BankAccountName,
			t.TicketPaymentTypeId,
			aa.Code + ' - ' + aa.Name ChangedToPendingByAgencyName,
			t.UpdatedToPendingByAdmin,
          c.CashierId,
--		  ISNULL(t.TransactionFee,0) AS TransactionFee

     CASE 
        WHEN t.TransactionFee IS NULL AND t.TransactionId IS NOT NULL THEN CAST(0 AS DECIMAL(18,2))
        ELSE t.TransactionFee
    END AS TransactionFee
    FROM Tickets t
             INNER JOIN TicketStatus ts ON t.TicketStatusId = ts.TicketStatusId
             INNER JOIN Users u ON u.UserId = t.CreatedBy
             INNER JOIN Cashiers c  ON c.UserId = u.UserId
             INNER JOIN Agencies a ON a.AgencyId = t.AgencyId
             LEFT JOIN TicketPaymentTypes tp ON t.TicketPaymentTypeId = tp.TicketPaymentTypeId
             LEFT JOIN Users uc ON uc.UserId = t.CompletedBy
             LEFT JOIN Users uL ON uL.UserId = t.LastUpdatedBy
			 LEFT JOIN dbo.BankAccounts b ON b.BankAccountId = t.BankAccountId
			 LEFT JOIN dbo.Bank bk ON bk.BankId = b.BankId
			 LEFT JOIN dbo.Agencies aa ON aa.AgencyId = t.ChangedToPendingByAgency
    WHERE t.TicketId = @TicketId;
END;






GO