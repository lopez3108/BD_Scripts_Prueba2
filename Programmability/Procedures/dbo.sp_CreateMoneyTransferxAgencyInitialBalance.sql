SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateMoneyTransferxAgencyInitialBalance] @AgencyId       INT,
                                                                    @ProviderId     INT,
                                                                    @InitialBalance DECIMAL(18, 2),
                                                                    @ConfigurationSavedDate DATETIME = NULL,
@LastUpdatedOn DATETIME = null,
@CreatedBy     INT = null

AS
     BEGIN
         INSERT INTO[dbo].[MoneyTransferxAgencyInitialBalances]
         ([AgencyId],
          [ProviderId],
          [InitialBalance],
          ConfigurationSavedDate,
          LastUpdatedOn,
          CreatedBy
         )
         VALUES
         (@AgencyId,
          @ProviderId,
          @InitialBalance,
          @ConfigurationSavedDate,
          @LastUpdatedOn,
          @CreatedBy
         );
         SELECT @@IDENTITY;
     END;


GO