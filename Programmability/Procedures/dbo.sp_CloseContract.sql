SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-09-05JF/6722: Contracts deben poder quedar en status PENDING cuando se crean
-- 2025-10-09 JF/6786: Ajuste para contratos cerrados el mismo día de creación
-- 2025-10-20 JF/6776: Permitir cerrar contratos antes de la fecha final
-- 2025-11-06 JF/6776: prueba de cambios FELIPE oquendo 

CREATE PROCEDURE [dbo].[sp_CloseContract] (@ContractId INT = NULL,
@SetAvailableDeposit BIT,
@CurrentDate DATETIME,
@Note VARCHAR(300) = NULL,
@ClosedBy INT,
@RentValue DECIMAL(18, 2) = NULL,
@MoveInFee DECIMAL(18, 2) = NULL,
@ClosedDate DATETIME,
@ClosedDate2 DATETIME
)

AS

BEGIN

  IF EXISTS (SELECT
        1
      FROM Contract c
      WHERE c.IsPendingInformation = 1
      AND c.ContractId = @ContractId)
  BEGIN
    RETURN -1
  END
  ELSE
  BEGIN


    UPDATE Contract
    SET ClosedDate = @ClosedDate
       ,Status = (SELECT TOP 1
            ContractStatusId
          FROM ContractStatus
          WHERE Code = 'C02')
       ,ClosedBy = @ClosedBy
    WHERE ContractId = @ContractId

    IF (@Note IS NOT NULL)
    BEGIN

      INSERT INTO [dbo].[ContractNotes] ([ContractId]
      , [Note]
      , [CreationDate]
      , [CreatedBy])
        VALUES (@ContractId, @Note, @CurrentDate, @ClosedBy)
    END

    INSERT INTO [dbo].[ContractNotes] ([ContractId]
    , [Note]
    , [CreationDate]
    , [CreatedBy])
      VALUES (@ContractId, 'CONTRACT CLOSED', @CurrentDate, @ClosedBy)


    UPDATE [dbo].[Contract]
    SET [SetAvailableDeposit] = @SetAvailableDeposit,
        [RentValue] = @RentValue,
        [MoveInFee] = @MoveInFee 
    WHERE ContractId = @ContractId

    RETURN @ContractId; -- devolvemos el ID del contrato cerrado


  END

END








GO