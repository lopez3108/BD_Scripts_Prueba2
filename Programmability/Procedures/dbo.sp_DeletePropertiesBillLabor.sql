SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePropertiesBillLabor]
 (
 @PropertiesBillLaborId INT,
		   @CurrentDate DATETIME
    )
AS 

BEGIN

declare @billLaborDate DATETIME
set @billLaborDate = (SELECT TOP 1 CreationDate FROM [dbo].[PropertiesBillLabor] WHERE PropertiesBillLaborId = @PropertiesBillLaborId)

declare @billLaborDeposit DECIMAL(18,2)
set @billLaborDeposit = (SELECT TOP 1 DepositUsed FROM [dbo].[PropertiesBillLabor] WHERE PropertiesBillLaborId = @PropertiesBillLaborId)

IF(CAST(@billLaborDate as date) <> CAST(@CurrentDate as date))
BEGIN

SELECT -1

END
ELSE
BEGIN



IF(@billLaborDeposit IS NOT NULL)
BEGIN

declare @contractId INT
set @contractId = (SELECT TOP 1 ContractId FROM [dbo].[PropertiesBillLabor] WHERE PropertiesBillLaborId = @PropertiesBillLaborId)

declare @createdBy INT
set @createdBy = (SELECT TOP 1 CreatedBy FROM [dbo].[PropertiesBillLabor] WHERE PropertiesBillLaborId = @PropertiesBillLaborId)

INSERT INTO [dbo].[ContractNotes]
           ([ContractId]
           ,[Note]
           ,[CreationDate]
           ,[CreatedBy])
     VALUES
           (@contractId
           ,'DELETED LABOR THAT USED DEPOSIT' + ', AMOUNT OF $' + CAST(@billLaborDeposit as VARCHAR(10))
           ,@CurrentDate
           ,@createdBy)


END

DELETE [dbo].[PropertiesBillLabor]
WHERE PropertiesBillLaborId = @PropertiesBillLaborId

SELECT @PropertiesBillLaborId

END

	END
GO