SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Update by jt/10-07-2024 task 5917
-----------------------------------------------------------------------
CREATE PROCEDURE [dbo].[sp_GetClientFirstCheck] @ClientId INT = NULL
, @Account VARCHAR(50) = NULL
, @MakerId INT = NULL
, @Routing VARCHAR(50) = NULL
, @CheckId INT = NULL
, @GetLastCheck BIT = NULL
, @Date DATETIME = NULL
, @CheckRangeRegistering INT = NULL --Esta variable sirve para saber cuanto se configuró de rango en días para cambio entre un cheuqe y otro del mismo cliente
AS
BEGIN
  DECLARE @FromDate DATETIME = NULL;
  IF (@CheckRangeRegistering IS NOT NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -@CheckRangeRegistering, @Date);
  END;

  SELECT TOP (CASE
    WHEN @GetLastCheck = 1 THEN 1000
    ELSE 1
  END)
    checkEls.CheckId
   ,checkEls.ClientId
   ,Checks.CheckTypeId
   ,checkEls.AgencyId
   ,Checks.CheckFront
   ,Checks.CheckBack
   ,checkEls.CheckDate CreationDate
   ,
    --(select TOP 1
    --    CreationDate
    --FROM ChecksEls
    --WHERE CheckId = Checks.CheckId
    --ORDER BY CreationDate DESC ) DateCashed,
    checkEls.CreationDate DateCashed
   ,CheckElsId
   ,Checks.Maker
   ,Makers.MakerId
   ,checkEls.Amount
   ,checkEls.Fee
   ,checkEls.CheckNumber Number
   ,checkEls.Account
   ,checkEls.Routing
   ,Checks.DateCheck
   ,Makers.Name AS MakerName
   ,Routings.BankName
   ,ds.DocumentStatusId CheckStatusId
   ,ds.Code CheckStatusCode
   ,dsc.DocumentStatusId ClientStatusId
   ,dsc.Code ClientStatusCode
   ,CheckElsId
   ,
    -- cels.CheckElsId
    --(select TOP 1
    --    CheckElsId
    --FROM ChecksEls
    --WHERE CheckId = checkEls.CheckId
    --ORDER BY CreationDate DESC ) CheckElsId,
    --checkEls.ValidatedBy ,
    --checkEls.ValidatedRangeBy ,
    --checkEls.ValidatedRoutingBy ,
    --checkEls.ValidatedMaxAmountBy ,
    --checkEls.ValidatedCheckDateBy ,
    --checkEls.ValidatedPhoneBy ,
    --Checks.ValidatedMakerBy ,
    --Checks.ValidateCheckTypeBy ,
    --Checks.ValidatedPostdatedChecksBy ,
    a.Code + ' - ' + a.Name AgencyCodeName
   ,cc.IsClientVIP
   ,cc.CountContinuousChecks
  -- ISNULL(p.PromotionalCodeStatusId, 0) PromotionalCodeStatusId,
  -- ISNULL(p.PromotionalCodeId, 0) PromotionalCodeId,
  -- ISNULL(PC.Usd, 0) UsdDiscount
  FROM ChecksEls checkEls
  LEFT JOIN dbo.Checks
    ON Checks.CheckId = checkEls.CheckId
  -- LEFT JOIN ChecksEls cels ON cels.CheckId = CHECKS.CheckId
  -- LEFT JOIN PromotionalCodesStatus P ON cels.CheckElsId = p.CheckId
  -- LEFT JOIN PromotionalCodes pc ON pc.PromotionalCodeId = p.PromotionalCodeId
  LEFT JOIN Makers
    ON checkEls.MakerId = Makers.MakerId
  LEFT JOIN Agencies a
    ON a.AgencyId = checkEls.AgencyId
  LEFT JOIN Routings
    ON checkEls.Routing = Routings.Number
  LEFT JOIN dbo.Clientes cc
    ON checkEls.ClientId = cc.ClienteId
  LEFT JOIN DocumentStatus ds
    ON ds.DocumentStatusId = Checks.CheckStatusId
  LEFT JOIN DocumentStatus dsc
    ON dsc.DocumentStatusId = cc.ClientStatusId
  WHERE (checkEls.CheckId = @CheckId
  OR @CheckId IS NULL)
  AND (checkEls.ClientId = @ClientId
  OR @ClientId IS NULL)
  AND (checkEls.Account = @Account
  OR @Account IS NULL)
  AND (checkEls.Routing = @Routing
  OR @Routing IS NULL)
  AND (checkEls.CreationDate >= @FromDate
  OR @FromDate IS NULL)
    AND (Makers.MakerId = @MakerId
  OR @MakerId IS NULL)
  ORDER BY (CASE
    WHEN @GetLastCheck = 1 THEN checkEls.CreationDate
  END) ASC,

  (CASE
    WHEN @GetLastCheck <> 1 THEN checkEls.CreationDate
  END) ASC
--ORDER BY checkEls.CheckId DESC;
END;




GO