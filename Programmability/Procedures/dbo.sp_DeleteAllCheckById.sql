SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteAllCheckById] (@CheckId INT)
AS
BEGIN


  --1451 CHECKID
  --1396 CLIENTID USERID 1559
  --1192 MAKER
  --20171 checkelsId
  --SELECT * FROM ChecksEls ce
  --SELECT * FROM Clientes
  --SELECT * from ChecksEls ce
  --SELECT * FROM Checks c
  --SELECT * FROM Makers m
  DECLARE @countClientId INT
         ,@countMakerId INT
         ,@isDelete BIT = 0
         ,@clientId INT
         ,@UserId INT
         ,@makerId INT;


  --  SET @checkId = (SELECT TOP 1
  --      c.CheckId
  --    FROM ChecksEls c
  --    WHERE c.CheckElsId = @CheckElsId)

  SET @clientId = (SELECT TOP 1
      c.ClientId
    FROM Checks c
    WHERE c.CheckId = @CheckId)
  SET @makerId = (SELECT TOP 1
      c.Maker
    FROM Checks c
    WHERE c.CheckId = @CheckId)

  ---- SE ELIMINA PRIMERO EL CHECK ELS YA QUE SI TIENE REELACION CON UN CHECK NO SE PUEDE DEJAR AL FINAL.
  --  DELETE FROM ChecksEls
  --  WHERE CheckElsId = @CheckElsId;


  IF (@CheckId IS NOT NULL
    AND @clientId IS NOT NULL
    AND @makerId IS NOT NULL)
  BEGIN
    -- SE BUSCA SI EL CLIENTE Y MAKER ESTAN SIENDO UTILIZADOS EN MAS DE UNA SOLA OPERACION DE CHEQUE.
    SET @countClientId = (SELECT
        COUNT(c.ClientId)
      FROM Checks c
      WHERE c.ClientId = @clientId)
    SET @countMakerId = (SELECT
        COUNT(c.Maker)
      FROM Checks c
      WHERE c.Maker = @makerId)

    -- SE ELIMINA EL CHEQUE.
    IF (@countClientId = 1
      AND @countMakerId = 1)
    BEGIN
      DELETE Checks
      WHERE CheckId = @CheckId

      SET @isDelete = 1


    END

    -- SE ELIMINA USUARIO Y CLIENTE SI ESTE SOLO ESTA EN UNA OPERACION DE CHEQUE.   
    IF (@countClientId = 1)
    BEGIN
      SET @UserId = (SELECT TOP 1
          c.UsuarioId
        FROM Clientes c
        WHERE c.ClienteId = @clientId)

      DELETE Users
      WHERE UserId = @UserId

      DELETE Clientes
      WHERE UsuarioId = @UserId

    END

    -- SE ELIMINA MAKER SI ESTE SOLO ESTA EN UNA OPERACION DE CHEQUE.   
    IF (@countMakerId = 1)
    BEGIN
      DELETE Makers
      WHERE MakerId = @makerId
    END






  END
  -- SI ES UN CHECK ELS REGRESA -1, CHECK REGRESA EL ID DEL CHECKID PARA ELIMINAR EL FOLDER CON LAS IMAGENES DE CHEQUE.
  SELECT
    @isDelete
--    CASE
--      WHEN @isDelete = 0 THEN -1
--      ELSE @checkId
--    END;



END;

GO