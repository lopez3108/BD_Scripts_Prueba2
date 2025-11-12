SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportChecksValidated]
(@AgencyId       INT,
 @FromDate       DATETIME = NULL,
 @ToDate         DATETIME = NULL,
 @Date           DATETIME,
 @ProviderTypeId INT      = NULL
)
AS
     BEGIN
         IF(@FromDate IS NULL)
             BEGIN
                 SET @FromDate = DATEADD(day, -10, @Date);
                 SET @ToDate = @Date;
         END;
         SELECT c.CreationDate,
                c.CheckDate,
                UPPER(pt.Description) Type,
                c.Amount Usd,
				  --SUBSTRING( u.Name , 1 , 18) CreatedBy ,
      --        SUBSTRING( uv.Name , 1 , 18) ValidatedBy
                 u.Name AS  CreatedBy ,
               uv.Name AS ValidatedBy
         FROM [dbo].[ChecksEls] C
              INNER JOIN ProviderTypes pt ON pt.ProviderTypeId = c.ProviderTypeId
              INNER JOIN Users u ON u.UserId = c.CreatedBy
              INNER JOIN Users uv ON uv.UserId = c.ValidatedBy
              LEFT JOIN PromotionalCodesStatus P ON c.CheckElsId = p.CheckId
              LEFT JOIN PromotionalCodes pc ON pc.PromotionalCodeId = p.PromotionalCodeId
         WHERE CAST(C.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
               AND CAST(C.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
               AND C.AgencyId = @AgencyId
               AND (C.ProviderTypeId = @ProviderTypeId
                    OR @ProviderTypeId IS NULL)
               AND C.ValidatedBy IS NOT NULL;
     END;
GO