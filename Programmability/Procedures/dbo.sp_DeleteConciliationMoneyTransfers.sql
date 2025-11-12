SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteConciliationMoneyTransfers] 
@ConciliationMoneyTransfersId INT = NULL,
@CurrentDate DATETIME
AS
     BEGIN

IF(CAST(@CurrentDate as DATE) <> (SELECT TOP 1 CAST(CreationDate as DATE) FROM ConciliationMoneyTransfers WHERE
ConciliationMoneyTransfersId = @ConciliationMoneyTransfersId))
BEGIN

SELECT -1

END
ELSE
BEGIN

DELETE ConciliationMoneyTransfers WHERE 
ConciliationMoneyTransfersId = @ConciliationMoneyTransfersId

SELECT @ConciliationMoneyTransfersId

END

END
GO