SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllExtraFoundByDate]
(@From      DATE, 
 @To        DATE, 
 @AgencyId  INT, 
 @CreatedBy INT
)
AS
    BEGIN
  --      SELECT ISNULL(SUM(USD) , 0 ) USD
		--,Date,
		--Name
		--FROM (SELECT ISNULL(
  --      (
  --          SELECT ISNULL(SUM(e.Usd), 0) Suma
  --          FROM ExtraFund e
  --          --INNER JOIN Cashiers cc ON cc.CashierId = e.AssignedTo
  --          WHERE CAST(e.CreationDate AS DATE) = CAST(ext.CreationDate AS DATE)
  --                AND (e.AgencyId = @AgencyId)
  --                AND ((e.AssignedTo = @CreatedBy ---recbidos
  --                     )
  --                     AND e.CashAdmin = 0
  --                --AND e.IsCashier = 1
  --                )
  --      )
		----- (
  ----          SELECT ISNULL(SUM(e.Usd), 0) Resta
  ----          FROM ExtraFund e
  ----          --INNER JOIN Cashiers cc ON cc.CashierId = e.CreatedBy
  ----          WHERE CAST(e.CreationDate AS DATE) = CAST(ext.CreationDate AS DATE)
  ----                AND (e.AgencyId = @AgencyId)
  ----                AND (((e.CreatedBy = @CreatedBy ---- hechos cashier to cashier
  ----                      )
  ----                      AND (e.AssignedTo <> @CreatedBy)
  ----                      AND e.IsCashier = 1)
  ----                     OR ((e.CreatedBy = @CreatedBy ---cash for admin hechos
  ----                         )
  ----                         AND e.CashAdmin = 1))

  ----      --                       AND (e.CreatedBy = @CreatedBy)
  ----      --AND ((e.AssignedTo <> @CreatedBy and e.IsCashier = 1 )
  ----      --                 OR E.CashAdmin = 1 )
  ----      )
		--, 0) AS USD,  
  --             CAST(ext.CreationDate AS DATE) AS Date, 
  --             'EXTRA FUND' AS Name
  --      FROM dbo.ExtraFund ext
  --           INNER JOIN Cashiers cc ON cc.UserId = ext.CreatedBy
  --           INNER JOIN Cashiers cr ON cr.UserId = ext.AssignedTo
  --      WHERE CAST(ext.CreationDate AS DATE) >= CAST(@From AS DATE)
  --            AND CAST(ext.CreationDate AS DATE) <= CAST(@To AS DATE)
  --            AND (cc.UserId = @CreatedBy
  --                 OR cr.UserId = @CreatedBy)
  --            AND AgencyId = @AgencyId

		--	--  UNION ALL 
		
  -- --         SELECT -ISNULL(SUM((e.Usd * -1)), 0) USD,
		--	--  CAST(e.CreationDate AS DATE) AS Date, 
  -- --            'EXTRA FUND' AS Name
  -- --         FROM dbo.ExtraFundAgencyToAgency e
  -- --              INNER JOIN Users ua ON ua.UserId = e.AssignedTo
  -- --         WHERE
		--	--CAST(e.CreationDate AS DATE) >= CAST(@From AS DATE)
  -- --           AND CAST(e.CreationDate AS DATE) <= CAST(@To AS DATE)
  -- --              AND (e.FromAgencyId = @AgencyId)
		--	--	   AND ((e.CreatedBy = @CreatedBy) ---made
		--	--	  )
		--	--	    GROUP BY 
		--	--	  CAST(e.CreationDate AS DATE) ,
		--	--	  Name
  -- --    UNION ALL 
  -- --         SELECT ISNULL(SUM((e.Usd * -1)), 0) USD,
		--	--  CAST(e.AcceptedDate AS DATE) AS Date, 
  -- --            'EXTRA FUND' AS Name
  -- --         FROM dbo.ExtraFundAgencyToAgency e
  -- --              INNER JOIN Users ua ON ua.UserId = e.AssignedTo
  -- --         WHERE
		--	--CAST(e.AcceptedDate AS DATE) >= CAST(@From AS DATE)
  -- --           AND CAST(e.AcceptedDate AS DATE) <= CAST(@To AS DATE)
  -- --              AND (e.ToAgencyId = @AgencyId)
		--	--	   AND ((e.AcceptedBy = @CreatedBy) ---received
		--	--	  )
		--	--	  GROUP BY 
		--	--	  CAST(e.AcceptedDate AS DATE) ,
		--	--	  Name
  --      ) AS QUERY 
		--GROUP BY 
		--DATE,
		--Name




