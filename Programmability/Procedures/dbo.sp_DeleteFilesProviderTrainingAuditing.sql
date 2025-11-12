SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		cmontoya
-- Create date: 18Abril2020
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_DeleteFilesProviderTrainingAuditing]
	@ProviTrainingAuditingId int
AS
BEGIN
	DECLARE @AgencyId INT
	DECLARE @ProviderId INT
	DECLARE @Window INT

	SELECT @AgencyId = AgencyId,
	@ProviderId = ProviderId,
	@Window = Window
	FROM dbo.ProviderTrainingAuditing
	WHERE ProviderTrainingAuditingId = @ProviTrainingAuditingId

	DELETE
	FROM dbo.ProviderTrainingAuditing
	WHERE ProviderTrainingAuditingId = @ProviTrainingAuditingId

	SELECT @AgencyId AS AgencyId, @ProviderId AS ProviderId, @Window AS Window
END
GO