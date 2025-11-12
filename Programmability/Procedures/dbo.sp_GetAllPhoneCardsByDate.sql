SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllPhoneCardsByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN
         SELECT SUM(ISNULL(PhoneCardsUsd, 0)) AS USD,
                CAST(dbo.PhoneCards.CreationDate AS DATE) AS Date,
                'PHONE CARDS' AS Name
         FROM dbo.PhoneCards
         WHERE CAST(dbo.PhoneCards.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.PhoneCards.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
         GROUP BY CAST(dbo.PhoneCards.CreationDate AS DATE);
     END;
GO