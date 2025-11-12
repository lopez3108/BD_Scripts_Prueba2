SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetExpiredMsbFiles]
(@UserId INT = NULL,  @CurrentDate DATETIME

)
AS
    BEGIN
       
        DECLARE @Date AS DATE;
        SET @Date = @CurrentDate;
        SELECT *
        FROM
        (
            SELECT *, 
                   DATEDIFF(DAY, @Date, Query1.ExpirationDate ) Direfence
            FROM
            (
		
                SELECT TOP 1 *
                FROM Msb M
				INNER JOIN Cashiers C ON C.UserId = M.CreatedBy
                INNER JOIN RolCompliance R ON R.RolComplianceId = C.ComplianceRol
                WHERE  R.Code = 'C02'
                      AND C.IsAdmin = 1
				ORDER BY M.MsbId DESC
            ) AS Query1
        ) AS Query2
        WHERE Query2.Direfence <= 30
        
    END;
GO