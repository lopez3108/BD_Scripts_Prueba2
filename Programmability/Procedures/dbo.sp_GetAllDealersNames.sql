SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllDealersNames]
AS
     BEGIN
         WITH s
              AS (
              SELECT DealerAddress,
                     DealerNumber,
                     DealerName,
                     rn = ROW_NUMBER() OVER(PARTITION BY DealerName ORDER BY CreatedOn DESC)
              FROM
              (
                  SELECT DealerAddress,
                         DealerNumber,
                         DealerName,
                         CreatedOn
                  FROM Financing
                  GROUP BY DealerName,
                           DealerAddress,
                           DealerNumber,
                           CreatedOn
              ) AS s2)
              SELECT  DealerAddress,
                     DealerNumber,
                     DealerName
              FROM s
              WHERE rn <= 1 AND DealerName IS NOT NULL
              ORDER BY DealerName DESC;
     END;
GO