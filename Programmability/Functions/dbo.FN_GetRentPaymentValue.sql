SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-09-15 JF/ 6773 : Renew contracts
-- 2025-09-15 JF/ 6777 : Error al ingresar a testError al ingresar a test
-- 2025-10-10 JF/6786: Ajuste para contratos cerrados el mismo día de creación

CREATE FUNCTION [dbo].[FN_GetRentPaymentValue] (@ContractId INT, @Date DATETIME)


RETURNS @result TABLE (
  ContractId INT
 ,DueDays INT
 ,FeeDue DECIMAL(18, 2)
 ,FeeDueLate DECIMAL(18, 2)
 ,MonthsLate DECIMAL(18, 1)
 ,RentToPay DECIMAL(18, 1)
 ,Paid DECIMAL(18, 1)
 ,ContractLenght INT
 ,ContractStatusCode VARCHAR(4)
 ,ContractStatusDescription VARCHAR(20)
)
AS
BEGIN



  DECLARE @monthsLateDue INT
  DECLARE @lastPendingFeeDueDate DATETIME
  DECLARE @contractdate DATETIME
  DECLARE @contractEndDate DATETIME
  DECLARE @monthsLived DECIMAL(18, 2)
  DECLARE @dateBeginOfMonth DATETIME
  DECLARE @dayToChargeRent INT
  DECLARE @newStartDate DATETIME
  DECLARE @initialMonthFeeCharged DECIMAL(18, 2)
  DECLARE @initialMonthInitialDate DATETIME
  DECLARE @dueDaysConfiguration DECIMAL(18, 0)
  DECLARE @paid DECIMAL(18, 2)
  DECLARE @rent DECIMAL(18, 2)
  DECLARE @feeLate DECIMAL(18, 2)
  DECLARE @contractFeeLate DECIMAL(18, 2)
  DECLARE @monthsLate DECIMAL(18, 2)
  DECLARE @monthsPaid DECIMAL(18, 2)
  DECLARE @paidDue DECIMAL(18, 2)
  DECLARE @dueDays DECIMAL(18, 0)
  DECLARE @mustpaid DECIMAL(18, 2)
  DECLARE @endDate DATETIME
  DECLARE @startingDate DATETIME
  DECLARE @monthsLateFeeDue INT

  SET @paid = ISNULL((SELECT
      SUM(UsdPayment)
    FROM [dbo].[RentPayments]
    WHERE ContractId = @ContractId)
  , 0)

  SET @rent = (SELECT TOP 1
      RentValue
    FROM [dbo].[Contract]
    WHERE ContractId = @ContractId)

  SET @contractdate = (SELECT TOP 1
      StartDate
    FROM Contract
    WHERE ContractId = @ContractId)

  SET @dayToChargeRent = (DATEPART(DAY, @contractdate) - 1)

  SET @contractFeeLate = ISNULL((SELECT TOP 1
      FeeDue
    FROM Contract
    WHERE ContractId = @ContractId)
  , 0)


  SET @startingDate = (SELECT TOP 1
      StartDate
    FROM Contract
    WHERE ContractId = @ContractId)

  SET @endDate = @Date

  SET @monthsLived = DATEDIFF(MONTH, @startingDate, @endDate)


  SET @dateBeginOfMonth = DATEADD(MONTH, DATEDIFF(MONTH, 0, @Date), 0)


  SET @dayToChargeRent = DATEPART(DAY, @startingDate)

  SET @dateBeginOfMonth = DATEADD(DAY, @dayToChargeRent, CAST(@dateBeginOfMonth AS DATE))

  SET @dueDaysConfiguration = ISNULL((SELECT TOP 1
      Dayslate
    FROM Contract
    WHERE ContractId = @ContractId)
  , 0)

  DECLARE @dateToBeChargedFee DATETIME
  SET @dateToBeChargedFee = DATEADD(DAY, (@dueDaysConfiguration), CAST(@dateBeginOfMonth AS DATE))


