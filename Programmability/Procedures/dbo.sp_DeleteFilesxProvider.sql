SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		cmontoya
-- Create date: 16Marzo2020
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_DeleteFilesxProvider]
	@FilesxProviderId int
AS
BEGIN

	DECLARE @ProviderId INT

	SELECT @ProviderId = ProviderId
	FROM dbo.FilesxProvider
	WHERE FilesxProviderId = @FilesxProviderId

	DELETE
	FROM dbo.FilesxProvider
	WHERE FilesxProviderId = @FilesxProviderId

	SELECT @ProviderId AS ProviderId

END
GO