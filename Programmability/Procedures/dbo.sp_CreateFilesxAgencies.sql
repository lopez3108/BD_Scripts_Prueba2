SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		cmontoya
-- Create date: 12Marzo2020
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateFilesxAgencies] 
	@FilesxAgenciesId int = NULL,
	@AgencyId int,
	@CreationDate datetime,
	@UserId int,
	@Name varchar(150),
	@Extension varchar(25),
	@Window int,
	@Section int,
	@IdCreated      INT OUTPUT
AS
BEGIN
	IF (@FilesxAgenciesId IS NOT NULL)
	BEGIN
		UPDATE dbo.FilesxAgencies
		SET AgencyId = @AgencyId,
		CreationDate = @CreationDate,
		UserId = @UserId,	
		Name = @Name,
		Extension = @Extension,
		Window=@Window,
		Section=@Section
		WHERE FilesxAgenciesId = @FilesxAgenciesId
		SET @IdCreated = @FilesxAgenciesId;
		
	END
	ELSE
	BEGIN
		INSERT INTO dbo.FilesxAgencies
		(AgencyId, CreationDate, UserId, Name, Extension, Window, Section)
		VALUES
		(@AgencyId, @CreationDate, @UserId, @Name, @Extension, @Window, @Section)

		SET @IdCreated = @@IDENTITY;
	END
	
END
GO