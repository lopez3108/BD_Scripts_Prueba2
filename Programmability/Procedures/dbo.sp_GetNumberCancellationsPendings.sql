SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--created by: Sergio
--Date: 26-04-2024
--created for quick access to pending cancellations

CREATE PROCEDURE [dbo].[sp_GetNumberCancellationsPendings] @AgencyId INT = NULL
AS
BEGIN
  SELECT
    COUNT(*) AS NumberCancellationsPendings
  FROM Cancellations c
  INNER JOIN CancellationStatus cs
    ON c.InitialStatusId = cs.CancellationStatusId
  WHERE (AgencyId = @AgencyId
  OR @AgencyId IS NULL)
  AND cs.Code = 'C03' -- C03 es el codigo de cacellation pendings
END;
GO