SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllHeadphonesAndChargeByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN
         SELECT SUM(ISNULL(ChargersUsd,0) + ISNULL(HeadphonesUsd, 0)) AS USD,
                CAST(dbo.HeadphonesAndChargers.CreationDate AS DATE) AS Date,
                'HEADPHONES AND CHARGERS' AS Name
         FROM dbo.HeadphonesAndChargers
         WHERE CAST(dbo.HeadphonesAndChargers.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.HeadphonesAndChargers.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
         GROUP BY CAST(dbo.HeadphonesAndChargers.CreationDate AS DATE);
     END;
GO