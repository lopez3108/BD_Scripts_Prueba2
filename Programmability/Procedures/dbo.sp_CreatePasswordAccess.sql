SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreatePasswordAccess]
(
	@PassAccessId int = null,
	@UserId int,
	@OwnerUserId int,
	@FromDate datetime,
	@ToDate datetime,
	@AgencyId int = null,
	@CreationDate datetime,
	@CreatedBy int
)
AS 

BEGIN
DECLARE @1 date
SET @1=(SELECT CAST(@CreationDate AS DATE))
	--IF EXISTS (SELECT * FROM [dbo].[PassAccess] 
	--		WHERE UserId = @UserId AND OwnerUserId = @OwnerUserId AND AgencyId = @AgencyId)
	--			--AND (@current between @FromDate AND @ToDate))
	--	SELECT -1
	IF EXISTS (SELECT 1
		FROM [dbo].[PassAccess]
		WHERE UserId = @UserId AND OwnerUserId = @OwnerUserId AND AgencyId = @AgencyId AND 
		@1 BETWEEN CAST(FromDate AS DATE) AND CAST(ToDate AS DATE))
		SELECT -1
	ELSE IF EXISTS (SELECT 1
		FROM [dbo].[PassAccess]
		WHERE  UserId = @UserId AND AgencyId = @AgencyId AND  ((CAST(@FromDate AS DATE) <= CAST(FromDate AS DATE) AND CAST(@ToDate AS DATE) <= CAST(ToDate AS DATE) AND CAST(@ToDate AS DATE) >= CAST(FromDate AS DATE)) OR
			   (CAST(@FromDate AS DATE) >= CAST(FromDate AS DATE) AND CAST(@ToDate AS DATE) <= CAST(ToDate AS DATE)) OR
			   (CAST(@FromDate AS DATE) >= CAST(FromDate AS DATE) AND CAST(@ToDate AS DATE) >= CAST(ToDate AS DATE) AND CAST(@FromDate AS DATE) <= CAST(ToDate AS DATE))OR 
			   (CAST(@FromDate AS DATE) <= CAST(FromDate AS DATE) AND CAST(@ToDate AS DATE) >= CAST(ToDate AS DATE)))) 
	
		SELECT -2
	ELSE IF(@PassAccessId IS NULL)
	BEGIN

		INSERT INTO [dbo].[PassAccess]
		VALUES (@UserId,
				@OwnerUserId,
				@FromDate,
				@ToDate,
				@AgencyId,
				@CreationDate,
				@CreatedBy)

		SELECT @@IDENTITY

	END
	ELSE
	BEGIN

		UPDATE [dbo].[PassAccess]
		SET OwnerUserId = @OwnerUserId,
		  AgencyId = @AgencyId,
		  FromDate = @FromDate,
		  ToDate = @ToDate
		WHERE PassAccessId = @PassAccessId

		SELECT @PassAccessId

	END

END

--declare @1 date
--set @1=(select CAST(getdate() AS DATE))
--exec [dbo].[sp_CreatePasswordAccess] @PassAccessId=null,
--	@UserId=121,
--	@OwnerUserId=73,
--	@FromDate='2019-02-26 00:00:00.000',
--	@ToDate='2019-02-28 00:00:00.000',
--	@AgencyId=1,
--	@CreationDate=@1,
--	@CreatedBy=1
GO