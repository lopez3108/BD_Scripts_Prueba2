SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllSmartDepositsByProvider]
(@Creationdate DATE = NULL,
 @AgencyId     INT,
 @CreatedBy    INT,
 @ProviderId   INT  = NULL
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
				,s.LastUpdatedOn
				,s.LastUpdatedBy
				,usu.Name LastUpdatedByName
        ,u.Name LastUpdatedByNameReal
         FROM SmartSafeDeposit S
		 LEFT JOIN Users usu ON S.UserId = usu.UserId
     LEFT JOIN dbo.Users u ON S.LastUpdatedBy = u.UserId
         WHERE S.AgencyId = @AgencyId
               AND (CAST(S.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
               AND S.UserId = @CreatedBy
               AND (S.ProviderId = @ProviderId
                    OR @ProviderId IS NULL);
     END;
GO