SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		cmontoya
-- Create date: 12Mayo2020
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_DeleteProviderStatements]
	@ProviderStatementsId varchar(50)
AS
BEGIN

	DELETE
	FROM dbo.ProviderStatements
	WHERE  ProviderStatementsId = @ProviderStatementsId;

END

GO