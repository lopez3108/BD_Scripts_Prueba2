SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllElsByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN
         SELECT CAST(dbo.CityStickers.CreationDate AS DATE) AS Date,
                SUM(USD) AS USD,
                --'CITY STICKER' AS Name
				(SELECT Name FROM  ProvidersEls WHERE Code = 'C03') AS Name
         FROM dbo.CityStickers
         WHERE CAST(dbo.CityStickers.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.CityStickers.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
         GROUP BY CAST(dbo.CityStickers.CreationDate AS DATE)
         UNION ALL
         SELECT CAST(dbo.CountryTaxes.CreationDate AS DATE) AS Date,
                SUM(USD) AS USD,
                --'COUNTY TAX' AS Name
				(SELECT Name FROM  ProvidersEls WHERE Code = 'C08') AS Name

         FROM dbo.CountryTaxes
         WHERE CAST(dbo.CountryTaxes.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.CountryTaxes.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
         GROUP BY CAST(dbo.CountryTaxes.CreationDate AS DATE)
         UNION ALL
         SELECT CAST(dbo.ParkingTickets.CreationDate AS DATE) AS Date,
                SUM(USD) AS USD,
                'PARKING TICKET - CARD' AS Name

         FROM dbo.ParkingTickets
         WHERE CAST(dbo.ParkingTickets.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.ParkingTickets.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
         GROUP BY CAST(dbo.ParkingTickets.CreationDate AS DATE)
         UNION ALL
         SELECT CAST(dbo.ParkingTicketsCards.CreationDate AS DATE) AS Date,
                SUM(USD) AS USD,
                'PARKING TICKET - ELS' AS Name
         FROM dbo.ParkingTicketsCards
         WHERE CAST(dbo.ParkingTicketsCards.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.ParkingTicketsCards.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
         GROUP BY CAST(dbo.ParkingTicketsCards.CreationDate AS DATE)
         UNION ALL
         SELECT CAST(dbo.PlateStickers.CreationDate AS DATE) AS Date,
                SUM(USD) AS USD,
                --'REGISTRATION RENEWAL' AS Name
				(SELECT Name FROM  ProvidersEls WHERE Code = 'C04') AS Name
         FROM dbo.PlateStickers
         WHERE CAST(dbo.PlateStickers.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.PlateStickers.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
         GROUP BY CAST(dbo.PlateStickers.CreationDate AS DATE)
         UNION ALL
         SELECT CAST(dbo.TitleInquiry.CreationDate AS DATE) AS Date,
                SUM(USD) AS USD,
                --'TITLE INQUIRY' AS Name
				(SELECT Name FROM  ProvidersEls WHERE Code = 'C05') AS Name
         FROM dbo.TitleInquiry
         WHERE CAST(dbo.TitleInquiry.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.TitleInquiry.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
         GROUP BY CAST(dbo.TitleInquiry.CreationDate AS DATE)
         UNION ALL
         SELECT CAST(dbo.Titles.CreationDate AS DATE) AS Date,
                SUM(USD) AS USD,
                --'TITLE AND PLATES' AS Name,
				(SELECT Name FROM  ProvidersEls WHERE Code = 'C01') AS Name
         FROM dbo.Titles
         WHERE CAST(dbo.Titles.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.Titles.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
               AND ProcessAuto = 1
			AND FinancingId IS NULL
         GROUP BY CAST(dbo.Titles.CreationDate AS DATE)
         UNION ALL
         SELECT CAST(dbo.TRP.CreatedOn AS DATE) AS Date,
                SUM(USD) AS USD,
                --'TRP' AS Name,
				(SELECT Name FROM  ProvidersEls WHERE Code = 'C02') AS Name
         FROM dbo.TRP
         WHERE CAST(dbo.TRP.CreatedOn AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.TRP.CreatedOn AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
         GROUP BY CAST(dbo.TRP.CreatedOn AS DATE);
     END;
GO