SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GeSmartDepositsByTransaction]
(
 @TransactionId		VARCHAR(15),
 @AgencyId			INT,
 @ProviderId		INT  = NULL
)
AS
     BEGIN
         SELECT  S.SmartSafeDepositId
				,S.ProviderId
				,S.TransactionId
				,S.Usd
				,S.Voucher
				,S.UserId
				,S.AgencyId
				,S.CreationDate
         FROM SmartSafeDeposit S
		  LEFT JOIN Users usu ON S.UserId = usu.UserId
         WHERE S.AgencyId = @AgencyId
               AND (S.ProviderId = @ProviderId)
			   AND s.TransactionId = @TransactionId
     END;
GO