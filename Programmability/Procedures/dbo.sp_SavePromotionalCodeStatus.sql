SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- date 05-06-2025 task 6559 Ajustes discounts  JF

CREATE PROCEDURE [dbo].[sp_SavePromotionalCodeStatus]
(@PromotionalCodeStatusId INT          = NULL, 
 @PromotionalCodeId       INT, 
 @Code                    CHAR(4), 
 @Used                    BIT          = NULL, 
 @UsedDate                DATETIME     = NULL, 
 @SentSMSDate             DATETIME     = NULL, 
 @AgencyUsedId            INT          = NULL, 
 @UserUsedId              INT          = NULL, 
 @CheckId                 INT          = NULL, 
 @CityStickerId           INT          = NULL, 
 @PlateStickerId          INT          = NULL, 
 @TitleId                 INT          = NULL, 
 @AgencyUsedName          VARCHAR(150) OUTPUT, 
 @ActualClientTelephone   VARCHAR(10) = NULL, 
 @TelIsCheck              BIT          = NULL, 
 @Usd                     DECIMAL(18, 2) = NULL,
 @Reusable                BIT          = NULL,
 @UsedDateOut             DATETIME     = NULL OUTPUT
)
AS
    BEGIN
        IF EXISTS
        (
            SELECT TOP 1 1
            FROM PromotionalCodesStatus P
                 INNER JOIN PromotionalCodes pc ON pc.PromotionalCodeId = P.PromotionalCodeId
            WHERE P.Code = @Code
                  AND Pc.Reusable = 0
                  AND P.Used = 1
        )
            BEGIN
                SELECT TOP 1 @AgencyUsedName = a.Name, 
                             @UsedDateOut = P.UsedDate
                FROM PromotionalCodesStatus P
                     INNER JOIN PromotionalCodes pc ON pc.PromotionalCodeId = P.PromotionalCodeId
                     INNER JOIN Agencies a ON a.AgencyId = P.AgencyUsedId
                WHERE P.Code = @Code
                      AND Pc.Reusable = 0
                      AND P.Used = 1;
            END;
            ELSE
            BEGIN
                IF(@PromotionalCodeStatusId IS NULL
                   OR @PromotionalCodeStatusId <= 0)
                    BEGIN
                        INSERT INTO [dbo].PromotionalCodesStatus
                        (PromotionalCodeId, 
                         Code, 
                         Used, 
                         UsedDate, 
                         AgencyUsedId, 
                         UserUsedId, 
                         CheckId, 
                         CityStickerId, 
                         PlateStickerId, 
                         TitleId, 
                         ActualClientTelephone, 
                         TelIsCheck,
                         Usd,
                         Reusable ,
                         SentSMSDate
                        )
                        VALUES
                        (@PromotionalCodeId, 
                         @Code, 
                         @Used, 
                         @UsedDate, 
                         @AgencyUsedId, 
                         @UserUsedId, 
                         @CheckId, 
                         @CityStickerId, 
                         @PlateStickerId, 
                         @TitleId, 
                         @ActualClientTelephone, 
                         @TelIsCheck,
                         @Usd,
                         @Reusable ,
                         @SentSMSDate
                        );
                    END;
                    ELSE
                    BEGIN
                        UPDATE [dbo].PromotionalCodesStatus
                          SET 
                              Used = @Used, 
                              UsedDate = @UsedDate, 
                              AgencyUsedId = @AgencyUsedId, 
                              UserUsedId = @UserUsedId, 
                              CheckId = @CheckId, 
                              CityStickerId = @CityStickerId, 
                              PlateStickerId = @PlateStickerId, 
                              ActualClientTelephone = @ActualClientTelephone, 
                              TelIsCheck = @TelIsCheck, 
                              TitleId = @TitleId,
                              Usd = @Usd
                        WHERE PromotionalCodeStatusId = @PromotionalCodeStatusId;
                    END;
            END;
    END;


GO