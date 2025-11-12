SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		cmontoya
-- Create date: 12Marzo2020
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_DeleteFilesxAgencyxId]
	@FilesxAgenciesId int
AS
BEGIN

	DECLARE @AgencyId INT
	DECLARE @Window INT

	SELECT @AgencyId = AgencyId,
	@Window = Window
	FROM dbo.FilesxAgencies
	WHERE FilesxAgenciesId = @FilesxAgenciesId

	DELETE
	FROM dbo.FilesxAgencies
	WHERE FilesxAgenciesId = @FilesxAgenciesId

	SELECT @AgencyId AS AgencyId, @Window AS Window
END
GO