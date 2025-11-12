SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-04-11 DJ/5516: Fields ClosedOnCashAdmin and ClosedByCashAdmin must be null if it is the first time the daily is closed, so the admin can update those values in daily report

CREATE PROCEDURE [dbo].[sp_SaveDaily]
(@DailyId                   INT            = NULL,
 @CreationDate              DATETIME       = NULL,
 @Total                     DECIMAL(18, 2),
 @TotalFree                 DECIMAL(18, 2)  = NULL,
 @Cash                      DECIMAL(18, 2)  = NULL,
 @CashAdmin                 DECIMAL(18, 2)  = NULL,
 @CardPayments              DECIMAL(18, 2)  = NULL,
 @CardPaymentsAdmin         DECIMAL(18, 2)  = NULL,
 @Missing                   DECIMAL(18, 2)  = NULL,
 @Surplus                   DECIMAL(18, 2)  = NULL,
 @Note                      VARCHAR(300)   = NULL,
 @CashierId                 INT,
 @AgencyId                  INT,
 @LastEditedOn              DATETIME       = NULL,
 @LastEditedBy              INT            = NULL,
 @ClosedOn                  DATETIME       = NULL,
 @ClosedBy                  INT            = NULL,
 @ClosedOnCashAdmin         DATETIME       = NULL,
 @ClosedByCashAdmin         INT            = NULL,
 @ClosedOnCardPaymentsAdmin DATETIME       = NULL,
 @ClosedByCardPaymentsAdmin INT            = NULL,
 @IsCashier                 BIT            = NULL,
 @ClosedTime                TIME       = NULL,
 @IdCreated                 INT OUTPUT
)
AS
DECLARE @userId INT;
     BEGIN
	 if(@ClosedByCashAdmin = 0 )
	 begin
	set @ClosedByCashAdmin =  null;
	 end

	 	 if(@ClosedByCardPaymentsAdmin = 0 )
	 begin
	set @ClosedByCardPaymentsAdmin =  null;
	 end
         IF(@DailyId IS NULL)
             BEGIN
                 INSERT INTO [dbo].Daily
                 (CreationDate,
                  Total,
                  CashierId,
                  AgencyId,
                  Cash,
                  CardPayments,
                  Missing,
                  Surplus,
                  Note,
                  ClosedOn,
                  ClosedBy,
				  ClosedTime
                 )
                 VALUES
                 (@CreationDate,
                  @Total,
                  @CashierId,
                  @AgencyId,
                  @Cash,
                  @CardPayments,
                  @Missing,
                  @Surplus,
                  @Note,
                  @ClosedOn,
                  @ClosedBy,
				  @ClosedTime
                 );
                 SET @IdCreated = @@IDENTITY;
         END;
             ELSE
           BEGIN

		   -- 5516
		   DECLARE @dailyIsAlreadyClosed BIT
		   SET @dailyIsAlreadyClosed = (SELECT CASE WHEN d.ClosedOn IS NULL THEN CAST(0 as BIT) ELSE
		   CAST(1 as BIT) END FROM dbo.Daily d WHERE d.DailyId = @DailyId)

		   IF(@dailyIsAlreadyClosed = CAST(0 AS BIT))
		   BEGIN

		   SET @ClosedOnCashAdmin = NULL
		   SET @ClosedByCashAdmin = NULL

		   END

                 UPDATE [dbo].Daily
                   SET
                       TotalFree = @TotalFree,
                       Total = @Total,
                       CashAdmin = @CashAdmin,
                       Cash = @Cash,
                       CardPaymentsAdmin = @CardPaymentsAdmin,
                       CardPayments = @CardPayments,
                       Missing = @Missing,
                       Surplus = @Surplus,
                       Note = @Note,
                       LastEditedOn = @LastEditedOn,
                       LastEditedBy = @LastEditedBy,
                       ClosedOn = @ClosedOn,
                       ClosedBy = @ClosedBy,
                       ClosedOnCashAdmin = @ClosedOnCashAdmin,
                       ClosedByCashAdmin = @ClosedByCashAdmin,
                       ClosedOnCardPaymentsAdmin = @ClosedOnCardPaymentsAdmin,
                       ClosedByCardPaymentsAdmin = @ClosedByCardPaymentsAdmin,
					   ClosedTime = @ClosedTime
                 WHERE DailyId = @DailyId;
                 SET @IdCreated = @DailyId;
         END;
     END;



GO