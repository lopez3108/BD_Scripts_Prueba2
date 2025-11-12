SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =========================================================
-- Author:		Juan Felipe Oquendo López 
-- Create date: 2021-12-28
-- Description:	Get que trae Orders X office supplies.
-- =========================================================
CREATE PROCEDURE [dbo].[sp_GetOrdersOfficeSupplies]
(@Name                     VARCHAR(200)  = NULL, 
 @ProvidersOfficeSuppliesId VARCHAR(1000) = NULL, 
 @DateFrom                 DATE = NULL, 
 @ToDate                   DATE = NULL, 
 @OrdersOfficeStatusId     INT           = NULL,
 @ListAgenciId VARCHAR(1000) = NULL
)
AS
     DECLARE @NumberOfSeconds INT;
    BEGIN
        SELECT DISTINCT
               oo.OrderDate AS CreationDate,
			    FORMAT(oo.OrderDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  OrderDateFormat,
               op.Name AS Product, 
        --(
        --    SELECT [dbo].[fn_GetAgenciesXOrdersSupplies](Od.OrderOfficeSupplieId)
        --) Agencies, 
		a.Code +' - '+a.Name as AgencyName,
        (
            SELECT [dbo].[fn_GetPrividerSupplyNames](od.OfficeSupplieId)
        ) Provider, 
               os.Description AS StatusName, 
               u.Name AS CreatedByName, 
               --oo.LastUpdated, 
               --ul.Name AS LastUpdatedByName, 
			   od.OrderOfficeSuppliesDetailsId,
               od.SentOn, 
			   FORMAT(od.SentOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  SentOnFormat,
			   od.SentBy, 
               us.Name AS SentByName, 
               od.CompletedOn, 
			    FORMAT(od.CompletedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CompletedOnFormat,
			   od.CompletedBy,
               uc.Name AS CompletedtByName,
			   od.Status,
			   os.Code OrderStatusCode,
			   od.Quantity,
			   od.Quantity InitialQuantity,
			   --od.Note,
			   a.AgencyId,
			   op.OfficeSupplieId,
			   od.OrderOfficeSupplieId,
			   --u.Name AS RefundByName, 
			   -- oo.OrderDate AS RefundOn, 
				  od.RefundDate as CompletedRefundOn, 
				  FORMAT( od.RefundDate, 'MM-dd-yyyy', 'en-US')  RefundDateOnFormat,
				 ur.Name AS CompletedRefundByName
 FROM OrderOfficeSuppliesDetails od
             INNER JOIN  OrdersOfficeSupplies oo ON od.OrderOfficeSupplieId = oo.OrderOfficeSupplieId
             INNER JOIN OfficeSupplies op ON op.OfficeSupplieId = od.OfficeSupplieId
             INNER JOIN ProvidersXOfficeSupplies po ON po.OfficeSupplieId = op.OfficeSupplieId
             INNER JOIN OrdersOfficeStatus os ON os.OrdersOfficeStatusId = od.STATUS
             LEFT JOIN dbo.Users U ON oo.CreatedBy = U.UserId
             --LEFT JOIN dbo.Users UL ON oo.LastUpdatedBy = UL.UserId
             LEFT JOIN dbo.Users Us ON od.SentBy = Us.UserId
             LEFT JOIN dbo.Users Uc ON od.CompletedBy = Uc.UserId
			   LEFT JOIN dbo.Users Ur ON od.CompletedRefundBy = Ur.UserId
			 LEFT JOIN Agencies a on a.AgencyId = od.AgencyId
			 WHERE(Op.Name LIKE '%' + @Name + '%'
              OR @Name IS NULL)
             AND (po.ProvidersOfficeSuppliesId IN
        (
            SELECT item
            FROM dbo.FN_ListToTableInt(@ProvidersOfficeSuppliesId)
        )
        OR @ProvidersOfficeSuppliesId IS NULL)
		    AND (OD.AgencyId IN
        (
            SELECT item
            FROM dbo.FN_ListToTableInt(@ListAgenciId)
        )
        OR @ListAgenciId IS NULL)
             AND (CAST(oo.Orderdate AS DATE) >= CAST(@DateFrom AS DATE) OR @DateFrom IS NULL)
             AND (CAST(oo.Orderdate AS DATE) <= CAST(@ToDate AS DATE) OR @ToDate IS NULL)
        AND (Od.Status = @OrdersOfficeStatusId  OR @OrdersOfficeStatusId  IS NULL)
        ORDER BY oo.Orderdate DESC;
       
    END;
GO