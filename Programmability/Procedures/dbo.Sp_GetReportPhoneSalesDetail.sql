SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Sp_GetReportPhoneSalesDetail]
(@AgencyId INT, 
 @FromDate DATETIME = NULL, 
 @ToDate   DATETIME = NULL, 
 @Date     DATETIME
)
AS
    BEGIN
        IF(@FromDate IS NULL)
            BEGIN
                SET @FromDate = DATEADD(day, -10, @Date);
                SET @ToDate = @Date;
            END;
        IF OBJECT_ID('#TempTablePhoneSalesDetail') IS NOT NULL
            BEGIN
                DROP TABLE #TempTablePhoneSalesDetail;
            END;
        CREATE TABLE #TempTablePhoneSalesDetail
        (RowNumber     INT, 
         Date          DATETIME,
         Type          VARCHAR(80),
         Description   VARCHAR(1000),
         Tax           DECIMAL(18, 2),
         Imei          VARCHAR(10),
         Employee      VARCHAR(80),
         Usd           DECIMAL(18, 2),
         Cost          DECIMAL(18, 2),
         Commission    DECIMAL(18, 2),
         BalanceDetail DECIMAL(18, 2)
        
         --PhoneSalesId  INT
        );
        INSERT INTO #TempTablePhoneSalesDetail
        (RowNumber, 
         Date, 
         Type, 
         Description,
         Tax, 
         Imei,
         Employee,
         Usd, 
         Cost ,
         Commission,
         BalanceDetail
 
         --PhoneSalesId
        )
               SELECT *
               FROM
               (
                   SELECT ROW_NUMBER() OVER(
                          ORDER BY
                                   CAST(Query.Date AS DATE) ASC) RowNumber, 
                          *
                   FROM
                   (
                       SELECT
					   --S.PhoneSalesId, 
                              CAST(S.CreationDate AS DATE) AS Date,	           
                              'PHONE' Type,
                              IV.Model Description,
                              --S.Tax  as  Tax,
							  S.sellingValue * S.tax / 100  as  Tax,
                              S.Imei as Imei,
                              U.Name as Employee,
                              SUM(S.SellingValue) AS Usd,
                              SUM(S.PurchaseValue) AS Cost,				
                              sum(S.SellingValue - S.PurchaseValue) as Commission,
                              S.SellingValue AS BalanceDetail
                              --1 TypeId
                       FROM PhoneSales S
                            INNER JOIN Users U ON S.CreatedBy = U.UserId
                            INNER JOIN Inventorybyagency I ON I.InventoryByAgencyId = S.InventoryByAgencyId
                            INNER JOIN Agencies A ON A.AgencyId = I.AgencyId
                            INNER JOIN Inventory IV ON I.InventoryId = IV.InventoryId
                       WHERE A.AgencyId = @AgencyId
                             AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                  OR @FromDate IS NULL)
                             AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                                  OR @ToDate IS NULL)
                       GROUP BY
					   S.PhoneSalesId, 
                                CAST(S.CreationDate AS DATE),
                       S.Tax,
                       S.Imei,
                       U.Name,
                       S.SellingValue,
                       S.PurchaseValue,
                       IV.Model
                   ) AS Query
               ) AS QueryFinal;
        SELECT *, 
        (
            SELECT SUM(t2.Commission)
            FROM #TempTablePhoneSalesDetail t2
            WHERE T2.RowNumber <= T1.RowNumber
        ) BalanceFinal
        FROM #TempTablePhoneSalesDetail t1
        ORDER BY RowNumber ASC;
    END;
GO