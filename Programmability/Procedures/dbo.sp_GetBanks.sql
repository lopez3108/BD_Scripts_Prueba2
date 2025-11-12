SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetBanks]
AS
     BEGIN
         SELECT distinct b.[BankId],
                b.[Name]
                --ab.ZipCode,
                --ab.Address,
                --ab.City,
                --ab.State,
                --ab.County
         FROM [dbo].[Bank] b
			--inner join AddressXBank ab ON b.BankId = ab.BankId
         ORDER BY b.Name;
     END;
GO