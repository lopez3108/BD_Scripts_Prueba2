SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllSmartSafeByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN
         SELECT CAST(dbo.SmartSafeDeposit.CreationDate AS DATE) AS Date,
                SUM(ISNULL(dbo.SmartSafeDeposit.USD, 0)) USD,
		
                dbo.Providers.Name+' (S.S.D)' Name,
                dbo.SmartSafeDeposit.AgencyId
         FROM dbo.SmartSafeDeposit 
              INNER JOIN dbo.Providers ON dbo.SmartSafeDeposit.ProviderId = dbo.Providers.ProviderId
         WHERE 
         CAST(dbo.SmartSafeDeposit.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.SmartSafeDeposit.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND dbo.SmartSafeDeposit.UserId = @CreatedBy
               AND dbo.SmartSafeDeposit.AgencyId = @AgencyId
              
               AND 
               UseSmartSafeDeposit = 1

         GROUP BY  CAST(dbo.SmartSafeDeposit.CreationDate AS DATE),
                  dbo.Providers.Name,
                  dbo.SmartSafeDeposit.AgencyId,
                  dbo.SmartSafeDeposit.ProviderId;
     END;

GO