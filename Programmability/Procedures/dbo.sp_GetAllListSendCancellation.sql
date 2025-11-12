SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- CreateBy: JF CreatedOn: 18-05-2024  Task: 5838 
-- =============================================
-- Author:      JF
-- Create date: 18/06/2024 4:05 p. m.
-- Database:    devtest
-- Description: task 5838  ABS(c.Fee + c.TotalTransaction) AmountUsd  colocar valor negativo en positivo 
-- =============================================



CREATE PROCEDURE [dbo].[sp_GetAllListSendCancellation] ( @CancellationId INT = NULL, @AgencyId INT = NULL )
AS
  SET NOCOUNT ON;
  BEGIN
    SELECT
      c.ClientName
     ,c.ReceiptCancelledNumber
     ,ABS(c.Fee + c.TotalTransaction) AmountUsd
     ,a.Name AgencyName
     ,a.Telephone AgencyPhone
     ,a.Address AgencyAddress
     ,c.Telephone
     ,c.CancellationId

    FROM Cancellations c
    INNER JOIN Agencies a
      ON c.AgencyId = a.AgencyId

    WHERE c.CancellationId = @CancellationId
    AND c.AgencyId = @AgencyId

  END;
GO