SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--10-10-2024 Jt/6085 Add new commissions InsurancePolicy, InsuranceMonthlyPayment, InsuranceRegistration
-- Create By:      Felipe
-- Creation Date:  24-Abril-2024
-- Task:           5751 Save commission values ​​for city stickers
-- 2025-01-17 JF/6293: Habilitar comisiones insurance a los cajeros para los nuevos servicios

CREATE FUNCTION [dbo].[fn_GetCahierCommissionElsById] (@CreatedBy INT, @Code VARCHAR(4), @DateApplyComissions DATE)
RETURNS DECIMAL(18, 2)
AS

BEGIN
  DECLARE @CashierId INT
         ,@ComissionApplyId INT;
  DECLARE @result DECIMAL(18, 2);

  SET @CashierId = (SELECT
      c.CashierId
    FROM Cashiers c
    WHERE c.UserId = @CreatedBy)


  IF (@Code = 'C03')
  BEGIN

    SET @ComissionApplyId = (SELECT
        cac.ComissionApplyId
      FROM CashierApplyComissions cac
      INNER JOIN Cashiers c
        ON c.CashierId = cac.CashierId
      WHERE cac.CashierId = @CashierId
      AND cac.ApplyCitySticker = 1
      AND c.IsComissions = 1
      AND CAST(@DateApplyComissions AS DATE) >= CAST(cac.StartDateCitySticker AS DATE))

    BEGIN
      IF (@ComissionApplyId IS NOT NULL)
      BEGIN
        SET @result = (SELECT
            cs.CitySticker
          FROM ComissionSettings cs)
      END
      ELSE
      BEGIN
        SET @result = (SELECT
            0 AS CitySticker)
      END
    END;
  --             RETURN @result           
  END;
  ELSE
  IF (@Code = 'C04')
  BEGIN
    SET @ComissionApplyId = (SELECT
        cac.ComissionApplyId
      FROM CashierApplyComissions cac
      INNER JOIN Cashiers c
        ON c.CashierId = cac.CashierId
      WHERE cac.CashierId = @CashierId
      AND cac.ApplyPlateSticker = 1
      AND c.IsComissions = 1
      AND CAST(@DateApplyComissions AS DATE) >= CAST(cac.StartDatePlateSticker AS DATE))

    BEGIN
      IF (@ComissionApplyId IS NOT NULL)
      BEGIN
        SET @result = (SELECT
            cs.PlateSticker
          FROM ComissionSettings cs)
      END
      ELSE
      BEGIN
        SET @result = (SELECT
            0 AS PlateSticker)
      END
    END;

  --          RETURN @result  

  END;
  ELSE
  IF (@Code = 'C01')
  BEGIN
    SET @ComissionApplyId = (SELECT
        cac.ComissionApplyId
      FROM CashierApplyComissions cac
      INNER JOIN Cashiers c
        ON c.CashierId = cac.CashierId
      WHERE cac.CashierId = @CashierId
      AND cac.ApplyTitlesAndPlates = 1
      AND c.IsComissions = 1
      AND CAST(@DateApplyComissions AS DATE) >= CAST(cac.StartDateTitlesAndPlates AS DATE))

    BEGIN
      IF (@ComissionApplyId IS NOT NULL)
      BEGIN
        SET @result = (SELECT
            cs.TitlesAndPlates
          FROM ComissionSettings cs)
      END
      ELSE
      BEGIN
        SET @result = (SELECT
            0 AS TitlesAndPlates)
      END
    END;

  --             RETURN @result  

  END
  ELSE
  IF (@Code = 'C02')
  BEGIN
    SET @ComissionApplyId = (SELECT
        cac.ComissionApplyId
      FROM CashierApplyComissions cac
      INNER JOIN Cashiers c
        ON c.CashierId = cac.CashierId
      WHERE cac.CashierId = @CashierId
      AND cac.ApplyTrp730 = 1
      AND c.IsComissions = 1
      AND CAST(@DateApplyComissions AS DATE) >= CAST(cac.StartDateTrp AS DATE))

    BEGIN
      IF (@ComissionApplyId IS NOT NULL)
      BEGIN
        SET @result = (SELECT
            cs.Trp730
          FROM ComissionSettings cs)
      END
      ELSE
      BEGIN
        SET @result = (SELECT
            0 AS Trp730)
      END
    END;
  --             RETURN @result

  END
  ELSE
  IF (@Code = 'C12')
  BEGIN
    SET @ComissionApplyId = (SELECT
        cac.ComissionApplyId
      FROM CashierApplyComissions cac
      INNER JOIN Cashiers c
        ON c.CashierId = cac.CashierId
      WHERE cac.CashierId = @CashierId
      AND cac.ApplyTelephones = 1
      AND c.IsComissions = 1
      AND CAST(@DateApplyComissions AS DATE) >= CAST(cac.StartDateTelephones AS DATE))

    BEGIN
      IF (@ComissionApplyId IS NOT NULL)
      BEGIN
        SET @result = (SELECT
            cs.Telephones
          FROM ComissionSettings cs)
      END
      ELSE
      BEGIN
        SET @result = (SELECT
            0 AS Telephones)
      END
    END;
  --              RETURN @result

  END
  ELSE
  IF (@Code = 'C24')
  BEGIN
    SET @ComissionApplyId = (SELECT
        cac.ComissionApplyId
      FROM CashierApplyComissions cac
      INNER JOIN Cashiers c
        ON c.CashierId = cac.CashierId
      WHERE cac.CashierId = @CashierId
      AND cac.ApplyTickets = 1
      AND c.IsComissions = 1
      AND CAST(@DateApplyComissions AS DATE) >= CAST(cac.StartDateTickets AS DATE))

    BEGIN
      IF (@ComissionApplyId IS NOT NULL)
      BEGIN
        SET @result = (SELECT
            cs.Tickets
          FROM ComissionSettings cs)
      END
      ELSE
      BEGIN
        SET @result = (SELECT
            0 AS Tickets)
      END
    END;

  END
  ELSE
  IF (@Code = 'C30')--NewPolicys
  BEGIN
    SET @ComissionApplyId = (SELECT
        cac.ComissionApplyId
      FROM CashierApplyComissions cac
      INNER JOIN Cashiers c
        ON c.CashierId = cac.CashierId
      WHERE cac.CashierId = @CashierId
      AND cac.ApplyNewPolicy = 1
      AND c.IsComissions = 1
      AND CAST(@DateApplyComissions AS DATE) >= CAST(cac.StartDateNewPolicy AS DATE))

    BEGIN
      IF (@ComissionApplyId IS NOT NULL)
      BEGIN
        SET @result = (SELECT
            cs.NewPolicy
          FROM ComissionSettings cs)
      END
      ELSE
      BEGIN
        SET @result = (SELECT
            0 AS NewPolicys)
      END
    END;
  --              RETURN @result

  END
  ELSE
  IF (@Code = 'C31')--MonthlyPayment
  BEGIN
    SET @ComissionApplyId = (SELECT
        cac.ComissionApplyId
      FROM CashierApplyComissions cac
      INNER JOIN Cashiers c
        ON c.CashierId = cac.CashierId
      WHERE cac.CashierId = @CashierId
      AND cac.ApplyMonthlyPayment = 1
      AND c.IsComissions = 1
      AND CAST(@DateApplyComissions AS DATE) >= CAST(cac.StartDateMonthlyPayment AS DATE))

    BEGIN
      IF (@ComissionApplyId IS NOT NULL)
      BEGIN
        SET @result = (SELECT
            cs.MonthlyPayment
          FROM ComissionSettings cs)
      END
      ELSE
      BEGIN
        SET @result = (SELECT
            0 AS MonthlyPayments)
      END
    END;
  --              RETURN @result

  END
  ELSE
  IF (@Code = 'C32')--RegistrationRelease
  BEGIN
    SET @ComissionApplyId = (SELECT
        cac.ComissionApplyId
      FROM CashierApplyComissions cac
      INNER JOIN Cashiers c
        ON c.CashierId = cac.CashierId
      WHERE cac.CashierId = @CashierId
      AND cac.ApplyRegistrationRelease = 1
      AND c.IsComissions = 1
      AND CAST(@DateApplyComissions AS DATE) >= CAST(cac.StartDateRegistrationRelease AS DATE))

    BEGIN
      IF (@ComissionApplyId IS NOT NULL)
      BEGIN
        SET @result = (SELECT
            cs.RegistrationRelease
          FROM ComissionSettings cs)
      END
      ELSE
      BEGIN
        SET @result = (SELECT
            0 AS RegistrationReleases)
      END
    END;

  --              RETURN @result

  END
    ELSE
  IF (@Code = 'C33')--endorsement
  BEGIN
    SET @ComissionApplyId = (SELECT
        cac.ComissionApplyId
      FROM CashierApplyComissions cac
      INNER JOIN Cashiers c
        ON c.CashierId = cac.CashierId
      WHERE cac.CashierId = @CashierId
      AND cac.ApplyEndorsement = 1
      AND c.IsComissions = 1
      AND CAST(@DateApplyComissions AS DATE) >= CAST(cac.StartDateEndorsement AS DATE))

    BEGIN
      IF (@ComissionApplyId IS NOT NULL)
      BEGIN
        SET @result = (SELECT
            cs.Endorsement
          FROM ComissionSettings cs)
      END
      ELSE
      BEGIN
        SET @result = (SELECT
            0 AS Endorsements)
      END
    END;

  --              RETURN @result

  END
    ELSE
  IF (@Code = 'C34')--PolicyRenewal
  BEGIN
    SET @ComissionApplyId = (SELECT
        cac.ComissionApplyId
      FROM CashierApplyComissions cac
      INNER JOIN Cashiers c
        ON c.CashierId = cac.CashierId
      WHERE cac.CashierId = @CashierId
      AND cac.ApplyPolicyRenewal = 1
      AND c.IsComissions = 1
      AND CAST(@DateApplyComissions AS DATE) >= CAST(cac.StartDatePolicyRenewal AS DATE))

    BEGIN
      IF (@ComissionApplyId IS NOT NULL)
      BEGIN
        SET @result = (SELECT
            cs.PolicyRenewal
          FROM ComissionSettings cs)
      END
      ELSE
      BEGIN
        SET @result = (SELECT
            0 AS PolicyRenewals)
      END
    END;

  --              RETURN @result

  END
  RETURN @result;

END;




GO