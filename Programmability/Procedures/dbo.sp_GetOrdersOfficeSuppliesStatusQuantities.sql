SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =========================================================
-- Author:		John García
-- Create date: 2021-12-28
-- Description:	Get number quantities status
-- =========================================================
CREATE PROCEDURE [dbo].[sp_GetOrdersOfficeSuppliesStatusQuantities](@ListAgenciId VARCHAR(1000) = NULL)
AS
     DECLARE @NumberOfSeconds INT;
    BEGIN
        SELECT COUNT(*) QuantityPending, 
               NULL QuantitySent,
			   null QuantityRefund
        FROM OrderOfficeSuppliesDetails od
             INNER JOIN OrdersOfficeStatus os ON os.OrdersOfficeStatusId = od.Status
        WHERE(od.AgencyId IN
        (
            SELECT item
            FROM dbo.FN_ListToTableInt(@ListAgenciId)
        )
        OR @ListAgenciId IS NULL)
             AND os.Code = 'C01'
        UNION ALL
        SELECT NULL QuantityPending, 
               COUNT(*) QuantitySent,
			   null QuantityRefund
       FROM OrderOfficeSuppliesDetails od
             INNER JOIN OrdersOfficeStatus os ON os.OrdersOfficeStatusId = od.Status
        WHERE(od.AgencyId IN
        (
            SELECT item
            FROM dbo.FN_ListToTableInt(@ListAgenciId)
        )
        OR @ListAgenciId IS NULL)
             AND os.Code = 'C02'
			  UNION ALL
        SELECT NULL QuantityPending, 
		  NULL QuantitySent,
               COUNT(*) QuantityRefund
       FROM OrderOfficeSuppliesDetails od
             INNER JOIN  OrdersOfficeStatus os ON os.OrdersOfficeStatusId = od.Status
        WHERE(od.AgencyId IN
        (
            SELECT item
            FROM dbo.FN_ListToTableInt(@ListAgenciId)
        )
        OR @ListAgenciId IS NULL)
             AND os.Code = 'C04';
    END;
GO