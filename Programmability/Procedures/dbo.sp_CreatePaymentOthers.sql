SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreatePaymentOthers] @AgencyId INT,
@ProviderId INT = null,
@Usd DECIMAL(18, 2),
@CreationDate datetime = null,
@CreatedBy int = null,
@LastUpdatedOn datetime = null,
@LastUpdatedBy int = null,
@CompletedOn datetime = null,
@CompletedBy int = null,
@IsDebit BIT,
@Date DATETIME,
@PaymentOthersId INT = NULL,
@StatusPaymentOthers varchar(3) = NULL,
@IsCardPayment BIT  

AS
BEGIN

  IF @PaymentOthersId IS NULL
  BEGIN
    -- Siempre que se cree un other payment estará en pending
    DECLARE @PaymentOthersStatusId INT
    SET @PaymentOthersStatusId = (SELECT TOP 1
        pos.PaymentOtherStatusId
      FROM PaymentOthersStatus pos
      WHERE pos.Code = 'C01')

    INSERT INTO [dbo].[PaymentOthers] ([AgencyId]
    , [ProviderId]
    , [USD]
    , [CreationDate]
    , [CreatedBy]
    , [IsDebit]
    , [Date]
    , PaymentOtherStatusId
    ,IsCardPayment
    )
      VALUES (@AgencyId, @ProviderId, @Usd, @CreationDate, @CreatedBy, @IsDebit, @Date, @PaymentOthersStatusId,@IsCardPayment)

  SELECT
    @@identity
  END
  ELSE
    DECLARE @PaymentOthersStatus INT
    SET @PaymentOthersStatus = (SELECT TOP 1
      pos.PaymentOtherStatusId
    FROM PaymentOthersStatus pos
    WHERE pos.Code = @StatusPaymentOthers)

    UPDATE  PaymentOthers 
    SET AgencyId = @AgencyId
   ,ProviderId = @ProviderId
   ,USD = @Usd
   ,LastUpdatedOn = @LastUpdatedOn
   ,LastUpdatedBy = @LastUpdatedBy
   ,CompletedOn = @CompletedOn
   ,CompletedBy = @CompletedBy
   ,IsDebit = @IsDebit
   ,Date = @Date
   ,PaymentOtherStatusId = @PaymentOthersStatus
   ,IsCardPayment = @IsCardPayment
WHERE PaymentOthersId = @PaymentOthersId;  

  SELECT
    @PaymentOthersId

END;

GO