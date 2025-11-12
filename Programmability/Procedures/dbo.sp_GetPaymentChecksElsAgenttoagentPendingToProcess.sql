SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPaymentChecksElsAgenttoagentPendingToProcess] @Date DATETIME = NULL,
@UserId INT = NULL,
@AgencyId INT = NULL
--@PaymentCheckId  INT = NULL
AS
BEGIN
  SELECT
    (
    ((SELECT
        COUNT(*) NumberPendings
      FROM [dbo].[ChecksEls]
      WHERE [dbo].[ChecksEls].CreatedBy = @UserId
      AND [dbo].[ChecksEls].AgencyId = @AgencyId
      AND (ChecksEls.ValidatedBy IS NULL)
      AND ((CAST([ChecksEls].CreationDate AS DATE) <= CAST(@Date AS DATE))
      OR @Date IS NULL)
      AND ((CAST([ChecksEls].CheckDate AS DATE) <= CAST(@Date AS DATE))
      OR @Date IS NULL)--task 5096  se debe ajustar para que los cheques pendientes y obligatorios para procesar solo tenga en cuenta cheques con CHECK DATE menor o igual a la fecha actual, los cheques que tengan fecha futura no son obligatorios procesar para poder cerrar el daily.

    )
    + (SELECT
        COUNT(*) NumberPendings
      FROM [dbo].ReturnPayments
      INNER JOIN [dbo].[ReturnPaymentMode] rm
        ON rm.ReturnPaymentModeId = [dbo].[ReturnPayments].ReturnPaymentModeId

      WHERE [dbo].[ReturnPayments].CreatedBy = @UserId
      AND [dbo].[ReturnPayments].AgencyId = @AgencyId
      AND (ReturnPayments.ValidatedBy IS NULL)
      AND rm.Code = 'C01'
      AND (CAST([ReturnPayments].CreationDate AS DATE) <= CAST(@Date AS DATE))
      OR @Date IS NULL)

    )) AS NumberPendings
END;
GO