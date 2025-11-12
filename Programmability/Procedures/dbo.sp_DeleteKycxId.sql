SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		cmontoya
-- Create date: 06Abril2020
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_DeleteKycxId]
	@KycId int
AS
BEGIN

	DECLARE @AgencyId INT
	DECLARE @ProviderId INT

	SELECT @AgencyId = AgencyId,
	@ProviderId = ProviderId
	FROM dbo.Kyc
	WHERE KycId = @KycId

	DELETE
	FROM dbo.Kyc
	WHERE KycId = @KycId

	SELECT @AgencyId AS AgencyId, @ProviderId AS ProviderId
END
GO