SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- date 03-06-2025 task 6553 Ajustes módulo USERS JF
-- date 04-06-2025 task 6555 USERS - Se actualiza todos los registros del tab de My users

CREATE PROCEDURE [dbo].[sp_GetPasswordsCompanyByUser]
(@UserId         INT, 
 @AgencyId       INT      = NULL, 
 @CurrentDate    DATETIME, 
 @IsAdminRequest INT      = NULL
)
AS
    BEGIN
        IF(@IsAdminRequest IS NOT NULL
           AND @IsAdminRequest = 1)
            BEGIN
                SELECT p.*, 
                       CAST(1 AS BIT) AS OwnerPass, 
                       u.Name AS UpdateByName,
                       p.[User] UserSaved,
                       p.[Pass] PassSaved,
                       p.AgencyNumber AgencyNumberSaved,
                       p.TokenNumber TokenNumberSaved,
                       p.Url UrlSaved
                FROM UserPass p
                     LEFT JOIN Users u ON u.UserId = p.UpdatedBy
                WHERE p.UserId = @UserId
                      AND p.AgencyId = @AgencyId
                       ORDER BY p.Company ASC;
            END;
            ELSE
            IF(@IsAdminRequest IS NOT NULL
               AND @IsAdminRequest = 3)
                BEGIN
                    SELECT p.*, 
                           CAST(1 AS BIT) AS OwnerPass, 
                           u.Name AS UpdateByName,
                            p.[User] UserSaved,
                            p.[Pass] PassSaved,
                            p.AgencyNumber AgencyNumberSaved,
                            p.TokenNumber TokenNumberSaved,
                            p.Url UrlSaved

                    FROM UserPass p
                         LEFT JOIN Users u ON u.UserId = p.UpdatedBy
                    WHERE p.UserId = @UserId
                          AND p.AgencyId is NULL
                          ORDER BY p.Company ASC;
                END;
                ELSE
                BEGIN
                    IF(EXISTS
                    (
                        SELECT *
                        FROM UserPass
                        WHERE UserId = @UserId
                              AND AgencyId = @AgencyId
                    ))
                        BEGIN
                            SELECT p.*, 
                                   p.[User] UserSaved, 
                                   CAST(1 AS BIT) AS OwnerPass, 
                                   u.Name AS UpdateByName,
                                    p.[User] UserSaved,
                                    p.[Pass] PassSaved,
                                    p.AgencyNumber AgencyNumberSaved,
                                    p.TokenNumber TokenNumberSaved,
                                    p.Url UrlSaved
                            FROM UserPass p
                                 LEFT JOIN Users u ON u.UserId = p.UpdatedBy
                            WHERE p.UserId = @UserId
                                  AND p.AgencyId = @AgencyId
                                  ORDER BY p.Company ASC;
                        END;
                        ELSE
                        BEGIN
                            IF(EXISTS
                            (
                                SELECT UserId
                                FROM PassAccess
                                WHERE UserId = @UserId
                                      AND AgencyId = @AgencyId
                                      AND CAST(@CurrentDate AS DATE) >= CAST(FromDate AS DATE)
                                      AND CAST(@CurrentDate AS DATE) <= CAST(ToDate AS DATE)
                            ))
                                BEGIN
                                    DECLARE @ownerId INT;
                                    SET @ownerId =
                                    (
                                        SELECT TOP 1 OwnerUserId
                                        FROM PassAccess
                                        WHERE UserId = @UserId
                                              AND AgencyId = @AgencyId
                                              AND CAST(@CurrentDate AS DATE) >= CAST(FromDate AS DATE)
                                              AND CAST(@CurrentDate AS DATE) <= CAST(ToDate AS DATE)
                                    );
                                    
                                    SELECT *, 
                                           p.[User] UserSaved, 
                                           CAST(0 AS BIT) AS OwnerPass,
										    u.Name AS UpdateByName
                                    FROM UserPass p
									LEFT JOIN Users u ON u.UserId = p.UpdatedBy
                                    WHERE p.UserId = @ownerId
                                          AND p.AgencyId = @AgencyId
                                           ORDER BY p.Company ASC;
                                END;
                        END;
                END;
    END;



GO