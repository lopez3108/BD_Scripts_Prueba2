SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSuspiciousActivity] @ProviderId                 INT         = NULL, 
                                                 @AgencyId                   INT         = NULL, 
                                                 @TransactionNumber          VARCHAR(20) = NULL, 
                                                 @SAR                        BIT         = NULL, 
                                                 @SuspiciousActivityStatusId INT         = NULL, 
                                                 @CreationDate               DATETIME    = NULL
AS
     SET NOCOUNT ON;
    BEGIN
        SELECT dbo.SuspiciousActivity.SuspiciousActivityId, 
               dbo.SuspiciousActivity.ProviderId, 
               dbo.Providers.Name AS Provider, 
               dbo.SuspiciousActivity.TransactionNumber, 
               dbo.SuspiciousActivity.USD, 
               dbo.SuspiciousActivity.Note AS Description, 
               dbo.SuspiciousActivity.SAR,
               CASE
                   WHEN dbo.SuspiciousActivity.SAR = 0
                   THEN 'NO'
                   ELSE 'YES'
               END AS SARText, 
               dbo.SuspiciousActivity.AgencyId, 
               dbo.Agencies.Code + ' - ' + dbo.Agencies.Name AS Agency, 
               dbo.SuspiciousActivity.CreationDate, 
			   FORMAT(SuspiciousActivity.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
               dbo.SuspiciousActivity.CreatedBy AS UserId, 
               dbo.Users.Name AS CreatedBy, 
               dbo.SuspiciousActivity.SuspiciousActivityStatusId, 
               dbo.SuspiciousActivityStatus.Description AS Status
        FROM dbo.SuspiciousActivity
             INNER JOIN dbo.Agencies ON dbo.SuspiciousActivity.AgencyId = dbo.Agencies.AgencyId
             INNER JOIN dbo.Users ON dbo.SuspiciousActivity.CreatedBy = dbo.Users.UserId
             INNER JOIN dbo.Providers ON dbo.SuspiciousActivity.ProviderId = dbo.Providers.ProviderId
             INNER JOIN dbo.SuspiciousActivityStatus ON dbo.SuspiciousActivity.SuspiciousActivityStatusId = dbo.SuspiciousActivityStatus.SuspiciousActivityStatusId
        WHERE(@AgencyId IS NULL
              OR dbo.SuspiciousActivity.AgencyId = @AgencyId)
             AND (@ProviderId IS NULL
                  OR dbo.SuspiciousActivity.ProviderId = @ProviderId)
             AND (@TransactionNumber IS NULL
                  OR dbo.SuspiciousActivity.TransactionNumber = @TransactionNumber)
             AND (@SAR IS NULL
                  OR dbo.SuspiciousActivity.SAR = @SAR)
             AND (@SuspiciousActivityStatusId IS NULL
                  OR dbo.SuspiciousActivity.SuspiciousActivityStatusId = @SuspiciousActivityStatusId)
             AND (@CreationDate IS NULL
                  OR CAST(dbo.SuspiciousActivity.CreationDate AS DATE) = CAST(@CreationDate AS DATE));
    END;

	select * from SuspiciousActivityStatus
GO