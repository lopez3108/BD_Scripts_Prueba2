SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SetUrlExpiration] @CashierId          INT,
                                                    @SecurityCode       VARCHAR(50),
                                                      @ExpirationDateUrl DATETIME,
													  @TrainingId INT = NULL,
													   @ReviewId INT = NULL

AS
     BEGIN
         UPDATE Cashiers
           SET
              SecurityCode = @SecurityCode,
               ExpirationDateUrl = @ExpirationDateUrl,
			    TrainingToDoId = @TrainingId,
				ReviewToDoId = @ReviewId
         WHERE CashierId = @CashierId;
     END;
GO