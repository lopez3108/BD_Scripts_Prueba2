SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllPayrollsByUserByDate]
(
 @Date   DATETIME,
 @CashierId    INT     
)
AS
     BEGIN
         SELECT DISTINCT
                p.*,
                U.Name
         FROM Payrolls P
              INNER JOIN Users U ON U.UserId = P.UserId
		    INNER JOIN Cashiers C ON C.UserId = U.UserId 
         WHERE CAST(@Date AS DATE) >=  CAST(P.FromDate AS DATE)
               AND CAST(@Date AS DATE)  <= CAST(P.ToDate AS DATE)
               AND C.CashierId = @CashierId;
     END;
GO