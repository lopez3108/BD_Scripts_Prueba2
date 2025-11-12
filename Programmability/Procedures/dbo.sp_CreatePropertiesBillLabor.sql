SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      JF
-- Create date: 13/09/2024 11:33 a. m.
-- Database:    [dev29-08-2024]
-- Description: task 6054 Ajuste Bill labor pago con money order
-- =============================================



CREATE PROCEDURE [dbo].[sp_CreatePropertiesBillLabor]
 (
      @PropertiesId INT,
	  @ApartmentId INT = NULL,
	  @Name VARCHAR(50),
	  @Note VARCHAR(300),
           @ProviderCommissionPaymentTypeId INT,
           @FromDate DATETIME,
           @ToDate DATETIME,
           @Usd DECIMAL(18,2),
           @CheckNumber VARCHAR(15) = NULL,
           @CheckDate DATETIME = NULL,
           @BankAccountId INT = NULL,
           @CardBankId INT = NULL,
           @AgencyId INT = NULL,
           @MoneyOrderNumber VARCHAR(20) = NULL,
           @AchDate DATETIME = NULL,
           @CreationDate DATETIME,
           @CreatedBy INT,
		   @DepositUsed decimal(18,2) = NULL,
		   @LaborInvoice varchar(1000) = NULL
    )
AS 

BEGIN

 IF (@DepositUsed > @Usd)
  BEGIN
    SELECT
      -1; --Error is equal
  END;
ELSE

declare @contractId INT
SET @contractId = NULL

IF(@DepositUsed IS NOT NULL)
BEGIN

SET @contractId = (SELECT TOP 1 ContractId FROM Contract WHERE ApartmentId = @ApartmentId AND Status = 1)

END




INSERT INTO [dbo].[PropertiesBillLabor]
           ([PropertiesId]
		   ,[ApartmentId]
		   ,[Name]
		   ,[Note]
           ,[ProviderCommissionPaymentTypeId]
           ,[FromDate]
           ,[ToDate]
           ,[Usd]
           ,[CheckNumber]
           ,[CheckDate]
           ,[BankAccountId]
           ,[CardBankId]
           ,[AgencyId]
           ,[MoneyOrderNumber]
           ,[AchDate]
           ,[CreationDate]
           ,[CreatedBy]
		   ,[ContractId]
		   ,[DepositUsed]
		   ,[LaborInvoice])
     VALUES
           (@PropertiesId
		   ,@ApartmentId
		   ,@Name
		   ,@Note
           ,@ProviderCommissionPaymentTypeId
           ,@FromDate
           ,@ToDate
           ,@Usd
           ,@CheckNumber
           ,@CheckDate
           ,@BankAccountId
           ,@CardBankId
           ,@AgencyId
           ,@MoneyOrderNumber
           ,@AchDate
           ,@CreationDate
           ,@CreatedBy
		   ,@contractId
		   ,@DepositUsed
		   ,@LaborInvoice)

       SELECT @@IDENTITY

		   IF(@DepositUsed IS NOT NULL)
BEGIN

		   INSERT INTO [dbo].[ContractNotes]
           ([ContractId]
           ,[Note]
           ,[CreationDate]
           ,[CreatedBy])
     VALUES
           (@contractId
           ,'DEPOSIT USED FOR LABOR ' + @Name + ', AMOUNT OF $' + CAST(@DepositUsed as VARCHAR(10))
           ,@CreationDate
           ,@CreatedBy)

		   END


		   


	END


GO