SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--CREATEDBY: JT
--CREATEDON:29-11-2023
--task 5306, UPDATE VIP CLIENT


CREATE PROCEDURE [dbo].[sp_UpdateClientVipInfo] (
@ClientId INT = NULL,
@IsClientVIP BIT = NULL,
@ReasonOne VARCHAR(400) = NULL,
@ReasonTwo VARCHAR(400) = NULL,
@VIPUserId INT = NULL,
@VIPAgencyId INT = NULL,
@VIPDate DATETIME = NULL
)

AS

BEGIN

    UPDATE [dbo].Clientes
    SET IsClientVIP = @IsClientVIP,
	 ReasonOne = @ReasonOne,
	 ReasonTwo = @ReasonTwo,
	 VIPUserId = @VIPUserId,
	 VIPAgencyId = @VIPAgencyId,
	 VIPDate = @VIPDate
    WHERE ClienteId = @ClientId

END


GO