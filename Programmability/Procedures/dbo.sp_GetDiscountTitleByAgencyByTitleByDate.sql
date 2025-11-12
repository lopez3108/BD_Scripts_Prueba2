SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetDiscountTitleByAgencyByTitleByDate]
(@TitleId         INT,
 @DiscountTitleId INT  = NULL,
 @AgencyId        INT,
 @CreationDate    DATE
)
AS
     BEGIN
         SELECT d.DiscountTitleId,
                d.TitleId,
                d.Discount,
                d.ReasonId,
                d.OtherReason,
                d.CreationDate,
                d.CreatedBy,
                d.AgencyId,
			 r.Code ReasonCode,
                UPPER(ISNULL(T.Name, ''))+ CASE WHEN T.Name IS NOT NULL  AND T.Name <> '' THEN  ' - ' ELSE '' END + UPPER(pt.Description) AS TitleProcessType
         FROM DiscountTitles d
              INNER JOIN TITLES t ON d.TitleId = t.TitleId
              INNER JOIN ProcessTypes pt ON t.ProcessTypeId = pt.ProcessTypeId
		    INNER JOIN Reasons r ON d.ReasonId = r.ReasonId
         WHERE(CAST(d.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
              AND d.AgencyId = @AgencyId
              AND d.TitleId = @TitleId
              AND (d.DiscountTitleId <> @DiscountTitleId
                   OR @DiscountTitleId IS NULL);
     END;


GO