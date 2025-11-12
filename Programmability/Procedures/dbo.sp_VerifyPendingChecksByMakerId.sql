SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATEDBY: JOHAN
--CREATEDON: 24-02-23
--USO: VERIFICA LOS CHEQWUES PENDIENTES LIGADOS A UN MAKER.
CREATE PROCEDURE [dbo].[sp_VerifyPendingChecksByMakerId] (@MakerId INT = null)
AS
BEGIN
  IF EXISTS (SELECT TOP 1
        Maker
      FROM Checks c
       INNER JOIN DocumentStatus DS ON DS.DocumentStatusId = c.CheckStatusId
    LEFT JOIN Clientes cl
      ON c.ClientId = cl.ClienteId
	  INNER JOIN DocumentStatus DSC ON DSC.DocumentStatusId = cl.ClientStatusId
      WHERE (DS.Code = 'C02' --C02 PENDING
	  OR DSC.Code='C02')
     
      AND c.Maker = @MakerId)
  BEGIN
    SELECT
      u.Name
     ,c.Account
     ,c.Routing
     ,c.Number,
     m.Name AS MakerName
     
    FROM Checks c
    LEFT JOIN Clientes cl
      ON c.ClientId = cl.ClienteId
    INNER JOIN Users u
      ON cl.UsuarioId = u.UserId
      INNER JOIN Makers m ON c.Maker = m.MakerId
        INNER JOIN DocumentStatus DS ON DS.DocumentStatusId = c.CheckStatusId
      WHERE C.Maker = @MakerId AND (DS.Code = 'C02' --C02 PENDING
	 )
  END


END;


GO