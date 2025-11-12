SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCourtPaymentsByReturnedCheck]
(
	  @ReturnedCheckId int
)
AS 

BEGIN

     SELECT *, 
               P.Description, 
               U.Name,
			   B.AccountNumber,
			   c.CardNumber,
			   a.Code+' - '+a.Name AS AgencyName,
			   ba.Name as BankName,
          l.LastUpdatedOn AS LastUpdatedOn,
           U1.Name AS LastUpdatedBy
     FROM [dbo].[CourtPayment] L
             left JOIN ProviderCommissionPaymentTypes P ON L.ProviderCommissionPaymentTypeId = P.ProviderCommissionPaymentTypeId
             left JOIN Users U ON U.UserId = L.CreatedBy
             left JOIN Users U1 ON U1.UserId = l.LastUpdatedBy
             left JOIN BankAccounts b ON b.BankAccountId = L.BankAccountId
			 left join bank ba on ba.BankId = b.BankId
			 left JOIN CardBanks c ON c.CardBankId = L.CardBankId
			 left join Agencies a on a.AgencyId = L.AgencyId
        WHERE ReturnedCheckId = @ReturnedCheckId;
    END;
GO