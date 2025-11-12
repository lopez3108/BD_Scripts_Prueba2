SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-04-23 JT/: No se pueden eliminar agendas que ya fueron completadas
CREATE PROCEDURE [dbo].[sp_ValidateStatusAgenda] @AgendaId INT
AS
BEGIN
  SELECT
    *
  FROM dbo.Agendas a
  INNER JOIN dbo.AgendaStatus [as]
    ON a.AgendaStatusId = [as].AgendaStatusId
  WHERE a.AgendaId = @AgendaId
  AND [as].Code = 'C02'
END
GO