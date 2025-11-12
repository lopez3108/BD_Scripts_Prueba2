SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-07-30 DJ/6676 Permitir editar expenses bank en status pending

CREATE PROCEDURE [dbo].[sp_DeleteConciliationOther] 
@ConciliationOtherId INT = NULL,
@CurrentDate DATETIME
AS
     BEGIN

	 DECLARE @CurrentStatus VARCHAR(8);

  SET @CurrentStatus = (SELECT TOP 1 
      ebs.Code
    FROM dbo.ExpenseBankStatus ebs INNER JOIN ConciliationOthers CLO ON ebs.ExpenseBankStatusId = CLO.ExpenseBankStatusId
    WHERE clo.ConciliationOtherId = @ConciliationOtherId)
  IF (@CurrentStatus = 'C02')
  BEGIN
    SELECT
      -2;
  END
  ELSE
  BEGIN

IF(CAST(@CurrentDate as DATE) <> (SELECT TOP 1 CAST(CreationDate as DATE) FROM ConciliationOthers WHERE
ConciliationOtherId = @ConciliationOtherId))
BEGIN

SELECT -1

END
ELSE
BEGIN

DELETE ConciliationOthersDistributions WHERE 
ConciliationOtherId = @ConciliationOtherId


DELETE ConciliationOthers WHERE 
ConciliationOtherId = @ConciliationOtherId

SELECT @ConciliationOtherId

END

END

END
GO