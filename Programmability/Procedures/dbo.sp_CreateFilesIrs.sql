SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		cmontoya
-- Create date: 16Abril2020
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateFilesIrs] 
	@IrsId int = NULL,
	@AgencyId int,
	@CreationDate datetime,
	@UserId int,
	@Name varchar(150),
	@Extension varchar(25),
	@Window int,
	@IdCreated      INT OUTPUT
AS
BEGIN
	IF (@IrsId IS NOT NULL)
	BEGIN
		UPDATE dbo.Irs
		SET AgencyId = @AgencyId,
		CreationDate = @CreationDate,
		UserId = @UserId,
		Name = @Name,
		Extension = @Extension
		WHERE IrsId = @IrsId
		SET @IdCreated =  @IrsId;
		--SELECT @IrsId as ID
	END
	ELSE
	BEGIN
		INSERT INTO dbo.Irs
		(AgencyId, CreationDate, UserId, Name, Extension, Window)
		VALUES
		(@AgencyId, @CreationDate, @UserId, @Name, @Extension, @Window)

		SET @IdCreated = @@IDENTITY;
	END
END
GO