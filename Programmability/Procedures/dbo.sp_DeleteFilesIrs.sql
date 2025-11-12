SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		cmontoya
-- Create date: 16Abril2020
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_DeleteFilesIrs]
	@IrsId int
AS
BEGIN

	DECLARE @AgencyId INT
	DECLARE @Window INT

	SELECT @AgencyId = AgencyId,
	@Window = Window
	FROM dbo.Irs
	WHERE IrsId = @IrsId

	DELETE
	FROM dbo.Irs
	WHERE IrsId = @IrsId

	SELECT @AgencyId AS AgencyId, @Window AS Window
END
GO