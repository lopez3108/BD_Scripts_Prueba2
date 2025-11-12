SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VerifyFullAccount] (@BankAccountId INT)
AS
  DECLARE @HasFullAccount BIT
  BEGIN
    IF EXISTS (SELECT
          *
        FROM BankAccounts p      
        WHERE p.BankAccountId = @BankAccountId AND (p.FullAccount is NULL OR  p.FullAccount = '') )
    BEGIN
     
        SET @HasFullAccount = 0;
    END
   ELSE
   BEGIN
    SET @HasFullAccount = 1;
   END
SELECT @HasFullAccount
  END;

GO