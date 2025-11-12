SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSuspiciousActivityPendingNumber]

AS
     SET NOCOUNT ON;
    BEGIN
        

SELECT        COUNT(dbo.SuspiciousActivity.SuspiciousActivityId)
FROM            dbo.SuspiciousActivity INNER JOIN
                         dbo.SuspiciousActivityStatus ON dbo.SuspiciousActivity.SuspiciousActivityStatusId = dbo.SuspiciousActivityStatus.SuspiciousActivityStatusId
WHERE dbo.SuspiciousActivityStatus.Description = 'PENDING'










    END;
GO