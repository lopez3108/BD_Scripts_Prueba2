SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_VerifyToken] (@UserId INT, @Token VARCHAR(300),
 @CurrentDate DATETIME
)
AS
BEGIN
--Verificamos que el token exista para el user y que no haya expirado
 IF(EXISTS(SELECT TOP 1 UserId FROM dbo.Access WHERE UserId = @UserId AND Token = @Token
 AND ExpirationDate >= @CurrentDate))
 BEGIN

 SELECT CAST(1 as BIT)
 --Eliminamos todos los tokens que tenga el user vencidos
 DELETE dbo.Access WHERE UserId = @UserId AND ExpirationDate < @CurrentDate 
 END
 ELSE
 BEGIN
  SELECT CAST(0 as BIT)
 END


END
GO