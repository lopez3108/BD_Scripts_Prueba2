SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:2-11-2023
--CAMBIOS EN 5467, ELIMINAR CHECK FRAUD IS NOT FRAUD
CREATE PROCEDURE [dbo].[sp_DeleteIsNotFraudByAccountMaker] (@Account VARCHAR(50),
@Maker VARCHAR(80) )
AS

BEGIN

  IF EXISTS (SELECT TOP 1
        f.FraudId
      FROM FraudAlert f
      WHERE f.Maker = @Maker
      AND f.Account = @Account
      AND CAST(f.IsNotFraud AS BIT) = 1)

  BEGIN
    DELETE FraudAlert
    WHERE Maker = @Maker
      AND Account = @Account
      AND CAST(IsNotFraud AS BIT) = 1

    DELETE CheckFraudExceptions
    WHERE Maker = @Maker
      AND Account = @Account

  END
END



GO