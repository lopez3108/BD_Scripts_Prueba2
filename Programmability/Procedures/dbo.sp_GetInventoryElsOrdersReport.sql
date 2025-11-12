SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetInventoryElsOrdersReport]
(
@AgencyId INT,
@StartingDate DATE,
@EndingDate DATE,
@Status INT = 0
)
AS
BEGIN
    
	IF (@Status = 0)    
	BEGIN
		SELECT        
			dbo.InventoryELSAlerts.InventoryELSAlertId, 
			dbo.InventoryELSAlerts.InventoryELSId, 
			dbo.InventoryELS.Description, 
			dbo.InventoryELSAlerts.QuantityOrdered, 
			dbo.InventoryELSAlerts.AgencyId, 
			dbo.Agencies.Name AS AgencyName, 
			dbo.InventoryELSAlerts.CreationDate, 
			FORMAT(InventoryELSAlerts.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
			Users_1.Name AS CreatedBy, 
			dbo.InventoryELSAlerts.ClosedDate, 
			FORMAT(InventoryELSAlerts.ClosedDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  ClosedDateFormat,
			dbo.Users.Name AS ClosedBy,
			CASE WHEN
			dbo.InventoryELSAlerts.ClosedDate IS NULL THEN
			'OPEN' ELSE
			'CLOSED'
			END as Status
		FROM	dbo.InventoryELSAlerts INNER JOIN
			dbo.InventoryELS ON dbo.InventoryELSAlerts.InventoryELSId = dbo.InventoryELS.InventoryELSId INNER JOIN
			dbo.Agencies ON dbo.InventoryELSAlerts.AgencyId = dbo.Agencies.AgencyId INNER JOIN
			dbo.Users AS Users_1 ON dbo.InventoryELSAlerts.CreatedBy = Users_1.UserId LEFT OUTER JOIN
			dbo.Users ON dbo.InventoryELSAlerts.ClosedBy = dbo.Users.UserId
		WHERE InventoryELSAlerts.AgencyId = @AgencyId AND 
			CAST(CreationDate as DATE) >= CAST(@StartingDate as DATE) AND
			CAST(CreationDate as DATE) <= CAST(@EndingDate as DATE) 
		ORDER BY CreationDate DESC
	END
	IF (@Status = 1)    
	BEGIN
		SELECT        
			dbo.InventoryELSAlerts.InventoryELSAlertId, 
			dbo.InventoryELSAlerts.InventoryELSId, 
			dbo.InventoryELS.Description, 
			dbo.InventoryELSAlerts.QuantityOrdered, 
			dbo.InventoryELSAlerts.AgencyId, 
			dbo.Agencies.Name AS AgencyName, 
			dbo.InventoryELSAlerts.CreationDate,
			FORMAT(InventoryELSAlerts.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
			Users_1.Name AS CreatedBy, 
			dbo.InventoryELSAlerts.ClosedDate, 
			FORMAT(InventoryELSAlerts.ClosedDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  ClosedDateFormat,
			dbo.Users.Name AS ClosedBy,
			CASE WHEN
			dbo.InventoryELSAlerts.ClosedDate IS NULL THEN
			'OPEN' ELSE
			'CLOSED'
			END as Status
		FROM	dbo.InventoryELSAlerts INNER JOIN
			dbo.InventoryELS ON dbo.InventoryELSAlerts.InventoryELSId = dbo.InventoryELS.InventoryELSId INNER JOIN
			dbo.Agencies ON dbo.InventoryELSAlerts.AgencyId = dbo.Agencies.AgencyId INNER JOIN
			dbo.Users AS Users_1 ON dbo.InventoryELSAlerts.CreatedBy = Users_1.UserId LEFT OUTER JOIN
			dbo.Users ON dbo.InventoryELSAlerts.ClosedBy = dbo.Users.UserId
		WHERE InventoryELSAlerts.AgencyId = @AgencyId AND 
			CAST(CreationDate as DATE) >= CAST(@StartingDate as DATE) AND
			CAST(CreationDate as DATE) <= CAST(@EndingDate as DATE) AND
			dbo.InventoryELSAlerts.ClosedDate IS NULL
		ORDER BY CreationDate DESC
	END
	IF (@Status = 2)    
	BEGIN
		SELECT        
			dbo.InventoryELSAlerts.InventoryELSAlertId, 
			dbo.InventoryELSAlerts.InventoryELSId, 
			dbo.InventoryELS.Description, 
			dbo.InventoryELSAlerts.QuantityOrdered, 
			dbo.InventoryELSAlerts.AgencyId, 
			dbo.Agencies.Name AS AgencyName, 
			dbo.InventoryELSAlerts.CreationDate, 
			FORMAT(InventoryELSAlerts.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
			Users_1.Name AS CreatedBy, 
			dbo.InventoryELSAlerts.ClosedDate, 
			FORMAT(InventoryELSAlerts.ClosedDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  ClosedDateFormat,
			dbo.Users.Name AS ClosedBy,
			CASE WHEN
			dbo.InventoryELSAlerts.ClosedDate IS NULL THEN
			'OPEN' ELSE
			'CLOSED'
			END as Status
		FROM	dbo.InventoryELSAlerts INNER JOIN
			dbo.InventoryELS ON dbo.InventoryELSAlerts.InventoryELSId = dbo.InventoryELS.InventoryELSId INNER JOIN
			dbo.Agencies ON dbo.InventoryELSAlerts.AgencyId = dbo.Agencies.AgencyId INNER JOIN
			dbo.Users AS Users_1 ON dbo.InventoryELSAlerts.CreatedBy = Users_1.UserId LEFT OUTER JOIN
			dbo.Users ON dbo.InventoryELSAlerts.ClosedBy = dbo.Users.UserId
		WHERE InventoryELSAlerts.AgencyId = @AgencyId AND 
			CAST(CreationDate as DATE) >= CAST(@StartingDate as DATE) AND
			CAST(CreationDate as DATE) <= CAST(@EndingDate as DATE) AND
			dbo.InventoryELSAlerts.ClosedDate IS NOT NULL
		ORDER BY CreationDate DESC
	END

END;
GO