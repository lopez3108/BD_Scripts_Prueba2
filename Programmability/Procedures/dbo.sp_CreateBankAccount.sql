SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateBankAccount] @BankAccountId  INT            = NULL, 
                                             @BankId         INT, 
                                             @AccountNumber  VARCHAR(4), 
                                             @AccountOwnerId INT, 
                                             @Active         BIT, 
                                             @InitialBalance DECIMAL(18, 2),
                                                 @FullAccount  VARCHAR(15),
											 @CreatedBy INT,
											 @CreationDate DATETIME
AS
    BEGIN

	DECLARE @result int
	SET @result = 0


        IF(EXISTS
        (
            SELECT 1
            FROM [BankAccounts]
            WHERE AccountNumber = @AccountNumber
                  AND (@BankAccountId IS NULL
                       OR @BankAccountId <> BankAccountId)
        ))
            BEGIN
                SET @result = -1;
        END;
            ELSE
            BEGIN
                IF(@BankAccountId IS NULL)
                    BEGIN
                        INSERT INTO [dbo].[BankAccounts]
                        ([AccountNumber], 
                         [BankId], 
                         [Active], 
                         InitialBalance,
                         FullAccount,
						 CreatedBy,
						CreationDate
                        )
                        VALUES
                        (@AccountNumber, 
                         @BankId, 
                         @Active, 
                         @InitialBalance,
                         @FullAccount,
						 @CreatedBy,
						@CreationDate
                        );
                        DECLARE @bankAccountIdentity INT;
                        SET @bankAccountIdentity =
                        (
                            SELECT @@IDENTITY
                        );
                        INSERT INTO [dbo].[BankAccountsXProviderBanks]
                        ([BankAccountId], 
                         [AccountOwnerId]
                        )
                        VALUES
                        (@bankAccountIdentity, 
                         @AccountOwnerId
                        );
                        SET @result = @bankAccountIdentity;
                END;
                    ELSE
                    BEGIN
                        DECLARE @actualActive BIT;
                        SET @actualActive =
                        (
                            SELECT TOP 1 Active
                            FROM BankAccounts
                            WHERE BankAccountId = @BankAccountId
                        );
                        DECLARE @accountOwner INT;
                        SET @accountOwner =
                        (
                            SELECT TOP 1 AccountOwnerId
                            FROM dbo.BankAccountsXProviderBanks
                            WHERE BankAccountId = @BankAccountId
                        );
                        IF(@actualActive <> @Active)
                            BEGIN
                                IF(@Active = 1
                                   AND
                                (
                                    SELECT TOP 1 Active
                                    FROM AccountOwners
                                    WHERE AccountOwnerId = @accountOwner
                                ) = 0)
                                    BEGIN
                                        SET @result =-2;
                                END;

								IF(EXISTS(SELECT * FROM dbo.MoneyDistribution WHERE BankAccountId = @BankAccountId))
								BEGIN

								SET @result = -3;

								END
                        END;

						IF(@result >= 0)
						BEGIN
						 
                        UPDATE [dbo].[BankAccounts]
                          SET 
                              [AccountNumber] = @AccountNumber, 
                              Active = @Active, 
                              [BankId] = @BankId, 
                              InitialBalance = @InitialBalance,
                              FullAccount = @FullAccount
                        WHERE BankAccountId = @BankAccountId;
                        DELETE [dbo].[BankAccountsXProviderBanks]
                        WHERE BankAccountId = @BankAccountId;
                        INSERT INTO [dbo].[BankAccountsXProviderBanks]
                        ([BankAccountId], 
                         [AccountOwnerId]
                        )
                        VALUES
                        (@BankAccountId, 
                         @AccountOwnerId
                        );
                        SET @result = @BankAccountId;

						END


						END

						END

						SELECT @result
 
    END;

GO