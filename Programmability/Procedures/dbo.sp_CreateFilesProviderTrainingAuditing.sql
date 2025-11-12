SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		cmontoya
-- Create date: 18Abril2020
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateFilesProviderTrainingAuditing] 
	@ProviTrainingAuditingId int = NULL,
	@AgencyId int,
	@ProviderId int,
	@CreationDate datetime,
	@UserId int,
	@Name varchar(150),
	@Extension varchar(25),
	@Window int,
	@IdCreated      INT OUTPUT
AS
BEGIN
	IF (@ProviTrainingAuditingId IS NOT NULL)
	BEGIN
		UPDATE dbo.ProviderTrainingAuditing
		SET AgencyId = @AgencyId,
		ProviderId = @ProviderId,
		CreationDate = @CreationDate,
		UserId = @UserId,
		Name = @Name,
		Extension = @Extension
		WHERE ProviderTrainingAuditingId = @ProviTrainingAuditingId
 SET @IdCreated = @ProviTrainingAuditingId;
		--SELECT @ProviTrainingAuditingId as ID
	END
	ELSE
	BEGIN
		INSERT INTO dbo.ProviderTrainingAuditing
		(AgencyId, ProviderId, CreationDate, UserId, Name, Extension, Window)
		VALUES
		(@AgencyId, @ProviderId, @CreationDate, @UserId, @Name, @Extension, @Window)

		
		SET @IdCreated = @@IDENTITY;
	END
END
GO