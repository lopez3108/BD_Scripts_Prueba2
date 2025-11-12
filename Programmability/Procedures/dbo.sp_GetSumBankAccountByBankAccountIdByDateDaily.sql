SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
	create PROCEDURE [dbo].[sp_GetSumBankAccountByBankAccountIdByDateDaily] @BankAccountId   INT      = NULL,
                                                                                       @CreationDate DATETIME
																	  --,
                   --                                                                    @AgencyId     INT
AS
     BEGIN
         SELECT ISNULL(SUM(b.Usd), 0) AS Suma
         FROM PaymentBanks b
         WHERE b.BankAccountId = @BankAccountId
               --AND b.AgencyId = @AgencyId
               AND (CAST(b.CreationDate AS DATE) = CAST(@CreationDate AS DATE));
     END;
GO