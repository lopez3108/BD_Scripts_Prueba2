SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		cmontoya
-- Create date: 12Mayo2020
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_DeleteBankStatements]
	@BankStatementsId varchar(50)
AS
BEGIN

	DELETE
	FROM dbo.BankStatements
	WHERE BankStatementsId IN (SELECT str
			FROM dbo.iter_charlist_to_tbl(@BankStatementsId, ','))

END
GO