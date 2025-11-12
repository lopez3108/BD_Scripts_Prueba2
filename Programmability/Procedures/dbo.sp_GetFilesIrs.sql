SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		cmontoya
-- Create date: 12Marzo2020
-- Description:	<Description,,>
-- =============================================
/*
	exec [dbo].[sp_GetFilesIrs]
	@AgencyId = 1,
	@Window = 1,
	@StartDate = null,
	@EndDate = '2020-04-16'
*/

CREATE PROCEDURE [dbo].[sp_GetFilesIrs] @AgencyId  INT, 
                                       @Window    INT, 
                                       @StartDate DATETIME = NULL, 
                                       @EndDate   DATETIME = NULL
AS
    BEGIN
        DECLARE @PrimeraFecha DATETIME;
        DECLARE @UltimaFecha DATETIME;
        SET NOCOUNT ON;
        SELECT TOP (1) @PrimeraFecha = CreationDate
        FROM dbo.Irs
        ORDER BY CreationDate ASC;
        SELECT TOP (1) @UltimaFecha = CreationDate
        FROM dbo.Irs
        ORDER BY CreationDate DESC;
        SET NOCOUNT OFF;
        SELECT f.IrsId, 
               f.AgencyId, 
               f.CreationDate, 
               f.UserId AS CreatedBy, 
               u.Name AS CreatedByName, 
               f.Name, 
               f.Extension, 
               f.Base64, 
               f.Window, 
               CAST(1 AS BIT) AS IsSaved, 
               CAST(0 AS BIT) AS IsModify
        FROM dbo.Irs f
             INNER JOIN dbo.Users u ON f.UserId = U.UserId
        WHERE AgencyId = @AgencyId
              AND Window = @Window
              AND CONVERT(VARCHAR(10), CreationDate, 120) BETWEEN CASE
                                                                      WHEN @StartDate IS NOT NULL
                                                                      THEN CONVERT(VARCHAR(10), @StartDate, 120)
                                                                      ELSE CONVERT(VARCHAR(10), @PrimeraFecha, 120)
                                                                  END AND CASE
                                                                              WHEN @EndDate IS NOT NULL
                                                                              THEN CONVERT(VARCHAR(10), @EndDate, 120)
                                                                              ELSE CONVERT(VARCHAR(10), @UltimaFecha, 120)
                                                                          END
        ORDER BY CreationDate DESC;
    END;
GO