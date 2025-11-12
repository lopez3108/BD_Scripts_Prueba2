SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSumBankAccountsDailyDistributionByBankAccountIdByDateDailyByAgency] @BankAccountId   INT      = NULL,
                                                                                            @CreationDate DATETIME,
                                                                                            @AgencyId     INT
AS
     BEGIN
         SELECT ISNULL(SUM(b.Usd), 0) AS Suma
         FROM DailyDistribution b
              INNER JOIN Daily d ON d.DailyId = b.DailyId
--              INNER JOIN MoneyDistribution m ON b.MoneyDistributionId = m.MoneyDistributionId
         WHERE 
--          m.BankAccountId = @BankAccountId               
               d.AgencyId = @AgencyId
               AND (CAST(d.CreationDate AS DATE) = CAST(@CreationDate AS DATE));
     END;
GO