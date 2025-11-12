SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllCancellationsByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN
         DECLARE @result TABLE
         (Date DATETIME,
          USD  DECIMAL(18, 2),
          Name VARCHAR(50)
         );

	 -- Refunds

         INSERT INTO @result
                SELECT CAST(RefundDate AS DATE) AS DATE,
                       TotalTransaction AS USD,
                       'CANCELLATIONS' AS Name
                FROM Cancellations INNER JOIN CancellationStatus ON 
             Cancellations.FinalStatusId =CancellationStatus.CancellationStatusId
                WHERE (Cancellations.FinalStatusId IS NOT NULL AND CancellationStatus.Code = 'C01')
                      AND AgencyId = @AgencyId
                      AND CAST(RefundDate AS DATE) >= CAST(@From AS DATE)
                      AND CAST(RefundDate AS DATE) <= CAST(@To AS DATE)
                      AND ((ChangedBy = @CreatedBy OR @CreatedBy IS NULL))
                UNION ALL
                SELECT CAST(RefundDate AS DATE) AS DATE,
                       Fee AS USD,
                       'CANCELLATIONS' AS Name
                FROM Cancellations 	INNER JOIN CancellationStatus ON
             Cancellations.FinalStatusId =CancellationStatus.CancellationStatusId 
                WHERE CancellationStatus.Code = 'C01' 
                      AND AgencyId = @AgencyId
					AND (ChangedBy = @CreatedBy OR @CreatedBy IS NULL)
					AND CAST(RefundDate AS DATE) >= CAST(@From AS DATE)
                      AND CAST(RefundDate AS DATE) <= CAST(@To AS DATE)
                      AND RefundFee = 1
                UNION ALL
                SELECT CAST(NewTransactionDate AS DATE) AS DATE,
                       TotalTransaction + Fee AS USD,
                       'CANCELLATIONS' AS Name
                FROM Cancellations
				INNER JOIN CancellationStatus ON
             Cancellations.FinalStatusId =CancellationStatus.CancellationStatusId 
                WHERE CancellationStatus.Code = 'C02' 
                      AND AgencyId = @AgencyId
                      AND (ChangedBy = @CreatedBy OR @CreatedBy IS NULL)
                      AND CAST(NewTransactionDate AS DATE) >= CAST(@From AS DATE)
                      AND CAST(NewTransactionDate AS DATE) <= CAST(@To AS DATE);
         SELECT -SUM(ABS(USD)) AS USD,
                Name,
                CAST(Date AS DATE) AS Date
         FROM @result
         GROUP BY Name,
                  CAST(DATE AS DATE);
     END;
GO