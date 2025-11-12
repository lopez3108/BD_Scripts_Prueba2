SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SavePhonePlans]
(@PhonePlanId INT            = NULL,
 @Description VARCHAR(30),
 @Usd         DECIMAL(18, 2),
 @Active      BIT            = NULL,
 @IdCreated   INT OUTPUT
)
AS
     BEGIN
        
         IF(@PhonePlanId IS NULL)
             BEGIN
                IF NOT EXISTS
                 (
                     SELECT TOP 1 1
                     FROM [PhonePlans]
                     WHERE Description = @Description
                           AND Usd = @Usd
                 )
                     BEGIN
                       INSERT INTO [dbo].[PhonePlans]
                     (Description,
                      Usd
                     )
                     VALUES
                     (@Description,
                      @Usd
                     );
               SET @IdCreated = @@IDENTITY;
                 END;
                     ELSE
                     BEGIN
                         SET @IdCreated = -999
                 END;
         END;
             ELSE
             BEGIN
                 IF NOT EXISTS
                 (
                   SELECT TOP 1 1
                 FROM [PhonePlans]
                 WHERE Description = @Description
                       AND Usd = @Usd
                       AND PhonePlanId <> @PhonePlanId
                 )
                     BEGIN
                         UPDATE [dbo].[PhonePlans]
                       SET
                           Description = @Description,
                           Usd = @Usd,
                           Active = @Active
                     WHERE PhonePlanId = @PhonePlanId;
                     SET @IdCreated = @PhonePlanId;
                 END
                     ELSE
                     BEGIN
                         SET @IdCreated = -999
                 END
         END;
     END;
GO