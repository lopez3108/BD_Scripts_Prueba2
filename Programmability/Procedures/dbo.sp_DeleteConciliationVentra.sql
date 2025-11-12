SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteConciliationVentra] 
@ConciliationVentraId INT = NULL,
@CurrentDate DATETIME
AS
     BEGIN

IF(CAST(@CurrentDate as DATE) <> (SELECT TOP 1 CAST(CreationDate as DATE) FROM ConciliationVentras WHERE
ConciliationVentraId = @ConciliationVentraId))
BEGIN

SELECT -1

END
ELSE
BEGIN

DELETE ConciliationVentras WHERE 
ConciliationVentraId = @ConciliationVentraId

SELECT @ConciliationVentraId

END

END
GO