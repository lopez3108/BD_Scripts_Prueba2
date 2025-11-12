SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--CREATED BY: JOHAN
--CREATED ON: 14/8/2023
--USO: ENCONTRAR COINCIDENCIAS
CREATE PROCEDURE [dbo].[sp_GetRepeatCheckFraud] (@ClientName VARCHAR(50)= NULL,
@Maker VARCHAR(80) = NULL,
@Account VARCHAR(50) = NULL,
@CheckNumber VARCHAR(50) = NULL,
@Routing VARCHAR(15)= NULL,
@MakerAddress VARCHAR(100) = NULL,
@Telephone VARCHAR(20) = NULL,
@ClientAddress VARCHAR(100) = NULL,
@DOB DATETIME = NULL,
@Country VARCHAR(50) = NULL,
@IdentificacionNumber VARCHAR(30) = NULL,
@FraudId INT = NULL)
AS
BEGIN
  SELECT TOP 1
    fa.FraudId
  FROM FraudAlert fa
  WHERE (ClientName = @ClientName
  OR @ClientName IS NULL)
  --              AND  Maker  = @Maker 
  AND ((SELECT
      [dbo].[Removespecialcharatersinstring](UPPER(fa.Maker)))
  = (SELECT
      [dbo].[Removespecialcharatersinstring](UPPER(@Maker)))
  )--5120
  AND (Account = @Account
  OR @Account IS NULL)
  AND (CheckNumber = @CheckNumber
  OR @CheckNumber IS NULL)
  AND (NumberRouting = @Routing
  OR @Routing IS NULL)
  AND (FraudId != @FraudId
  OR @FraudId IS NULL)

  AND ((@MakerAddress IS NULL
  AND fa.MakerAddress IS NULL)
  OR (fa.MakerAddress = @MakerAddress))
  AND ((@Telephone IS NULL
  AND fa.Telephone IS NULL)
  OR (fa.Telephone = @Telephone))
  AND ((@ClientAddress IS NULL
  AND fa.ClientAddress IS NULL)
  OR (fa.ClientAddress = @ClientAddress))
  AND ((@DOB IS NULL
  AND fa.DOB IS NULL)
  OR (CAST(fa.DOB AS DATE) = CAST(@DOB AS DATE)))
  AND ((@Country IS NULL
  AND fa.Country IS NULL)
  OR (fa.Country = @Country))
  AND ((@IdentificacionNumber IS NULL
  AND fa.IdentificacionNumber IS NULL)
  OR (fa.IdentificacionNumber = @IdentificacionNumber))
--
--  AND ( fa.MakerAddress = @MakerAddress OR @MakerAddress is null)
--  AND (fa.Telephone = @Telephone  OR @Telephone is null)
--  AND (fa.ClientAddress = @ClientAddress OR @ClientAddress is null)
--  AND (CAST(fa.DOB AS DATE) = CAST(@DOB AS DATE)
--              OR @DOB IS NULL)
--  AND (fa.Country = @Country OR @Country is NULL)
--  AND (fa.IdentificacionNumber = @IdentificacionNumber OR @IdentificacionNumber is null)

END;



GO