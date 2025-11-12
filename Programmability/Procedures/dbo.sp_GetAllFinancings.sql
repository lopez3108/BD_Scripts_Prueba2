SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllFinancings] @ClientName        VARCHAR(200) = NULL,
                                            @Telephone         VARCHAR(10)  = NULL,
                                            @Trp               VARCHAR(10)  = NULL,
                                            @AgencyId          INT          = NULL,
                                            @FinancingStatusId INT          = NULL,
                                            @FromDate          DATETIME     = NULL,
                                            @ToDate            DATETIME     = NULL,
                                            @Date              DATETIME     = NULL
AS
     BEGIN
         DECLARE @FinancingCode VARCHAR(10);
         SET @FinancingCode =
         (
             SELECT Code
             FROM FinancingStatus
             WHERE FinancingStatusId = @FinancingStatusId
         );
         SELECT f.FinancingId,
                f.FinancingStatusId,
                f.Trp,
                f.Name ClientName,
                f.Name,
                f.Name+'-'+f.Trp ClientTrp,
                f.Telephone,
                f.USD,
                f.Note,
                f.AgencyId,
                f.ExpirationDate,
                f.CancellarionFee,
                f.CancellationUsd,
                f.CreatedBy,
                f.CreatedOn,
                f.CompletedBy,
                f.CompletedOn,
                f.CanceledBy,
                f.CanceledOn,
                f.Dealer,
                f.DealerName,
                f.DealerAddress,
                f.DealerNumber,
                dbo.fn_CalculateDueFinancing(f.FinancingId, NULL) AS Due,
                ISNULL((f.USD - dbo.fn_CalculateDueFinancing(f.FinancingId, NULL)), 0) AS Paid,
                CASE
                    WHEN FS.Code = 'C01'
                         AND f.ExpirationDate < CAST(@Date AS DATE)
                    THEN
         (
             SELECT Description
             FROM FinancingStatus
             WHERE CODE = 'C04'
         )
                    ELSE fs.Description
                END AS FinancingStatusDescription,
                CASE
                    WHEN FS.Code = 'C01'
                         AND f.ExpirationDate < CAST(@Date AS DATE)
                    THEN('C04')
                    ELSE fs.Code
                END AS FinancingStatusRealCode,
                CASE
                    WHEN FS.Code = 'C01'
                         AND f.ExpirationDate < CAST(@Date AS DATE)
                    THEN
         (
             SELECT Color
             FROM FinancingStatus
             WHERE CODE = 'C04'
         )
                    ELSE fs.Color
                END AS FinancingStatusColor,
                u.Name UserCretedBy,
			 cc.CashierId UserCretedByCashierId,
                uc.Name UserCompletedBy,
                ucancel.Name UserCanceledBy,
                a.AgencyId,
                a.Name AgencyName,
                a.Address AgencyAddress,
                a.Name AgencyName,
                a.Address AgencyAddress,
                replace(a.Telephone, ' ', '') AgencyPhone,
                ZipCodes.City AgencyCity,
                CASE
                    WHEN ZipCodes.StateAbre IS NULL
                    THEN ' '
                    ELSE ' '+ZipCodes.StateAbre
                END AS AgencyStateAbreviation,
                a.ZipCode AgencyZipCode,
                CASE
                    WHEN DATEDIFF(DAY, @Date, f.ExpirationDate) > 0
                    THEN DATEDIFF(DAY, @Date, f.ExpirationDate)
                    ELSE 0
                END AS DaysToExpire
         FROM Financing f
              INNER JOIN FinancingStatus fs ON f.FinancingStatusId = fs.FinancingStatusId
              INNER JOIN Users u ON u.UserId = f.CreatedBy
		    LEFT JOIN Cashiers cc ON cc.UserId = u.UserId
              INNER JOIN Agencies a ON a.AgencyId = f.AgencyId
              INNER JOIN ZipCodes ON a.ZipCode = ZipCodes.ZipCode
              LEFT JOIN Users uc ON uc.UserId = f.CompletedBy
              LEFT JOIN Users ucancel ON ucancel.UserId = f.CanceledBy
         WHERE(f.AgencyId = @AgencyId
               OR @AgencyId IS NULL)
              AND (f.Name LIKE '%'+@ClientName+'%'
                   OR @ClientName IS NULL)
              AND ((f.Trp LIKE '%'+@Trp+'%'
                    OR @Trp IS NULL)
                   OR (f.Telephone LIKE '%'+@Telephone+'%'
                       OR @Telephone IS NULL))
              AND (((@FinancingCode = 'C01'
                     AND fs.Code = 'C01')
                    OR (@FinancingCode = 'C04'
                        AND (f.ExpirationDate < CAST(@Date AS DATE)))
                    AND (fs.Code <> 'C02'
                         AND fs.Code <> 'C03'))
                   OR (f.FinancingStatusId = @FinancingStatusId
                       OR @FinancingStatusId IS NULL))
              AND ((CAST(f.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
                    OR @FromDate IS NULL)
                   AND (CAST(f.CreatedOn AS DATE) <= CAST(@ToDate AS DATE))
                   OR @ToDate IS NULL);
     END;
GO