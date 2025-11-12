SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		cmontoya
-- Create date: 04Abril2020
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateKyc] 
	@KycId int = NULL,
	@AgencyId int,
	@ProviderId int,
	@OrderNumber varchar(15),
	@ClientName varchar(40),
	@CreationDate datetime,
	@UserId int,
	@Name varchar(150),
	@Extension varchar(25),
	@Usd  decimal(18,2) ,
	@CheckIfExists BIT,
	@LastUpdatedBy INT,
	@LastUpdatedOn DATETIME
AS
BEGIN
	IF (@KycId IS NOT NULL)
	BEGIN
		UPDATE dbo.Kyc
		SET AgencyId = @AgencyId,
		ProviderId = @ProviderId,
		OrderNumber = @OrderNumber,
		ClientName = @ClientName,
		CreationDate = @CreationDate,
		UserId = @UserId,
		Name = @Name,
		Extension = @Extension,
		Usd = @Usd,
		LastUpdatedBy = @LastUpdatedBy,
		LastUpdatedOn = @LastUpdatedOn
		WHERE KycId = @KycId

		SELECT @KycId as ID
	END
	ELSE
	BEGIN

	IF(EXISTS(SELECT TOP 1 KycId FROM dbo.Kyc WHERE 
	ProviderId = @ProviderId AND
	OrderNumber = @OrderNumber AND
	@CheckIfExists = CAST(1 as BIT)))
	BEGIN

	SELECT -1

	END
	ELSE
	BEGIN

	INSERT INTO dbo.Kyc
		(AgencyId, ProviderId, OrderNumber, ClientName, CreationDate, UserId, Name, Extension, Usd, LastUpdatedBy, LastUpdatedOn)
		VALUES
		(@AgencyId, @ProviderId, @OrderNumber, @ClientName, @CreationDate, @UserId, @Name, @Extension, @Usd, @LastUpdatedBy, @LastUpdatedOn)

		SELECT @@IDENTITY


	END




		
	END
END
GO