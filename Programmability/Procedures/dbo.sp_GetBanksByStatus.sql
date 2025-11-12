SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetBanksByStatus] @IsActive BIT = NULL
AS
     BEGIN
         IF(@IsActive = 1)
             BEGIN
                 SELECT DISTINCT
                        b.[BankId],
                        b.[Name]
                 FROM [dbo].[Bank] b
                      INNER JOIN BankAccounts ab ON b.BankId = ab.BankId
                                                    AND AB.Active = 1
                 ORDER BY b.Name;
         END;
             ELSE
             BEGIN
                 SELECT DISTINCT
                        b.[BankId],
                        b.[Name]
                 FROM [dbo].[Bank] b
                      --INNER JOIN BankAccounts ab ON b.BankId = ab.BankId
                 ORDER BY b.Name;
         END;
     END;
GO