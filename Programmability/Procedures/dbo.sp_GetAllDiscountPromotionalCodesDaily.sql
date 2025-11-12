SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- date 05-06-2025 task 6559 Ajustes discounts  JF

CREATE PROCEDURE [dbo].[sp_GetAllDiscountPromotionalCodesDaily]
(@Date           DATE = NULL, 
 @AgencyId       INT, 
 @UserId         INT  = NULL, 
 @CheckId        INT  = NULL, 
 @CityStickerId  INT  = NULL, 
 @PlateStickerId INT  = NULL, 
 @TitleId        INT  = NULL
)
AS
    BEGIN
        SELECT P.PromotionalCodeStatusId, 
               P.PromotionalCodeId, 
               P.Code, 
               P.Used, 
               P.UsedDate, 
               p.AgencyUsedId, 
               pc.Description, 
               ISNULL(p.Usd,0) AS Usd , 
               p.UserUsedId, 
               p.CheckId, 
               p.CityStickerId, 
               p.PlateStickerId, 
               p.TitleId, 
               ISNULL(p.TelIsCheck, CAST(0 AS BIT)) TelIsCheck, 
               p.ActualClientTelephone
        FROM PromotionalCodesStatus P
             INNER JOIN PromotionalCodes pc ON pc.PromotionalCodeId = P.PromotionalCodeId
        WHERE(CAST(P.UsedDate AS DATE) = CAST(@Date AS DATE)
              OR @Date IS NULL)
             AND P.AgencyUsedId = @AgencyId
             AND (P.UserUsedId = @UserId
                  OR @UserId IS NULL)
             AND (P.CheckId = @CheckId
                  OR @CheckId IS NULL)
             AND (P.CityStickerId = @CityStickerId
                  OR @CityStickerId IS NULL)
             AND (P.PlateStickerId = @PlateStickerId
                  OR @PlateStickerId IS NULL)
             AND (P.TitleId = @TitleId
                  OR @TitleId IS NULL);
    END;
GO