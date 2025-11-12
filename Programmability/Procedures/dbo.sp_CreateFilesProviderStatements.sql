SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		Felipe oquendo Lopez
-- Create date: 21Marzo2023
-- Tarea 5012
-- Description:	<Description,MODULO COMPLIANCE-STATEMENT PROVIDERS SENT 04-15-2023>
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreateFilesProviderStatements]
	@ProviderStatementsId int = NULL,
	@Year int,
	@Month int,
  @ProviderId int,
--	@BankId int,
--	@Account int,
  @AgencyId INT,
	@CreationDate datetime,
	@UserId int,
	@Name varchar(150),
	@Extension varchar(25),
	@SameTransaction bit
AS
BEGIN

	IF(@SameTransaction = 1)
	BEGIN
		INSERT INTO dbo.ProviderStatements
		(Year, Month, AgencyId, ProviderId, CreationDate, UserId, Name, Extension)
		VALUES
		(@Year, @Month, @AgencyId, @ProviderId ,  @CreationDate, @UserId, @Name, @Extension)

		SELECT @@IDENTITY as ID
	END
	ELSE
	BEGIN

	IF( (SELECT COUNT(*) FROM ProviderStatements WHERE  YEAR = @Year AND Month = @Month AND ProviderId = @ProviderId AND AgencyId = @AgencyId ) > 0 )
  	
		BEGIN
		SELECT -2 as ID
		END

		ELSE
		BEGIN
		INSERT INTO dbo.ProviderStatements
		(Year, Month, AgencyId, ProviderId, CreationDate, UserId, Name, Extension)
		VALUES
		(@Year, @Month, @AgencyId, @ProviderId ,  @CreationDate, @UserId, @Name, @Extension)
		SELECT @@IDENTITY as ID
		END
	END



END


GO