SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllChecksElsByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN
         DECLARE @result TABLE
         (Date DATETIME,
          USD  DECIMAL(18, 4),
          Name VARCHAR(50)
         );

	 -- Returned checks

         INSERT INTO @result
                SELECT CAST(dbo.ChecksEls.CreationDate AS DATE) AS DATE,
                (
                    SELECT Amount - Amount * (Fee / 100)
                ) AS USD,
                       dbo.ProviderTypes.Description AS Name
                FROM ChecksEls
                     INNER JOIN ProviderTypes ON ProviderTypes.ProviderTypeId = ChecksEls.ProviderTypeId
                     INNER JOIN Providers ON Providers.ProviderTypeId = ProviderTypes.ProviderTypeId
                WHERE CAST(dbo.ChecksEls.CreationDate AS DATE) >= CAST(@From AS DATE)
                      AND CAST(dbo.ChecksEls.CreationDate AS DATE) <= CAST(@To AS DATE)
                      AND CreatedBy = @CreatedBy
                      AND AgencyId = @AgencyId;
         SELECT SUM(USD) AS USD,
                Name,
                CAST(Date AS DATE) AS Date
         FROM @result
         GROUP BY Name,
                  CAST(DATE AS DATE);
     END;

GO