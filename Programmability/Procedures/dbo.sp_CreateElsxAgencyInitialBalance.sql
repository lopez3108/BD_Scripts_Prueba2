SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateElsxAgencyInitialBalance] @AgencyId       INT,
                                                                    @ProviderId     INT,
                                                                    @InitialBalance DECIMAL(18, 2),
                                                                    @LastUpdatedOn DATETIME = null,
                                                                    @ConfigurationSavedDate DATETIME = null,
@CreatedBy     INT = null
AS
     BEGIN
         INSERT INTO [dbo].ElsxAgencyInitialBalances
         ([AgencyId],
          [ProviderId],
          [InitialBalance],
           LastUpdatedOn,
          CreatedBy,
          ConfigurationSavedDate
         )
         VALUES
         (@AgencyId,
          @ProviderId,
          @InitialBalance,
           @LastUpdatedOn,
          @CreatedBy, @ConfigurationSavedDate
         );
         SELECT @@IDENTITY;
     END;

GO