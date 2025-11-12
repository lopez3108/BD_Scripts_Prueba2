SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSecurityCodeExpirationTraining] @CashierId    INT         = NULL,
                                                             @UserId       INT         = NULL,
                                                             @SecurityCode VARCHAR(50) = NULL
AS
     BEGIN
         SELECT c.CashierId,
                u.UserId,
                c.SecurityCode,
                c.ExpirationDateUrl,
                c.TrainingToDoId,
                c.ReviewToDoId,
                t.TrainingId,  --EJEMPLO PARA TOMAR REVIEW DE LA TABLA DE REVIEWS
				r.ReviewId
         FROM Cashiers c
              LEFT JOIN Users u ON u.UserId = c.Userid
                                   AND c.UserId = @UserId
                                   OR @UserId IS NULL
              LEFT JOIN Training t ON t.TrainingId = c.TrainingToDoId
			  LEFT JOIN Reviews r ON r.ReviewId = c.ReviewToDoId
         WHERE(c.CashierId = @CashierId
               OR @CashierId IS NULL)
              AND (c.SecurityCode = @SecurityCode
                   OR @SecurityCode IS NULL);
     END;
GO