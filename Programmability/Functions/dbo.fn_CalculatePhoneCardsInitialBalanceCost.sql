SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CalculatePhoneCardsInitialBalanceCost](
@AgencyId   INT,
@EndDate DATETIME = NULL)
RETURNS DECIMAL(18, 2)
AS
   BEGIN  
   
    RETURN (


	ISNULL((SELECT       
SUM(ISNULL(dbo.PhoneCards.PhoneCardsUsd,0))
        FROM  dbo.PhoneCards
						 WHERE 
						 dbo.PhoneCards.AgencyId = @AgencyId 
						AND CAST(dbo.PhoneCards.CreationDate AS DATE) < CAST(@EndDate AS DATE)), 0)

						-

						ISNULL((SELECT  
SUM((ISNULL(dbo.Expenses.Usd,0) * -1))
FROM            dbo.Expenses INNER JOIN
                         dbo.ExpensesType ON dbo.Expenses.ExpenseTypeId = dbo.ExpensesType.ExpensesTypeId
						 WHERE 
						 dbo.ExpensesType.Code = 'C03' AND
						 dbo.Expenses.AgencyId = @AgencyId AND
						 CAST(dbo.Expenses.CreatedOn AS DATE) < CAST(@EndDate AS DATE)),0)
  


)

END
GO