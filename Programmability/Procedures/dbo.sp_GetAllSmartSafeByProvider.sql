SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created: FELIPE
--CReated: 14-02-2024
--

CREATE PROCEDURE [dbo].[sp_GetAllSmartSafeByProvider]
(@Creationdate DATE = NULL,
 @AgencyId     INT,
 @CreatedBy    INT,
 @ProviderId   INT  = NULL
)
AS
     BEGIN
         SELECT  ssd.SmartSafeDepositId
				,ssd.ProviderId
				,ssd.TransactionId
				,ssd.Usd
				,ssd.Voucher 
				,ssd.UserId AS UserId
				,ssd.AgencyId
--        ,A.Code + ' - ' + A.Name AgencyName
				,ssd.CreationDate
				,ssd.LastUpdatedOn
				,ssd.LastUpdatedBy
				,u.Name LastUpdatedByName
         FROM SmartSafeDeposit ssd 
--         INNER JOIN Agencies a ON C.AgencyId = a.AgencyId
		 LEFT JOIN Users usu ON ssd.UserId = usu.UserId
     	 LEFT JOIN Users u ON ssd.LastUpdatedBy = u.UserId
         WHERE ssd.AgencyId = @AgencyId
               AND (CAST(ssd.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
               AND ssd.UserId = @CreatedBy
               AND (ssd.ProviderId = @ProviderId
                    OR @ProviderId IS NULL);
     END;
GO