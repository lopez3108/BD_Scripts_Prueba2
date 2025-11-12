SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCashierCommissionsLendifyById ]
(@UserId          INT      = NULL
)
AS
    BEGIN
        SELECT ISNULL(CA.ApplyLendify,0)ApplyLendify
        FROM CashierApplyComissions CA 
		INNER JOIN dbo.Cashiers C ON C.CashierId = CA.CashierId            
        WHERE  C.UserId = @UserId         
       
    END;
GO