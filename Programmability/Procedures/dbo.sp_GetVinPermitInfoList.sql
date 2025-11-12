SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- ===================================================
-- Author:		Juan Felipe Oquendo López 
-- Create date: 2021-12-29
-- Description:	Trae los estados de la orden.
-- ===================================================
CREATE PROCEDURE [dbo].[sp_GetVinPermitInfoList]
(@VinNumber  varchar(17))
AS
     SET NOCOUNT ON;
    BEGIN
        SELECT DISTINCT
               T.VinNumber
        FROM TRP T
            
        WHERE VinNumber LIKE '%' + @VinNumber + '%'
        --OR @VinNumber is NOT NULL

       
    END;
GO