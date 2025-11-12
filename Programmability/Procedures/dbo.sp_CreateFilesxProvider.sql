SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		cmontoya
-- Create date: 16Marzo2020
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateFilesxProvider] 
	@FilesxProviderId int = NULL,
	@ProviderId int,
	@CreationDate datetime,
	@UserId int,
	@Name varchar(150),
	@Extension varchar(25),
	@IdCreated      INT OUTPUT
AS
BEGIN
	IF (@FilesxProviderId IS NOT NULL)
	BEGIN
		UPDATE dbo.FilesxProvider
		SET ProviderId = @ProviderId,
		CreationDate = @CreationDate,
		UserId = @UserId,
		Name = @Name,
		Extension = @Extension
		WHERE FilesxProviderId = @FilesxProviderId
		SET @IdCreated = @FilesxProviderId
		END
		
	ELSE
	BEGIN
		INSERT INTO dbo.FilesxProvider
		(ProviderId, CreationDate, UserId, Name, Extension)
		VALUES
		(@ProviderId, @CreationDate, @UserId, @Name, @Extension)

		SET @IdCreated = @@IDENTITY;
	END
END
GO