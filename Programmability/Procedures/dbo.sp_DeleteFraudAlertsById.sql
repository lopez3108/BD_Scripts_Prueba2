SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create PROCEDURE [dbo].[sp_DeleteFraudAlertsById] (@FraudId INT)
AS

BEGIN
  --Documentos
  DELETE FraudFiles 
  WHERE FraudId = @FraudId

  --Notas
  DELETE FraudNotes
  WHERE FraudId = @FraudId
  
  --Tabla principal
  DELETE FraudAlert
  WHERE FraudId = @FraudId


  SELECT
    1

END


GO