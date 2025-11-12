SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      sa
-- Create date: 8/07/2024 3:58 p. m.
-- Database:    copiaDevtest
-- Description: task 5905 Comisión pagada en 0.00 debe reflejarse en el reporte
-- =============================================


CREATE PROCEDURE [dbo].[sp_GetProviderCommissionOthers](@ProviderCommissionPaymentId INT)
AS
    BEGIN
        SELECT dbo.OtherCommissions.OtherCommissionId,
               ProviderCommissionPaymentTypes.Description AS PaymentTypeOther ,
               dbo.OtherCommissions.ProviderCommissionPaymentId,            
               dbo.OtherCommissions.Usd, 
               dbo.OtherCommissions.Usd AS UsdSaved , 
               dbo.OtherCommissions.Description, 
               dbo.OtherCommissions.ProviderCommissionPaymentTypeId, 
               dbo.OtherCommissions.ProviderCommissionPaymentTypeId AS ProviderCommissionPaymentTypeIdSaved,
               dbo.OtherCommissions.AchDate, 
               dbo.OtherCommissions.AdjustmentDate, 
               dbo.OtherCommissions.CheckNumber, 
               dbo.OtherCommissions.CheckDate, 
               dbo.OtherCommissions.BankId, 
			         dbo.OtherCommissions.BankAccountId, 
               dbo.OtherCommissions.Account, 
               dbo.ProviderCommissionPaymentTypes.Code,
               dbo.OtherCommissions.PaymentChecksAgentToAgentId,
               dbo.OtherCommissions.LotNumber,
              dbo.OtherCommissions.ValidatedBy,
              dbo.OtherCommissions.ValidatedOn,
              dbo.OtherCommissions.CurrentDate AS CreationDate

        FROM dbo.OtherCommissions
             INNER JOIN dbo.ProviderCommissionPaymentTypes ON dbo.OtherCommissions.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
			 LEFT OUTER JOIN dbo.BankAccounts ON dbo.OtherCommissions.BankAccountId = dbo.BankAccounts.BankAccountId
		WHERE [ProviderCommissionPaymentId] = @ProviderCommissionPaymentId;
    END;
GO