--  SET @monthsPaid = @paid / @rent --6786
SET @monthsPaid = ISNULL(@paid / NULLIF(@rent, 0), 0)



  IF (@monthsPaid > 1)
  BEGIN

    SET @monthsLate = @monthsLived - @monthsPaid

    IF (@dateToBeChargedFee > CAST(@Date AS DATE))
    BEGIN

      SET @monthsLived = @monthsLived - 1

    END

    SET @monthsLateFeeDue = @monthsLived - @monthsPaid

    DECLARE @contractStartingDate DATETIME
    SET @contractStartingDate = (SELECT TOP 1
        StartDate
      FROM Contract
      WHERE ContractId = ContractId)


    SET @feeLate = @contractFeeLate * @monthsLateFeeDue



    IF ((@feeLate > 0)
      AND (@feeLate < @contractFeeLate))
    BEGIN

      SET @feeLate = @contractFeeLate
      SET @dueDays = DATEDIFF(DAY, @dateToBeChargedFee, CAST(@Date AS DATE))

    END


    ------


    SELECT TOP 1
      @lastPendingFeeDueDate = ISNULL(rp.CreationDate, NULL)
    FROM RentPayments rp
    WHERE rp.ContractId = @ContractId
    AND rp.FeeDuePending > 0
    ORDER BY rp.RentPaymentId DESC


    -- DECLARE @Date DATETIME
    --SET @Date = '2022-08-29'



    IF (@lastPendingFeeDueDate IS NOT NULL)
    BEGIN

      SET @newStartDate = @lastPendingFeeDueDate


      SET @monthsLived = DATEDIFF(MONTH, @newStartDate, @Date)

      IF (@monthsLived > 0)
      BEGIN

        SET @dateBeginOfMonth = DATEADD(MONTH, @monthsLived, @newStartDate)

        SET @dateBeginOfMonth = DATEADD(MONTH, DATEDIFF(MONTH, 0, @dateBeginOfMonth), 0)


        SET @dateBeginOfMonth = DATEADD(DAY, @dayToChargeRent, CAST(@dateBeginOfMonth AS DATE))


        SET @dueDaysConfiguration = ISNULL((SELECT TOP 1
            Dayslate
          FROM Contract
          WHERE ContractId = @ContractId)
        , 0)

        SET @dateBeginOfMonth = DATEADD(DAY, @dueDaysConfiguration, CAST(@dateBeginOfMonth AS DATE))

        DECLARE @year INT = DATEPART(YEAR, @lastPendingFeeDueDate);
        DECLARE @month INT = DATEPART(MONTH, @lastPendingFeeDueDate);
        DECLARE @day INT = ((@dayToChargeRent + 1) + @dueDaysConfiguration);
        DECLARE @maxDay INT = DAY(eomonth(@lastPendingFeeDueDate));

        IF @day > @maxDay
          SET @day = @maxDay;

        SET @initialMonthInitialDate = datefromparts(@year, @month, @day);

        IF (@initialMonthInitialDate < CAST(@lastPendingFeeDueDate AS DATE))
        BEGIN

          SET @monthsLived = @monthsLived - 1

        END

        IF (@dateBeginOfMonth < CAST(@Date AS DATE))
        BEGIN

          SET @monthsLived = @monthsLived + 1

        END

        SET @paidDue = ISNULL((SELECT
            SUM(rp.UsdPayment)
          FROM [dbo].[RentPayments] rp
          WHERE rp.ContractId = @ContractId
          AND CAST(rp.CreationDate AS DATE) > CAST(@newStartDate AS DATE))
        , 0)


        SET @rent = (SELECT TOP 1
            RentValue
          FROM [dbo].[Contract]
          WHERE ContractId = @ContractId)


--        SET @monthsPaid = @paidDue / @rent --6786
            SET @monthsPaid = ISNULL(@paidDue / NULLIF(@rent, 0), 0)



        SET @monthsLateDue = @monthsLived - @monthsPaid



        SET @contractFeeLate = ISNULL((SELECT TOP 1
            FeeDue
          FROM Contract
          WHERE ContractId = @ContractId)
        , 0)

        SET @feeLate = ISNULL((@contractFeeLate * @monthsLateDue), 0)


      END
      ELSE
      BEGIN

        SET @feeLate = 0

      END

    END

    -----------------------


    DECLARE @monthsLivedRent INT
    SET @monthsLivedRent = DATEDIFF(MONTH, @startingDate, @Date) + 1

    SET @dateBeginOfMonth = DATEADD(MONTH, DATEDIFF(MONTH, 0, @Date), 0)

    SET @dateBeginOfMonth = DATEADD(DAY, @dayToChargeRent, CAST(@dateBeginOfMonth AS DATE))

    SET @dateToBeChargedFee = DATEADD(DAY, (@dueDaysConfiguration), CAST(@dateBeginOfMonth AS DATE))

    SET @mustpaid = ISNULL((@monthsLivedRent * @rent), 0)


  END
  ELSE
  BEGIN


    SET @mustpaid = @rent * (@monthsLived + 1)
--    SET @monthsLate = @mustpaid / @rent --6786
SET @monthsLate = ISNULL(@mustpaid / NULLIF(@rent, 0), 0)

    SET @monthsLateDue = @monthsLate

    IF (@dateBeginOfMonth > @Date)
    BEGIN

      SET @monthsLateDue = @monthsLateDue - 1

    END

    SET @dueDays = 0
    SET @feeLate = @monthsLateDue * @contractFeeLate







  END

  DECLARE @paidRent DECIMAL(18, 2)
  SET @paidRent = (ISNULL((SELECT
      SUM(UsdPayment)
    FROM RentPayments
    WHERE RentPayments.ContractId = @ContractId)
  , 0))

  SET @contractEndDate = (SELECT TOP 1
      EndDate
    FROM Contract
    WHERE ContractId = @ContractId)

  DECLARE @contractLenght INT
  SET @contractLenght = DATEDIFF(MONTH, @contractdate, @contractEndDate)

  DECLARE @contractStatusCode VARCHAR(4)
  DECLARE @contractStatusDescription VARCHAR(20)

  SET @contractEndDate = (SELECT TOP 1
      EndDate
    FROM Contract
    WHERE ContractId = @ContractId)

  SET @contractStatusCode =
  CASE
    WHEN @Date > @contractEndDate THEN (SELECT TOP 1
          Code
        FROM ContractStatus
        WHERE Code = 'C04')
    ELSE (SELECT TOP 1
          Code
        FROM ContractStatus
        WHERE Code = 'C01')
  END

  SET @contractStatusDescription =
  CASE
    WHEN @Date > @contractEndDate THEN (SELECT TOP 1
          Description
        FROM ContractStatus
        WHERE Code = 'C04')
    ELSE (SELECT TOP 1
          Description
        FROM ContractStatus
        WHERE Code = 'C01')
  END


  DECLARE @rentStatusCode VARCHAR(4)
  DECLARE @rentStatusDescription VARCHAR(20)




  INSERT INTO @result (ContractId,
  DueDays,
  FeeDue,
  FeeDueLate,
  MonthsLate,
  RentToPay,
  Paid,
  ContractLenght,
  ContractStatusCode,
  ContractStatusDescription)
    VALUES (@ContractId, @dueDays, @feeLate, @contractFeeLate, @monthsLate, @mustpaid, @paidRent, @contractLenght, @contractStatusCode, @contractStatusDescription)


  RETURN

END;
GO