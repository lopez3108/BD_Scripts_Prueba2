SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--date 19-06-2025 JF TASK 6604 No elimina código promocional que fue aplicado en un Check cashing que fue eliminado

CREATE PROCEDURE [dbo].[sp_DeleteCheckElsById] (@CheckElsId INT)
AS
BEGIN


  DECLARE @countClientId INT
         ,@countMakerId INT
         ,@countCheckEls INT
         ,@checkId INT
         ,@clientId INT
         ,@UserId INT
         ,@makerId INT
         ,@checkIdTodelete INT = NULL
         ,@clientIdTodelete INT = NULL;






  --Obtener checkId del checkEls
  SET @checkId = (SELECT TOP 1
      c.CheckId
    FROM ChecksEls c
    WHERE c.CheckElsId = @CheckElsId)

  --Obtener clientId del checkEls
  SET @clientId = (SELECT TOP 1
      c.ClientId
    FROM Checks c
    WHERE c.CheckId = @checkId)

  --Obtener makerId del checkEls
  SET @makerId = (SELECT TOP 1
      c.Maker
    FROM Checks c
    WHERE c.CheckId = @checkId)

  --Se obtiene el numero de checkEls ligados a un check (>1 no se puede eliminar el check)
  SET @countCheckEls = (SELECT
      COUNT(c.CheckElsId)
    FROM ChecksEls c
    WHERE c.CheckId = @checkId)

-- SE ELIMINA EL DESCUENTO 
  DELETE FROM PromotionalCodesStatus
  WHERE CheckId = @CheckElsId;


  --SE ELIMINA PRIMERO EL CHECK ELS YA QUE SI TIENE REELACION CON UN CHECK NO SE PUEDE DEJAR AL FINAL.
  DELETE FROM ChecksEls
  WHERE CheckElsId = @CheckElsId;


  --SE EVALUA SI SE PUEDE ELIMINAR UN CHECK, MAKER O CLIENT.
  IF (@countCheckEls <= 1)
  BEGIN
     --Obtener numero de veces que se usa el client en cheques. Se debe contar antes de eliminar los cheques 
    SET @countClientId = (SELECT
        COUNT(c.ClientId)
      FROM Checks c
      WHERE c.ClientId = @clientId)
    DELETE Checks
    WHERE CheckId = @checkId
    --SE ASIGNA VALOR DEL CHECK, QUE SE ESTA ELIMINANDO, PARA ELIMACION DE DOCUMENTOS.
    SET @checkIdTodelete = @checkId;


 

    IF (@countClientId <= 1
      AND @checkIdTodelete IS NOT NULL)
    BEGIN
      SET @UserId = (SELECT TOP 1
          c.UsuarioId
        FROM Clientes c
        WHERE c.ClienteId = @clientId)

      DELETE Users
      WHERE UserId = @UserId

      DELETE Clientes
      WHERE UsuarioId = @UserId

      --SE ASIGNA VALOR DEL CLIENT, QUE SE ESTA ELIMINANDO, PARA ELIMACION DE DOCUMENTOS.
      SET @clientIdTodelete = @clientId
    END


    SET @countMakerId = (SELECT
        SUM(AllCount)
      FROM ((SELECT
          COUNT(*) AS AllCount
        FROM Checks c
        WHERE c.Maker = @makerId)
        UNION ALL
        (SELECT
          COUNT(*) AS AllCount
        FROM ChecksEls ce
        WHERE ce.MakerId = @makerId)) t)


    IF (@countMakerId = 0
      AND @checkIdTodelete IS NOT NULL)
    BEGIN
      DELETE Makers
      WHERE MakerId = @makerId
    END

  END



  SELECT
    CASE
      WHEN @checkIdTodelete IS NULL THEN -1
      ELSE @checkIdTodelete
    END AS CheckId
   ,CASE
      WHEN @clientIdTodelete IS NULL THEN -1
      ELSE @clientId
    END AS ClientId;


END;





GO