SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Nombre:  [sp_VerifyClientInfo]				    															         
-- Descripcion: Procedimiento Almacenado que los clientes por id y number 1 o id y number 2.				    					         
-- Creado por: 	JT																			 
-- Fecha: 		08-11-2023																							 	
-- Modificado por: 																										 
-- Fecha: 																										 
-- Observación: Procedimiento Almacenado que los clientes por id y number 1 o id y number 2.
-- Test: EXECUTE [dbo].[sp_VerifyClientInfo]
------
CREATE PROCEDURE [dbo].[sp_VerifyClientInfo]
(
                 @Doc1Type int, @Doc1Number varchar(80), @Name varchar(80), @Doc2Type int = NULL, @Doc2Number varchar(80) = NULL, @ClientId int = NULL

)
AS
  DECLARE @sameClient bit

  BEGIN
    SELECT c.ClienteId,
    u.Name,
    u.Telephone,
    CASE
         WHEN c.Doc1Type = @Doc1Type AND
              c.Doc1Number = @Doc1Number THEN Doc1Number
         ELSE Doc2Number
    END
    AS Doc1Number,
    FORMAT(u.BirthDay, 'MM-dd-yyyy') BirthDay
    FROM Clientes c
         INNER JOIN
         Users u
         ON u.UserId = c.UsuarioId

    WHERE (c.ClienteId != @ClientId OR
          @ClientId IS NULL) AND

          (@Doc1Type IS NOT NULL AND
          ((c.Doc1Type = @Doc1Type AND
          c.Doc1Number = @Doc1Number) OR
          (c.Doc2Type = @Doc1Type AND
          c.Doc2Number = @Doc1Number)
          ))

    UNION ALL
    SELECT c.ClienteId,
    u.Name,
    u.Telephone,
    CASE
         WHEN c.Doc1Type = @Doc2Type AND
              c.Doc1Number = @Doc2Number THEN Doc1Number
         ELSE Doc2Number
    END
    AS Doc1Number,
    FORMAT(u.BirthDay, 'MM-dd-yyyy') BirthDay
    FROM Clientes c
         INNER JOIN
         Users u
         ON u.UserId = c.UsuarioId

    WHERE (c.ClienteId != @ClientId OR
          @ClientId IS NULL) AND

          (@Doc2Type IS NOT NULL AND
          ((c.Doc1Type = @Doc2Type AND
          c.Doc1Number = @Doc2Number) OR
          (c.Doc2Type = @Doc2Type AND
          c.Doc2Number = @Doc2Number)
          ))
  END;

GO