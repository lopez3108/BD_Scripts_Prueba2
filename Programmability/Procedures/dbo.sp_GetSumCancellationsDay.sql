SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSumCancellationsDay] @UserId       INT      = NULL,
                                                  @AgencyId     INT      = NULL,
                                                  @CreationDate DATETIME = NULL
AS
     BEGIN

	 -- Refunds
         DECLARE @refundAmount DECIMAL(18, 2) = 0;
         SET @refundAmount =
         (
             SELECT ISNULL(SUM(TotalTransaction), 0)
             FROM Cancellations INNER JOIN CancellationStatus ON 
             Cancellations.FinalStatusId =CancellationStatus.CancellationStatusId
            --   AND Cancellations.FinalStatusId IS NOT NULL
             WHERE CAST(RefundDate AS DATE) = CAST(@CreationDate AS DATE)
			       AND (Cancellations.FinalStatusId IS NOT NULL AND CancellationStatus.Code = 'C01'                  )
                   AND AgencyId = @AgencyId 
                   AND ((ChangedBy = @UserId OR @UserId IS NULL))
                   
                   

         );

	    	  --Refunds fee
         DECLARE @refundFee DECIMAL(18, 2) = 0;
         SET @refundFee =
         (
             SELECT ISNULL(SUM(Fee), 0)
             FROM Cancellations INNER JOIN CancellationStatus ON
             Cancellations.FinalStatusId =CancellationStatus.CancellationStatusId 
            --  AND Cancellations.FinalStatusId IS NOT NULL
             WHERE CAST(RefundDate AS DATE) = CAST(@CreationDate AS DATE)
			       AND (Cancellations.FinalStatusId IS NOT NULL AND CancellationStatus.Code = 'C01'                  )
                --    AND Cancellations.FinalStatusId <> NULL
                   AND AgencyId = @AgencyId
                   AND (ChangedBy = @UserId OR @UserId IS NULL)
				                      AND RefundFee = 1
         );

	 -- New transaction
         DECLARE @newTrans DECIMAL(18, 2) = 0;
         SET @newTrans =
         (
             SELECT ISNULL(SUM(TotalTransaction + Fee), 0)
             FROM Cancellations INNER JOIN CancellationStatus ON
             Cancellations.FinalStatusId =CancellationStatus.CancellationStatusId
            --   AND Cancellations.FinalStatusId IS NOT NULL
             WHERE CAST(NewTransactionDate AS DATE) = CAST(@CreationDate AS DATE)
			       AND (Cancellations.FinalStatusId IS NOT NULL AND CancellationStatus.Code = 'C02'                  )
                --    AND Cancellations.FinalStatusId <> NULL
                   AND AgencyId = @AgencyId
                   AND (ChangedBy = @UserId OR @UserId IS NULL)
				   
         );
         SELECT CAST(ISNULL(@refundAmount + @refundFee + @newTrans, 0) AS VARCHAR(30)) AS moneyvalue,
                'true' AS Disabled,
                'true' AS OnlyNegative,
                'true' 'Set'; 

	

     --    SELECT CAST(SUM(QUERY.TotalTransaction) AS VARCHAR(30)) AS 'moneyvalue',
     --           'true' AS 'Disabled'
     --    FROM
     --    (
	    ----REFUND
     --        SELECT SUM(C.TotalTransaction) AS 'TotalTransaction'
     --        FROM Cancellations c
     --             INNER JOIN CancellationStatus cs ON c.InitialStatusId = cs.CancellationStatusId
     --             INNER JOIN Providers pc ON pc.ProviderId = C.ProviderCancelledId
     --             INNER JOIN ProviderTypes pct ON pct.ProviderTypeId = pc.ProviderTypeId
     --             LEFT JOIN CancellationStatus csf ON c.FinalStatusId = csf.CancellationStatusId
     --             LEFT JOIN Providers pn ON pn.ProviderId = C.ProviderNewId
     --             LEFT JOIN ProviderTypes pnt ON pnt.ProviderTypeId = pn.ProviderTypeId
     --        WHERE CAST(c.CancellationDate AS DATE) = CAST(GETDATE() AS DATE)
     --              AND csf.Code = 'C03'

	    ----NEW TRANSACTION
     --        UNION ALL
     --        SELECT SUM(C.TotalTransaction) + C.Fee AS 'TotalTransaction'
     --        FROM Cancellations c
     --             INNER JOIN CancellationStatus cs ON c.InitialStatusId = cs.CancellationStatusId
     --             INNER JOIN Providers pc ON pc.ProviderId = C.ProviderCancelledId
     --             INNER JOIN ProviderTypes pct ON pct.ProviderTypeId = pc.ProviderTypeId
     --             LEFT JOIN CancellationStatus csf ON c.FinalStatusId = csf.CancellationStatusId
     --             LEFT JOIN Providers pn ON pn.ProviderId = C.ProviderNewId
     --             LEFT JOIN ProviderTypes pnt ON pnt.ProviderTypeId = pn.ProviderTypeId
     --        WHERE CAST(c.CancellationDate AS DATE) = CAST(GETDATE() AS DATE)
     --              AND csf.Code = 'C02'
			  --  GROUP BY C.TotalTransaction , C.Fee
     --    ) AS QUERY;
     END;
GO