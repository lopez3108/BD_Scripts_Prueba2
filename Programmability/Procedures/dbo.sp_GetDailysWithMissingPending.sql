SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-03-17 JT/5739: Error con los missing y surplus + el cash admin en el report daily
--Este sp no se usa dentro del sistema, se usó en algún momento solo para recalcular unos dailys que estaban generando probelma con el missing
--No hay necesidad de pasarlo a otros ambientes puesto que el error ya fue resuelto direcmante en produccion
CREATE PROCEDURE [dbo].[sp_GetDailysWithMissingPending]

AS
BEGIN 
SELECT d.*, c.UserId FROM Daily d INNER JOIN Cashiers c ON d.CashierId = c.CashierId WHERE d.Missing != 0 
END

GO