--SELECT SUM(ISNULL(q.Usd, 0)) Usd, q.Date, q.Name FROM (	SELECT u.Usd, Date, Name FROM (	  SELECT ISNULL(
--        (
--            SELECT  ISNULL(SUM(e.Usd), 0) Suma
--            FROM ExtraFund e
--            --INNER JOIN Cashiers cc ON cc.CashierId = e.AssignedTo
--            WHERE CAST(e.CreationDate AS DATE) = CAST(ext.CreationDate AS DATE)
--                  AND (e.AgencyId = @AgencyId)
--                  AND ((e.AssignedTo = @CreatedBy ---recbidos
--                       )
--                       AND e.CashAdmin = 0
--                  --AND e.IsCashier = 1
--                  )
--        ) -
--        (
--           ( SELECT  ISNULL(SUM(e.Usd), 0) Resta
--            FROM ExtraFund e
--            --INNER JOIN Cashiers cc ON cc.CashierId = e.CreatedBy
--            WHERE CAST(e.CreationDate AS DATE) = CAST(ext.CreationDate AS DATE)
--                  AND (e.AgencyId = @AgencyId)
--                  AND (((e.CreatedBy = @CreatedBy ---- hechos cashier to cashier
--                        )
--                        AND (e.AssignedTo <> @CreatedBy)
--                        AND e.IsCashier = 1)
--                       OR ((e.CreatedBy = @CreatedBy ---cash for admin hechos
--                           )
--                           AND e.CashAdmin = 1))
--						   GROUP BY e.ExtraFundId)
				

--        --                       AND (e.CreatedBy = @CreatedBy)
--        --AND ((e.AssignedTo <> @CreatedBy and e.IsCashier = 1 )
--        --                 OR E.CashAdmin = 1 )
--        ), 0) AS USD, 
--               CAST(ext.CreationDate AS DATE) AS Date, 
--               'EXTRA FUND' AS Name
--        FROM dbo.ExtraFund ext
--             INNER JOIN Cashiers cc ON cc.UserId = ext.CreatedBy
--             INNER JOIN Cashiers cr ON cr.UserId = ext.AssignedTo
--        WHERE CAST(ext.CreationDate AS DATE) >= CAST(@From AS DATE)
--              AND CAST(ext.CreationDate AS DATE) <= CAST(@To AS DATE)
--              AND (cc.UserId = @CreatedBy
--                   OR cr.UserId = @CreatedBy)
--              AND AgencyId = @AgencyId) u
--UNION ALL


SELECT SUM(Usd) Usd, Date, Name FROM (
 SELECT  
 ISNULL(e.Usd, 0) Usd, 
 CAST(e.CreationDate AS DATE) Date, 
 'EXTRA FUND' Name
            FROM ExtraFund e
            --INNER JOIN Cashiers cc ON cc.CashierId = e.AssignedTo
           WHERE CAST(e.CreationDate AS DATE) >= CAST(@From AS DATE)
              AND CAST(e.CreationDate AS DATE) <= CAST(@To AS DATE)
                  AND (e.AgencyId = @AgencyId)
                  AND ((e.AssignedTo = @CreatedBy ---recbidos
                       )
                       AND e.CashAdmin = 0)
UNION ALL
SELECT  -ISNULL(e.Usd, 0) Usd,
CAST(e.CreationDate as DATE) Date,
'EXTRA FUND' Name
            FROM ExtraFund e
            --INNER JOIN Cashiers cc ON cc.CashierId = e.CreatedBy
          WHERE CAST(e.CreationDate AS DATE) >= CAST(@From AS DATE)
              AND CAST(e.CreationDate AS DATE) <= CAST(@To AS DATE)
                  AND (e.AgencyId = @AgencyId)
                  AND (((e.CreatedBy = @CreatedBy ---- hechos cashier to cashier
                        )
                        AND (e.AssignedTo <> @CreatedBy)
                        AND e.IsCashier = 1)
                       OR ((e.CreatedBy = @CreatedBy ---cash for admin hechos
                           )
                           AND e.CashAdmin = 1))
UNION ALL
			    SELECT 
				ISNULL(e.Usd, 0) USD,
			  CAST(e.CreationDate AS DATE) AS Date, 
               'EXTRA FUND' AS Name
            FROM dbo.ExtraFundAgencyToAgency e
                 INNER JOIN Users ua ON ua.UserId = e.AssignedTo
            WHERE
			CAST(e.CreationDate AS DATE) >= CAST(@From AS DATE)
              AND CAST(e.CreationDate AS DATE) <= CAST(@To AS DATE)
                 AND (e.FromAgencyId = @AgencyId)
				   AND ((e.CreatedBy = @CreatedBy) ---made
				  )
				  UNION ALL
				   SELECT ISNULL((e.Usd * -1), 0) USD,
			  CAST(e.AcceptedDate AS DATE) AS Date, 
               'EXTRA FUND' AS Name
            FROM dbo.ExtraFundAgencyToAgency e
                 INNER JOIN Users ua ON ua.UserId = e.AssignedTo
            WHERE
			CAST(e.AcceptedDate AS DATE) >= CAST(@From AS DATE)
              AND CAST(e.AcceptedDate AS DATE) <= CAST(@To AS DATE)
                 AND (e.ToAgencyId = @AgencyId)
				   AND ((e.AcceptedBy = @CreatedBy) ---received
				  )) q
				  Group by
				  Date,
				  Name
              
    END;
GO