SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreatePaymentCashAgentToAgent] @AgencyId     INT,
                                             @FromAgencyId INT,
                                             @ProviderId   INT,
                                             @Usd          DECIMAL(18, 2),
                                             @CreationDate DATETIME,
                                             @CreatedBy    INT,
                                             @Date         DATETIME
AS
     BEGIN
         INSERT INTO [dbo].[PaymentCashAgentToAgent]
         ([AgencyId],
          [ProviderId],
          [USD],
          [CreationDate],
          [CreatedBy],
          [Date],
		FromAgencyId
         )
         VALUES
         (@AgencyId,
          @ProviderId,
          @Usd,
          @CreationDate,
          @CreatedBy,
          @Date,
		@FromAgencyId
         );
         SELECT @@IDENTITY;
     END;
GO