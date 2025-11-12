SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-06-09 JF/6571: Guardar valor de descuento aplicado en el momento del registro y no por referencia a configuración
-- 2025-07-15 JT/6670: Ver imagen del cheque en el daily

CREATE PROCEDURE [dbo].[sp_GetChecksElsDailyByType] (@Creationdate DATE,
@AgencyId INT,
@ProviderTypeId INT,
@UserId INT,
@QueryGroup BIT = NULL,
@CheckClientIdGuidGroup VARCHAR(100) = NULL)
AS


BEGIN
  SELECT
    UCL.Name ClientName
   ,CASE
      WHEN UCL.UserId IS NOT NULL THEN UCL.Telephone
      WHEN C.ClientTelephone IS NOT NULL THEN C.ClientTelephone
      ELSE ''
    END ClientTelephone
   ,UCL.Address ClientAddress
   ,CL.Doc1Number ClientDoc1Number
   ,CL.Doc2Number ClientDoc2Number
   ,CL.Doc1Front
   ,CL.Doc1Back
   ,CL.Doc2Front
   ,CL.Doc2Back
   ,CL.ClienteId AS ClientId
   ,C.*
   ,ISNULL(P.PromotionalCodeStatusId, 0) PromotionalCodeStatusId
   ,ISNULL(P.PromotionalCodeId, 0) PromotionalCodeId
   ,ISNULL(P.Usd, 0) UsdDiscount
   ,ISNULL(ch.ClientId, 0) ClientId
   ,r.BankName
   ,m.Name AS MakerName
   ,C.LastUpdatedOn
   ,usu.Name LastUpdatedByName
   ,1 QuantityChecks
   ,dbo.[fn_GetReturnedCheckByCheckElsId](C.CheckElsId) HasReturnedCheck
   ,CH.CheckFront
   ,CH.CheckBack
  FROM [dbo].[ChecksEls] C
  LEFT JOIN Checks ch
    ON C.CheckId = ch.CheckId
  LEFT JOIN PromotionalCodesStatus P
    ON C.CheckElsId = P.CheckId
  LEFT JOIN PromotionalCodes pc
    ON pc.PromotionalCodeId = P.PromotionalCodeId
  LEFT JOIN Users usu
    ON C.LastUpdatedBy = usu.UserId
  LEFT JOIN Routings r
    ON C.Routing = r.Number
  LEFT JOIN dbo.Makers m
    ON C.MakerId = m.MakerId
  LEFT JOIN Clientes CL
    ON CL.ClienteId = C.ClientId
  LEFT JOIN Users UCL
    ON UCL.UserId = CL.UsuarioId
  WHERE (CAST(C.CreationDate AS DATE) = CAST(@Creationdate AS DATE)
  OR @Creationdate IS NULL)
  AND C.AgencyId = @AgencyId
  AND C.ProviderTypeId = @ProviderTypeId
  AND C.CreatedBy = @UserId
  AND (C.CheckClientIdGuidGroup = @CheckClientIdGuidGroup
  OR @CheckClientIdGuidGroup IS NULL)
  ORDER BY C.CreationDate DESC
END




GO