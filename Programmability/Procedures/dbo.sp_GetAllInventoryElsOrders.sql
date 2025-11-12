SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--2024-04-26 JF/ 5758: Home button should refresh the QA   add new param ( @UserId)
--2025-07-19 JF/ 6661: Nueva alerta QA Vehicle services PENDING TO RECEIVE
CREATE PROCEDURE [dbo].[sp_GetAllInventoryElsOrders]
(@FromDate       DATETIME = NULL,
 @EndingDate     DATETIME = NULL,
 @InventoryELSId INT      = NULL,
 @AgencyId       INT      = NULL,
 @Status       INT      = NULL,
 @InventoryELSOrderId INT = NULL,
 @UserId INT = NULL
)
AS
     BEGIN

 DECLARE @statusCode NVARCHAR(10);
  SET @statusCode = (SELECT TOP 1
      i.Code
    FROM InventoryELSOrdersStatus i
    WHERE @Status = i.InventoryELSOrdersStatusId)


        SELECT 
		IEO.InventoryELSOrderId, 
		IE.InventoryELSId, 
		IE.Code, 
		IE.Description AS InventoryElsDescription, 
		IEO.OrderedBy, 
		US.Name AS NameOrderedBy, 
		IEO.OrderDate, 
        FORMAT(IEO.OrderDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  OrderDateFormat,
		IE.Description, 
		IEO.Units, a.Code + ' - ' + a.Name AS AgencyName, 
        iels.Code AS StatusCode, 
		iels.Description AS Status, 
		dbo.Users.Name AS SentBy, 
		Users_1.Name AS ClosedBy, 
		IEO.SentDate, 
		FORMAT(IEO.SentDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  SentDateFormat,
		IEO.ClosedDate,
		FORMAT(IEO.ClosedDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  ClosedDateFormat,
		IEO.InventoryFormFileName,
		ia.AgencyId,
		IEO.InventoryELSOrdersStatusId,
		IEO.ClosedUnits,
		IE.IsPersonalInventory,
		ia.InventoryELSByAgencyId
FROM     dbo.InventoryELSOrders AS IEO INNER JOIN
                  dbo.InventoryELSByAgency AS ia ON ia.InventoryELSByAgencyId = IEO.InventoryELSByAgencyId INNER JOIN
                  dbo.InventoryELS AS IE ON ia.InventoryELSId = IE.InventoryELSId INNER JOIN
                  dbo.Users AS US ON IEO.OrderedBy = US.UserId INNER JOIN
                  dbo.Agencies AS a ON ia.AgencyId = a.AgencyId INNER JOIN
                  dbo.InventoryELSOrdersStatus AS iels ON iels.InventoryELSOrdersStatusId = IEO.InventoryELSOrdersStatusId LEFT OUTER JOIN
                  dbo.Users AS Users_1 ON IEO.ClosedBy = Users_1.UserId LEFT OUTER JOIN
                  dbo.Users ON IEO.SentBy = dbo.Users.UserId
         WHERE(IE.InventoryELSId = @InventoryELSId
               OR @InventoryELSId IS NULL)
              AND (CAST(IEO.OrderDate AS DATE) >= CAST(@FromDate AS DATE)
                   OR @FromDate IS NULL)
              AND (CAST(IEO.OrderDate AS DATE) <= CAST(@EndingDate AS DATE)
                   OR @EndingDate IS NULL)
              AND (((IEO.OrderedBy =  @UserId OR @UserId IS NULL) AND @statusCode = 'C02') OR (@statusCode <> 'C02' OR @UserId IS NULL))
         
              AND (IA.AgencyId = @AgencyId
                   OR @AgencyId IS NULL)
				   AND (@Status IS NULL OR @Status = IEO.InventoryELSOrdersStatusId)
				   AND (@InventoryELSOrderId IS NULL OR @InventoryELSOrderId = IEO.InventoryELSOrderId)
     END;
GO