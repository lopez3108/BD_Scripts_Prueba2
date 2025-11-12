SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SetSecurityCodeExpiration] @CashierId          INT,
                                                      @SecurityCode       VARCHAR(5),
                                                      @ExpirationDateCode DATETIME
AS
     BEGIN
         UPDATE Cashiers
           SET
               SecurityCode = @SecurityCode,
               ExpirationDateCode = @ExpirationDateCode
         WHERE CashierId = @CashierId;
     END;
GO