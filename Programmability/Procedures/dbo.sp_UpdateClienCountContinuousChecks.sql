SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--CREATEDBY: JT
--CREATEDON:29-11-2023
--task 5306, UPDATE VIP CLIENT
--Description: Allows to edit the count for the continues change of checks for the same client


CREATE PROCEDURE [dbo].[sp_UpdateClienCountContinuousChecks] (
@ClientId INT = NULL,
@IsAddCheck BIT = NULL
)

AS

BEGIN

    UPDATE [dbo].Clientes
    SET CountContinuousChecks = CASE WHEN @IsAddCheck = 1
	THEN ISNULL(CountContinuousChecks , 0) + 1
	WHEN @IsAddCheck <> 1 AND CountContinuousChecks > 0--No se puede permitir rebajar más de 0 el conteo
	THEN CountContinuousChecks - 1
	END
    WHERE ClienteId = @ClientId

END


GO