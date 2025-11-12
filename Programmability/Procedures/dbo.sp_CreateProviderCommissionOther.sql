SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      JF
-- Create date: 20/07/2024 1:27 a. m.
-- Database:    copiaDevtest
-- Description: task 5905 Comisión pagada en 0.00 debe reflejarse en el reporte
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreateProviderCommissionOther]
 (
          @ProviderCommissionPaymentId INT
          ,@Usd DECIMAL(18,2)
          ,@Description VARCHAR(100)
          ,@ProviderCommissionPaymentTypeId INT
          ,@AchDate DATETIME = NULL
          ,@AdjustmentDate DATETIME = NULL
          ,@CheckNumber VARCHAR(15) = NULL
          ,@CheckDate DATETIME = NULL
          ,@BankId INT = NULL
          ,@Account VARCHAR(15) = NULL
          ,@ValidatedOn DATETIME = NULL
          ,@ValidatedBy INT = NULL
          ,@BankAccountId int = null,
          @LotNumber SMALLINT = NULL,
          @PaymentChecksAgentToAgentId INT = NULL,
          @CurrentDate DATETIME = NULL
    )
AS 

BEGIN

INSERT INTO [dbo].[OtherCommissions]
                  ([ProviderCommissionPaymentId]
                  ,[Usd]
                  ,[Description]
                  ,[ProviderCommissionPaymentTypeId]
                  ,[AchDate]
                  ,[AdjustmentDate]
                  ,[CheckNumber]
                  ,[CheckDate]
                  ,[BankId]
                  ,[Account]
                  ,[ValidatedOn]
                  ,[ValidatedBy]
                  ,BankAccountId,
                  LotNumber,
                  PaymentChecksAgentToAgentId,
                  CurrentDate)
     VALUES
                  (@ProviderCommissionPaymentId
                  ,@Usd
                  ,@Description
                  ,@ProviderCommissionPaymentTypeId
                  ,@AchDate
                  ,@AdjustmentDate
                  ,@CheckNumber
                  ,@CheckDate
                  ,@BankId
                  ,@Account
                  ,@ValidatedOn
                  ,@ValidatedBy
                  ,@BankAccountId,
                  @LotNumber,
                  @PaymentChecksAgentToAgentId,
                  @CurrentDate)

		   SELECT @ProviderCommissionPaymentId

	END
GO