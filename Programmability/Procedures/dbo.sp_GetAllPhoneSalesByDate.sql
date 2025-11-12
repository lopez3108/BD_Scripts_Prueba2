SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllPhoneSalesByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN
         SELECT SUM(dbo.PhoneSales.SellingValue) + (ISNULL(SUM(dbo.PhoneSales.SellingValue), 0) * (SUM(dbo.PhoneSales.Tax)  / count(dbo.PhoneSales.PhoneSalesId)) / 100) AS USD,
                CAST(dbo.PhoneSales.CreationDate AS DATE) AS Date,
                'PHONE SALES' AS Name
         FROM dbo.PhoneSales
              INNER JOIN dbo.InventoryByAgency ON dbo.PhoneSales.InventoryByAgencyId = dbo.InventoryByAgency.InventoryByAgencyId
         WHERE CAST(dbo.PhoneSales.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.PhoneSales.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
         GROUP BY CAST(dbo.PhoneSales.CreationDate AS DATE);
     END;
GO