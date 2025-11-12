SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllInventoryOrders]
(@Model      VARCHAR  = NULL,
 @FromDate   DATETIME = NULL,
 @EndingDate DATETIME = NULL,
 @AgencyId   INT = null
)
AS
     BEGIN
         SELECT io.InventoryOrderId,
                io.OrderDate,
				FORMAT(io.OrderDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  OrderDateFormat,
                i.Model,
                i.InventoryId,
                io.Units,
                io.PurchaseValue,
                io.SellingValue,
                u.UserId,
                u.Name NameOrderedBy,
                a.Code+' - '+a.Name AS AgencyName
         FROM InventoryOrders io
              INNER JOIN InventoryByAgency ia ON ia.InventoryByAgencyId = io.InventoryByAgencyId
              INNER JOIN Inventory i ON ia.InventoryId = i.InventoryId
              INNER JOIN Users u ON u.UserId = io.OrderedBy
              INNER JOIN Agencies a ON ia.AgencyId = a.AgencyId
         WHERE(i.Model LIKE '%'+@Model+'%'
               OR @Model IS NULL)
              AND ((CAST(io.OrderDate AS DATE) >= CAST(@FromDate AS DATE)
                    OR @FromDate IS NULL))
              AND ((CAST(io.OrderDate AS DATE) <= CAST(@EndingDate AS DATE)
                    OR @EndingDate IS NULL))
				AND (IA.AgencyId = @AgencyId OR @AgencyId IS NULL)
     END;
GO