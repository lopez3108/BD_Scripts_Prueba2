SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- ===================================================
-- Author:		Juan Felipe Oquendo López 
-- Create date: 2021-03-02
-- Description: trae los numeros perimitidos que esten repetidos para los TRP 
-- ===================================================
CREATE PROCEDURE [dbo].[sp_GetValidatePermitNumber]
(@PermitNumber  varchar(20), @TRPId INT = NULL)
AS     
    BEGIN
        SELECT 
               T.PermitNumber
        FROM TRP T
            
        WHERE ( T.TRPId != @TRPId OR @TRPId IS NULL ) AND T.PermitNumber = @PermitNumber
       
    END;

GO