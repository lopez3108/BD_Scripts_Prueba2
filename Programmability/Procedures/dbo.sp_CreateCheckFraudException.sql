SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Nombre:  sp_CreateCheckFraudException				    															         
-- Descripcion: Procedimiento Almacenado que guarda la excepcion d un fraude			    					         
-- Creado por: 	FELIPE																		 
-- Fecha: 		11-09-2023																							 	
-- Modificado por: 																										 
-- Fecha: 																											 
-- Observación: 
--                             
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



CREATE PROCEDURE [dbo].[sp_CreateCheckFraudException]
(
                 @Account varchar(50), @Maker VARCHAR(80), @IsSafe bit ,@IsNotFraud bit

)
AS



  DECLARE @CheckFraudExceptionId int;

  SET @CheckFraudExceptionId = 
  (  SELECT TOP 1 CheckFraudExceptionId
FROM CheckFraudExceptions
WHERE @Account = Account AND @Maker = Maker
)

  BEGIN

    IF (@CheckFraudExceptionId IS NULL OR
    @CheckFraudExceptionId = 0)
    BEGIN


      INSERT INTO [dbo].[CheckFraudExceptions] ([Account],[Maker],
      IsSafe,IsNotFraud)

      VALUES(@Account,@Maker, @IsSafe,@IsNotFraud)

      SELECT @@identity

    END
    ELSE
    BEGIN

      UPDATE [dbo].[CheckFraudExceptions]
        SET IsSafe = @IsSafe

      WHERE CheckFraudExceptionId = @CheckFraudExceptionId

      SELECT @CheckFraudExceptionId

    END

  END


GO