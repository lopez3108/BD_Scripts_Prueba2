SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllPendingChecksByListId]
(@ListChecksIds    VARCHAR(1000) = NULL
)
AS
     BEGIN

	         DECLARE @StatusId INT;

         SELECT 
      u.Name
     ,c.Account
     ,c.Routing
     ,c.Number
	 ,u.Name ClientName
	 ,m.Name MakerName
       FROM Checks c
	   INNER JOIN Makers m on m.MakerId = c.Maker
	   INNER JOIN ChecksEls cels on cels.CheckId = c.CheckId
	   INNER JOIN DocumentStatus DS ON DS.DocumentStatusId = c.CheckStatusId
    LEFT JOIN Clientes cl
      ON c.ClientId = cl.ClienteId
	  INNER JOIN DocumentStatus DSC ON DSC.DocumentStatusId = cl.ClientStatusId
    INNER JOIN Users u
	ON cl.UsuarioId = u.UserId
      WHERE (DS.Code = 'C02' --C02 PENDING
	  OR DSC.Code='C02')
	  --2 = PENDINGS -SE COMPARA CON DOS PORQUE NO TIENE TABLA DE ESTADOS
	
     AND (cels.CheckElsId IN
        (
            SELECT item
            FROM dbo.FN_ListToTableInt(@ListChecksIds)
        )
        OR (@ListChecksIds = ''
            OR @ListChecksIds IS NULL))
     end  
	 
GO