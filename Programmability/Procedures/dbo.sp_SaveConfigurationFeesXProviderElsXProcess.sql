SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveConfigurationFeesXProviderElsXProcess]
(@ConfigurationFeesXProviderElsXProcessId INT            = NULL,
 @ProviderElsId                           INT,
 @ProcessTypeId                           INT,
 @Fee1Default                             DECIMAL(18, 2),
 @FeeEls                                  DECIMAL(18, 2)
)
AS
     BEGIN
         IF(@ConfigurationFeesXProviderElsXProcessId IS NULL
            OR @ConfigurationFeesXProviderElsXProcessId <= 0)
             BEGIN
                 INSERT INTO [dbo].ConfigFeesXProviderElsXProcess
                 (ProviderElsId,
                  ProcessTypeId,
                  Fee1Default,
                  FeeELS
                 )
                 VALUES
                 (@ProviderElsId,
                  @ProcessTypeId,
                  @Fee1Default,
                  @FeeEls
                 );
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].ConfigFeesXProviderElsXProcess
                   SET
                       Fee1Default = @Fee1Default,
                       FeeELS = @FeeEls
                 WHERE ConfigurationFeesXProviderElsXProcessId = @ConfigurationFeesXProviderElsXProcessId;
         END;
     END;
GO