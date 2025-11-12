SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllOthersByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN
         SELECT SUM(dbo.OthersDetails.Usd) AS USD,
                dbo.OthersServices.Name,
                CAST(dbo.OthersDetails.CreationDate AS DATE) AS Date
         FROM dbo.OthersDetails
              INNER JOIN dbo.OthersServices ON dbo.OthersDetails.OtherServiceId = dbo.OthersServices.OtherId
         WHERE CAST(dbo.OthersDetails.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.OthersDetails.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
         GROUP BY dbo.OthersServices.Name,
                  CAST(dbo.OthersDetails.CreationDate AS DATE);
     END;
GO