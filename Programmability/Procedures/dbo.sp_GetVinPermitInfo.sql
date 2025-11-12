SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- ===================================================
-- Author:		Juan Felipe Oquendo López 
-- Create date: 2021-12-29
-- Description:	Trae los estados de la orden.
-- ===================================================
CREATE PROCEDURE [dbo].[sp_GetVinPermitInfo]
(@VinNumber AS   VARCHAR(17) = NULL, 
@Code AS   VARCHAR(3) = NULL, 
 @CurrentDate AS DATETIME
)
AS
     SET NOCOUNT ON;
    BEGIN
        SELECT T.CreatedOn DatePurchase, 
               T.ClientName, 
               V.Description, 
               v.Code
        FROM TRP T
             INNER JOIN VinPertmitStatus V ON V.VinPertmitTrpId = T.VinPertmitTrpId
        WHERE(t.VinNumber = @VinNumber) AND (v.Code = @Code OR @Code IS NULL)
             AND (((CAST(t.CreatedOn AS DATE) >= CAST(DATEADD(year, -1, @CurrentDate) AS DATE)))
                  AND ((CAST(t.CreatedOn AS DATE) <= CAST(@CurrentDate AS DATE))));
    END;

GO