SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreatePaymentChecksAgenttoagent] @PaymentChecksAgentToAgentId INT = NULL,
@AgencyFromId INT = NULL,
@AgencyToId INT = NULL,
@Usd DECIMAL(18, 2),
@Fee DECIMAL(18, 2) = NULL,
@ChecksCount INT,
@CreationDate DATETIME = NULL,
@CreatedBy INT = NULL,
@UpdatedBy INT = NULL,
@Date DATETIME = NULL,
@UpdatedOn DATETIME = NULL,

@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@ProviderId INT = NULL,
@LotNumber SMALLINT = NULL,
@providerBatch VARCHAR(50) = NULL,
@IsFromAdmin BIT = NULL

AS
BEGIN

  DECLARE @ProviderCheckfee DECIMAL(18, 2)
  SET @ProviderCheckfee = (SELECT TOP 1
      ISNULL(CheckCommission, 0) FROM  Providers
    WHERE ProviderId = @ProviderId) 




  IF (@PaymentChecksAgentToAgentId IS NULL)
  BEGIN
    INSERT INTO  [dbo].[PaymentChecksAgentToAgent] ([FromAgency]
    , [ToAgency]
    , [Date]
    , [Usd]
    , [NumberChecks]
    , [StatusId]
    , [CreationDate]
    , [CreatedBy]
    , [FromDate]
    , [ToDate]
    , [ProviderId]
    , [Fee]
    , LotNumber
    , providerBatch
    , IsFromAdmin,
    ProviderCheckfee)
      VALUES (@AgencyFromId, @AgencyToId, @Date, @Usd, @ChecksCount, 1, @CreationDate, @CreatedBy, @FromDate, @ToDate, @ProviderId, @Fee, @LotNumber,@providerBatch, @IsFromAdmin, @ProviderCheckfee)

    SELECT
      @@identity
  END
  ELSE
  BEGIN
    UPDATE  [PaymentChecksAgentToAgent]
    SET Usd = @Usd
       ,NumberChecks = @ChecksCount
       ,UpdatedOn = @UpdatedOn
       ,UpdatedBy = @UpdatedBy
       ,Fee = @Fee
       ,ProviderId = (CASE
          WHEN @ProviderId > 0 THEN @ProviderId
          ELSE ProviderId
        END)
       ,ToAgency = (CASE
          WHEN @AgencyToId > 0 THEN @AgencyToId
          ELSE ToAgency
        END)
       ,LotNumber = (CASE
          WHEN @LotNumber > 0 THEN @LotNumber
          ELSE LotNumber
        END)
        ,providerBatch = @providerBatch
    WHERE PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId
    SELECT
      @PaymentChecksAgentToAgentId;
  END




END;
GO