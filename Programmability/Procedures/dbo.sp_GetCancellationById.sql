SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:      JF
-- Create date: 17/06/2024 9:51 a. m.
-- Database:    devtest
-- Description: task: 5838 Enviar sms por default al momento de crear una cancelacción en pending
-- =============================================
--Last update by JT/08-05-2025 TASK 6506 ADD NEW FIELDS @ValidatedRefundManagerBy,@ValidatedRefundManagerOn ,@ValidatedRefundByTelClient


CREATE PROCEDURE [dbo].[sp_GetCancellationById] @CancellationId INT
AS
     BEGIN
         SELECT c.CancellationId,
         c.AgencyId AS agencyId,
                c.CancellationDate,
                c.ClientName,
                c.Telephone,
                c.Email,
                c.ProviderCancelledId,
                c.ReceiptCancelledNumber,
                c.ProviderNewId,
                c.ReceiptNewNumber,
                c.RefundDate,
                c.RefundAmount,
                CAST(c.RefundAmount AS VARCHAR(30)) AS 'RefundAmountString',
                c.NewTransactionDate,
                c.TotalTransaction,
                CAST(c.TotalTransaction AS VARCHAR(30)) AS 'TotalTransactionString',
                c.Fee,
                CAST(c.Fee AS VARCHAR(30)) AS 'FeeString',
                c.InitialStatusId,
                c.CreatedBy,
                c.ChangedBy,
                cs.Code AS CodeInitialStatus,
                cs.Description AS DescriptionInitialStatus,
                c.FinalStatusId,
                csf.Code AS CodeFinalStatus,
                csf.Description AS DescriptionFinalStatus,
                pc.Name AS NameProviderCancelled,
                pn.Name AS NameProviderNew,
                pct.ProviderTypeId AS CancelledProviderTypeId,
                pct.Code AS CancelledProviderTypeCode,
                pct.Description AS CancelledProviderTypeDescription,
                pnt.ProviderTypeId AS NewProviderTypeId,
                pnt.Code AS NewProviderTypeCode,
                pnt.Description AS NewProviderTypeDescription,
                ucreate.Name AS UserNameCreate,
                uchange.Name AS UserNameChanged,
        			 c.NoteXCancellationId,
        			 nc.Description as DescriptionNote,
        			 CT.Description  CancellationType,
        			 CT.CancellationTypeId, 
        			 c.Telephone TelephoneSaved,
        			 ISNULL(c.TelIsCheck , CAST(0 AS BIT)) TelIsCheck,
        			 c.LastUpdatedOn,
        			  ul.Name as LastUpdatedByName,
        			  CAST(RefundFee AS bit) RefundFee,
                uc.CashierId,
                uc.UserId,
                c.ChooseMsg,
                CASE
                  WHEN (c.ChooseMsg = 1 OR c.ChooseMsg = 0) THEN 1
                  ELSE 0
            END AS ChooseMsgSaved
              ,ValidatedBy
   ,ValidatedOn
   ,ValidatedRefundByTelClient
   ,ValidatedRefundManagerBy
   ,ValidatedRefundManagerOn
--                c.ChooseMsg ChooseMsgSaved                
         FROM Cancellations c
              INNER JOIN CancellationStatus cs ON c.InitialStatusId = cs.CancellationStatusId
              INNER JOIN Providers pc ON pc.ProviderId = C.ProviderCancelledId
              INNER JOIN ProviderTypes pct ON pct.ProviderTypeId = pc.ProviderTypeId
              INNER JOIN Users ucreate ON ucreate.UserId = c.CreatedBy
		    INNER JOIN NotesxCancellations nc ON nc.NoteXCancellationId = c.NoteXCancellationId
        INNER JOIN dbo.Cashiers uc
    ON uc.UserId = c.CreatedBy
		    LEFT JOIN CancellationTypes ct ON CT.CancellationTypeId = c.CancellationTypeId
              LEFT JOIN Users uchange ON uchange.UserId = c.ChangedBy
              LEFT JOIN CancellationStatus csf ON c.FinalStatusId = csf.CancellationStatusId
              LEFT JOIN Providers pn ON pn.ProviderId = C.ProviderNewId
              LEFT JOIN ProviderTypes pnt ON pnt.ProviderTypeId = pn.ProviderTypeId
			   LEFT JOIN Users uL ON uL.UserId = c.LastUpdatedBy
         WHERE C.CancellationId = @CancellationId;
     END;




GO