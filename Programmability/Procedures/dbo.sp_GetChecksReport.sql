SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetChecksReport] @ClientId    INT            = NULL,
                                           @MakerId     INT            = NULL,
                                           @Account     VARCHAR(50)    = NULL,
                                           @StartDate   DATETIME       = NULL,
                                           @EndDate     DATETIME       = NULL,
                                           @AgencyId    INT            = NULL,
                                           @Status      INT            = NULL,
                                           @CheckTypeId INT            = NULL,
                                           @CashierId   INT            = NULL,
                                           @Number      VARCHAR(40)    = NULL,
                                           @Operation   INT,
                                           @Amount      DECIMAL(18, 2)  = NULL
AS
     BEGIN
         SELECT Checks.CheckId,
                Checks.ClientId,
                Checks.CashierId,
                Checks.DateCashed,
                Checks.Maker,
                Checks.Amount,
                Checks.Fee,
                Checks.Number,
                Checks.Account,
                Checks.Routing,
                Checks.DateCheck,
                Users.Name AS Cliente,
                Users_1.Name AS Cashier,
                Agencies.Name AS Agency,
                Makers.Name AS MakerName,
                --Checks.IsBounced,
                --Checks.BouncedReason,
                --Checks.DateBounced,
                CheckTypes.Description AS CheckType,
                Checks.CheckFront,
                Checks.CheckBack,
                Clientes.Doc1Front,
                Clientes.Doc1Back,
                Clientes.Doc2Front,
                Clientes.Doc2Back
         FROM Checks
              INNER JOIN Cashiers ON Checks.CashierId = Cashiers.CashierId
              INNER JOIN Clientes ON Checks.ClientId = Clientes.ClienteId
              INNER JOIN Users ON Clientes.UsuarioId = Users.UserId
              INNER JOIN Users AS Users_1 ON Cashiers.UserId = Users_1.UserId
              INNER JOIN Makers ON Checks.Maker = Makers.MakerId
              INNER JOIN CheckTypes ON Checks.CheckTypeId = CheckTypes.CheckTypeId
              INNER JOIN Agencies ON Agencies.AgencyId = Checks.AgencyId
         WHERE Checks.ClientId = CASE
                                     WHEN @ClientId IS NULL
                                     THEN ClientId
                                     ELSE @ClientId
                                 END
               AND Checks.Maker = CASE
                                      WHEN @MakerId IS NULL
                                      THEN Checks.Maker
                                      ELSE @MakerId
                                  END
               AND Account LIKE CASE
                                    WHEN @Account IS NULL
                                    THEN Account
                                    ELSE '%'+@Account+'%'
                                END
               AND Checks.AgencyId = CASE
                                         WHEN @AgencyId IS NULL
                                         THEN Checks.AgencyId
                                         ELSE @AgencyId
                                     END
               AND CAST(DateCashed AS DATE) >= CASE
                                                   WHEN @StartDate IS NULL
                                                   THEN CAST(DateCashed AS DATE)
                                                   ELSE CAST(@StartDate AS DATE)
                                               END
               AND CAST(DateCashed AS DATE) <= CASE
                                                   WHEN @EndDate IS NULL
                                                   THEN CAST(DateCashed AS DATE)
                                                   ELSE CAST(@EndDate AS DATE)
                                               END
               --AND Checks.IsBounced = CASE
               --                           WHEN @Status = 1
               --                           THEN Checks.IsBounced
               --                           WHEN @Status = 2
               --                           THEN 0
               --                           ELSE 1
               --                       END
               AND CheckTypes.CheckTypeId = CASE
                                                WHEN @CheckTypeId IS NULL
                                                THEN CheckTypes.CheckTypeId
                                                ELSE @CheckTypeId
                                            END
               AND Checks.CashierId = CASE
                                          WHEN @CashierId IS NULL
                                          THEN Checks.CashierId
                                          ELSE @CashierId
                                      END
               AND Checks.Number = CASE
                                       WHEN @Number IS NULL
                                       THEN Checks.Number
                                       ELSE @Number
                                   END
               AND Checks.Amount = CASE
                                       WHEN @Operation = 1
                                       THEN @Amount
                                       ELSE Checks.Amount
                                   END
               AND Checks.Amount >= CASE
                                        WHEN @Operation = 2
                                        THEN @Amount
                                        ELSE Checks.Amount
                                    END
               AND Checks.Amount <= CASE
                                        WHEN @Operation = 3
                                        THEN @Amount
                                        ELSE Checks.Amount
                                    END;
     END;
GO