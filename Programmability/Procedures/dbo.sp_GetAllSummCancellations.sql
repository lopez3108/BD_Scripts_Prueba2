SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- UpdatedBy JF / UpdatedOn 4-May-2024 / Task 5837 New QA CANCELLATIONS (PENDING) '@AgencyId INT = NULL' 

CREATE PROCEDURE [dbo].[sp_GetAllSummCancellations] (

                                            @ClientName             VARCHAR(200) = NULL,
                                            @ReceiptCancelledNumber VARCHAR(10)  = NULL,
                                            @UserId                  INT          = NULL,
                                            @FromDate               DATETIME     = NULL,
                                            @ToDate                 DATETIME     = NULL,
                                            @AgencyId               INT = NULL,
                                            @ListStatusId     VARCHAR(500) = NULL )
AS
     BEGIN
         SELECT ISNULL(SUM(c.TotalTransaction), 0) TotalTransaction,
                ISNULL(SUM(c.Fee), 0) Fee,
                ISNULL(SUM(c.TotalTransaction), 0) + ISNULL(SUM(c.Fee), 0) GrandTotal
         FROM Cancellations c
              INNER JOIN CancellationStatus cs ON c.InitialStatusId = cs.CancellationStatusId
              INNER JOIN Providers pc ON pc.ProviderId = C.ProviderCancelledId
              INNER JOIN ProviderTypes pct ON pct.ProviderTypeId = pc.ProviderTypeId
              INNER JOIN Users ucreate ON ucreate.UserId = c.CreatedBy
              INNER JOIN NotesxCancellations nc ON nc.NoteXCancellationId = c.NoteXCancellationId
              INNER JOIN Agencies a ON a.AgencyId = c.AgencyId
              LEFT JOIN Users uchange ON uchange.UserId = c.ChangedBy
              LEFT JOIN CancellationStatus csf ON c.FinalStatusId = csf.CancellationStatusId
              LEFT JOIN Providers pn ON pn.ProviderId = C.ProviderNewId
              LEFT JOIN ProviderTypes pnt ON pnt.ProviderTypeId = pn.ProviderTypeId
         WHERE(C.ClientName LIKE '%'+@ClientName+'%'
               OR @ClientName IS NULL)
              AND ((C.ReceiptCancelledNumber LIKE '%'+@ReceiptCancelledNumber+'%'
                    OR @ReceiptCancelledNumber IS NULL)
                   OR (C.ReceiptNewNumber LIKE '%'+@ReceiptCancelledNumber+'%'
                       OR @ReceiptCancelledNumber IS NULL))
			  AND ((((cs.Code = 'C02' OR cs.Code = 'C01' ) AND  C.ChangedBy = @UserId) OR c.FinalStatusId = NULL AND c.CreatedBy = @UserId)
                    OR @UserId IS NULL)
              --AND (C.InitialStatusId = @CancellationStatusId
              --      OR @CancellationStatusId IS NULL)
              --     OR (C.FinalStatusId = @CancellationStatusId
              --         OR @CancellationStatusId IS NULL))
			   AND ((c.InitialStatusId IN
        (
            SELECT item
            FROM dbo.FN_ListToTableInt(@ListStatusId)
        )
        OR @ListStatusId IS NULL)
		OR (c.FinalStatusId IN
        (
            SELECT item
            FROM dbo.FN_ListToTableInt(@ListStatusId)
        )
        OR @ListStatusId IS NULL)
		)
              AND ((CAST(C.CancellationDate AS DATE) >= CAST(@FromDate AS DATE)
                    OR @FromDate IS NULL)
                   AND (CAST(c.CancellationDate AS DATE) <= CAST(@ToDate AS DATE))
                   OR @ToDate IS NULL)
              AND c.AgencyId = CASE
                                   WHEN @AgencyId IS NULL
                                   THEN c.AgencyId
                                   ELSE @AgencyId
                               END
     END;
GO