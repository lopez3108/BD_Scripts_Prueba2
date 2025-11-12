SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSumBillPaymentsDaily]
(@Creationdate DATE = NULL, 
 @AgencyId     INT, 
 @CreatedBy    INT  = NULL
)
AS
    BEGIN
        SELECT ISNULL(ISNULL(SUM(b.USD), 0) + SUM(ISNULL(b.Commission, 0)), '0') AS Suma
        FROM BillPayments b
        WHERE b.AgencyId = @AgencyId
              AND (CAST(b.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
              AND (b.CreatedBy = @CreatedBy
                   OR @CreatedBy IS NULL);
    END;
GO