SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		cmontoya
-- Create date: 11Mayo2020
-- Description:	<Description,,>
-- =============================================
/*
	EXEC [dbo].[sp_CreateFilesBankStatements]
	@BankStatementsId = NULL,
	@Year = 2020,
	@Month = 1,
	@BankId = 21,
	@Account = 60,
	@Agencies = '13,22',
	@CreationDate = '2020-05-11',
	@UserId = 237,
	@Name = 'Ejemplo.pdf',
	@Extension = 'pdf'
*/
CREATE PROCEDURE [dbo].[sp_CreateFilesBankStatements] 
	@BankStatementsId int = NULL,
	@Year int,
	@Month int,
	@BankId int,
	@Account int,
	@Agencies varchar(100),
	@CreationDate datetime,
	@UserId int,
	@Name varchar(150),
	@Extension varchar(25),
	@SameTransaction bit
AS
BEGIN

	IF(@SameTransaction = 1)
	BEGIN
		INSERT INTO dbo.BankStatements
		(Year, Month, Agencies, Bank, Account, CreationDate, UserId, Name, Extension)
		VALUES
		(@Year, @Month, @Agencies, @BankId, @Account, @CreationDate, @UserId, @Name, @Extension)

		SELECT @@IDENTITY as ID
	END
	ELSE
	BEGIN
		IF((SELECT COUNT(*) 
		FROM dbo.iter_charlist_to_tbl(
			(SELECT DISTINCT Agencies 
				FROM BankStatements
				WHERE YEAR = @Year
				AND Month = @Month
				AND Bank = @BankId
				AND Account = @Account), ',') b
		INNER JOIN (
			SELECT str
			FROM dbo.iter_charlist_to_tbl(@Agencies, ',')
			) r ON r.str = b.str) > 0)
		BEGIN
		SELECT -2 as ID
		END
		ELSE
		BEGIN
		INSERT INTO dbo.BankStatements
		(Year, Month, Agencies, Bank, Account, CreationDate, UserId, Name, Extension)
		VALUES
		(@Year, @Month, @Agencies, @BankId, @Account, @CreationDate, @UserId, @Name, @Extension)

		SELECT @@IDENTITY as ID
		END
	END

	


	--IF (@BankStatementsId IS NOT NULL)
	--BEGIN
	--	UPDATE dbo.BankStatements
	--	SET Year = @Year,
	--	Month = @Month,
	--	Agencies = @Agencies,
	--	Bank = @BankId,
	--	Account = @Account,
	--	CreationDate = @CreationDate,
	--	UserId = @UserId,
	--	Name = @Name,
	--	Extension = @Extension
	--	WHERE BankStatementsId = @BankStatementsId

	--	SELECT @BankStatementsId as ID
	--END
END
GO