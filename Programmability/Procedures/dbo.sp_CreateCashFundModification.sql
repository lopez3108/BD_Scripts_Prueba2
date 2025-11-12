SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- Nombre:  sp_CreateCashFundModification				    															         
-- Descripcion: Procedimiento Almacenado que consulta los fraud alerts.				    					         
-- Creado por: 	JT																			 
-- Fecha: 		17-05-2023																							 	
-- Modificado por: JT																								 
-- Fecha: 2023-10-17																											 
-------------
CREATE PROCEDURE [dbo].[sp_CreateCashFundModification] @CashFundModificationsId INT = NULL,
@CashierId INT,
@CreditCashFund DECIMAL(18, 2),
@DebitCashFund DECIMAL(18, 2),
@CreationDate DATETIME,
@CreatedBy INT,
@AgencyId INT,
@IsReturned  BIT
AS
BEGIN
  IF (@CashFundModificationsId IS NULL)
  BEGIN

    INSERT INTO [dbo].[CashFundModifications] ([CashierId]
    , CreditCashFund
    , DebitCashFund
    , [CreationDate]
    , [CreatedBy]
    , [AgencyId])
      VALUES (@CashierId, @CreditCashFund, @DebitCashFund, @CreationDate, @CreatedBy, @AgencyId)
  END
  ELSE
  BEGIN
    UPDATE [CashFundModifications]
    SET CreditCashFund = @CreditCashFund
       ,DebitCashFund = @DebitCashFund
       ,[CreationDate] = @CreationDate
       ,--Como este campo se permite cambiar solo el mismo día de creación  del cash fund, entonces siempre se actualiza JT TASK 5441
        [CreatedBy] = @CreatedBy  --Como este campo se permite cambiar solo el mismo día de creación  del cash fund, entonces siempre se actualiza
       ,[AgencyId] = @AgencyId
	   ,IsReturned = @IsReturned
    WHERE CashFundModificationsId = @CashFundModificationsId
  END
END

GO