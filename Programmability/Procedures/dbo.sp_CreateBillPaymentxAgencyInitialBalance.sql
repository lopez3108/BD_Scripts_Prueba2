SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateBillPaymentxAgencyInitialBalance] 
@AgencyId INT,
@ProviderId INT,
@InitialBalance DECIMAL(18,2),
@LastUpdatedOn DATETIME = null,
@CreatedBy     INT = null,
@ConfigurationSavedDate DATETIME = null
AS
     BEGIN

	INSERT INTO [dbo].[BillPaymentxAgencyInitialBalances]
           ([AgencyId]
           ,[ProviderId]
           ,[InitialBalance],
            LastUpdatedOn,
          CreatedBy,
          ConfigurationSavedDate)
     VALUES
           (@AgencyId
           ,@ProviderId
           ,@InitialBalance,
           @LastUpdatedOn,
          @CreatedBy,  @ConfigurationSavedDate)

		   SELECT @@IDENTITY

END

GO