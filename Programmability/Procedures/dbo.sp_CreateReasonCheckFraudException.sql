SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Nombre:  sp_CreateCheckFraudException				    															         
-- Descripcion: Procedimiento Almacenado  que guarda la nota de la  excepcion de un fraude			    					         
-- Creado por: 	FELIPE																		 
-- Fecha: 		11-09-2023																							 	
-- Modificado por: 																										 
-- Fecha: 																											 
-- Observación: 
--                             
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[sp_CreateReasonCheckFraudException]
(
@ReasonCheckFraudExceptionId INT = NULL,
@CheckFraudExceptionId INT,
@Reason                      VARCHAR(300),
@CreationDate                DATETIME  = NULL,
@CreatedBy                   INT = NULL


)
AS

BEGIN

  IF (@ReasonCheckFraudExceptionId IS NULL
    OR @ReasonCheckFraudExceptionId = 0)
  BEGIN 


    INSERT INTO [dbo].[ReasonsCheckFraudExceptions]

      (
      [Reason],
      CreatedBy,
      CreationDate,
      CheckFraudExceptionId
      )

      VALUES 
      (
      @Reason,
      @CreatedBy,
      @CreationDate  ,
	  @CheckFraudExceptionId
      )

    SELECT
      @@IDENTITY

  END
  ELSE
  BEGIN

    UPDATE [dbo].[ReasonsCheckFraudExceptions]
    SET
     [Reason] = @Reason,
     CreationDate  = @CreationDate,
     CreatedBy     = @CreatedBy 

    WHERE ReasonCheckFraudExceptionId = @ReasonCheckFraudExceptionId

    SELECT
      @ReasonCheckFraudExceptionId

  END

END


GO