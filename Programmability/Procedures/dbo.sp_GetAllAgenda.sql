SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllAgenda] @FromDate DATE = NULL,
@ToDate DATE = NULL,
@AgendaStatusId INT = NULL,
@Description VARCHAR(400) = NULL,
@CodeAgendaStatus VARCHAR(5) = NULL,
@UserId INT
AS
BEGIN
	DECLARE @StatusPendingDescription VARCHAR(100)
		   ,@StatusPendingCode VARCHAR(5)
		   ,@StatusPendingId INT;
	(SELECT
		@StatusPendingDescription = Name
	   ,@StatusPendingCode = Code
	   ,@StatusPendingId = AgendaStatusId
	FROM AgendaStatus [as]
	WHERE Code = 'C01')
	IF @CodeAgendaStatus IS NULL
		AND @AgendaStatusId IS NOT NULL
	BEGIN
		SELECT
			@CodeAgendaStatus = Code
		FROM AgendaStatus [as]
		WHERE [as].AgendaStatusId = @AgendaStatusId
	END
	ELSE
	IF @AgendaStatusId IS NOT NULL
	BEGIN
		SET @AgendaStatusId = (SELECT
				[as].AgendaStatusId
			FROM AgendaStatus [as]
			WHERE [as].Code = @CodeAgendaStatus)

	END

	ELSE
	IF @CodeAgendaStatus IS NOT NULL
	BEGIN
		SET @AgendaStatusId = (SELECT
				[as].AgendaStatusId
			FROM AgendaStatus [as]
			WHERE [as].Code = @CodeAgendaStatus)

	END
	SELECT
		a.AgendaId
	   ,a.CreationDate
     ,FORMAT(a.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat 
	   ,UPPER(a.Description) as Description
	   ,CASE
			WHEN 
			(a.CreatedBy <> @UserId AND a.DelegateTo = @UserId
			OR a.DelegateTo = @UserId) AND [as].Code = 'C03' THEN @StatusPendingDescription
			ELSE UPPER([as].Name)
		END
		as [Name]
	   ,CASE
			WHEN 	(a.CreatedBy <> @UserId AND a.DelegateTo = @UserId
			OR a.DelegateTo = @UserId) AND [as].Code = 'C03' THEN @StatusPendingId
			ELSE UPPER([as].AgendaStatusId)
		END
		as AgendaStatusId
	   ,CASE
			WHEN 	(a.CreatedBy <> @UserId AND a.DelegateTo = @UserId
			OR a.DelegateTo = @UserId) AND [as].Code = 'C03' THEN @StatusPendingCode
			ELSE UPPER([as].Code)
		END
		as Code
	   ,a.FileIdNameAgendaCopy
	   ,a.UpdateBy
	   ,a.UpdateOn as UpdateOn
     ,FORMAT(a.UpdateOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') UpdateOnFormat 
	   ,s.Name as DelegateToName
	   ,u.Name as UpdateByName
	   ,p.Name as DelegateByName
	   ,c.Name as CreateBY
	   ,a.DelegateBy
	   ,a.DelegateTo 
	   ,@CodeAgendaStatus
	FROM Agendas a
	JOIN AgendaStatus [as]
		ON a.AgendaStatusId = [as].AgendaStatusId
	LEFT JOIN Users u
		ON u.UserId = a.UpdateBy
	LEFT JOIN Users s
		ON s.UserId = a.DelegateTo
	LEFT JOIN Users p
		ON p.UserId = a.DelegateBy
			LEFT JOIN Users c
		ON c.UserId = a.CreatedBy
	WHERE ((CAST(a.CreationDate as DATE) >= CAST(@FromDate as DATE)
	OR @FromDate IS NULL)
	AND (CAST(a.CreationDate as DATE) <= CAST(@ToDate as DATE))
	OR @ToDate IS NULL)
	AND (a.Description LIKE '%' + @Description + '%'
	OR @Description IS NULL)

	--TO DO Felipe comentar estas condiciones
	AND (((((a.CreatedBy = @UserId AND  a.DelegateTo <> @UserId ) OR a.CreatedBy = @UserId AND [as].Code <> 'C03')

	AND (([as].Code = @CodeAgendaStatus
	OR @CodeAgendaStatus IS NULL)
	OR ([as].AgendaStatusId = @AgendaStatusId
	OR @AgendaStatusId IS NULL)))

	OR ([as].Code = 'C03'
	AND(( a.CreatedBy <> @UserId	
	AND a.DelegateTo = @UserId) 
	OR a.DelegateTo = @UserId
	)
	AND (@CodeAgendaStatus = 'C01'
	OR @CodeAgendaStatus IS NULL))

	OR ([as].Code = 'C02'
	AND a.CreatedBy <> @UserId
	AND a.DelegateTo = @UserId
	AND (@CodeAgendaStatus = 'C02'
	OR @CodeAgendaStatus IS NULL))
	))

	ORDER BY a.CreationDate DESC;

END;

GO