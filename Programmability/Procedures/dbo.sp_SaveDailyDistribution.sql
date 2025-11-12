SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created by jf/29-08-2025 task 6736 Pagar menos de lo disponible cuando se hace Money distribution

CREATE PROCEDURE [dbo].[sp_SaveDailyDistribution]
(@DailyDistributionId INT            = NULL, 
 @Usd                 DECIMAL(18, 2)  = NULL, 
 @DailyId             INT            = NULL, 
 @MoneyDistributionId INT            = NULL, 
 @PackageNumber       VARCHAR(15)    = NULL, 
 @ImageName           VARCHAR(100) = NULL, 
 @ImageNameBook       VARCHAR(100) = NULL,
 @CreationDate        DATETIME  = NULL,
 @CreatedBy           INT = NULL,
 @UpdatedOn           DATETIME  = NULL,
 @UpdatedBy           INT = NULL
)
AS
    BEGIN
        IF(@DailyDistributionId IS NULL)
            BEGIN
                DECLARE @providerId INT;
                SET @providerId = NULL;
                DECLARE @agencyId INT;
                SET @agencyId = NULL;
                DECLARE @code VARCHAR(20);
                SET @code = NULL;
                DECLARE @bankAccountId INT;
                SET @bankAccountId = NULL;
                IF(@MoneyDistributionId IS NOT NULL)
                    BEGIN
                        SET @providerId =
                        (
                            SELECT TOP 1 dbo.MoneyTransferxAgencyNumbers.ProviderId
                            FROM dbo.MoneyDistribution
                                 INNER JOIN dbo.MoneyTransferxAgencyNumbers ON dbo.MoneyDistribution.MoneyTransferxAgencyNumbersId = dbo.MoneyTransferxAgencyNumbers.MoneyTransferxAgencyNumbersId
                            WHERE dbo.MoneyDistribution.MoneyDistributionId = @MoneyDistributionId
                        );
                        SET @agencyId =
                        (
                            SELECT TOP 1 dbo.MoneyTransferxAgencyNumbers.AgencyId
                            FROM dbo.MoneyDistribution
                                 INNER JOIN dbo.MoneyTransferxAgencyNumbers ON dbo.MoneyDistribution.MoneyTransferxAgencyNumbersId = dbo.MoneyTransferxAgencyNumbers.MoneyTransferxAgencyNumbersId
                            WHERE dbo.MoneyDistribution.MoneyDistributionId = @MoneyDistributionId
                        );
                        SET @code =
                        (
                            SELECT TOP 1 dbo.MoneyTransferxAgencyNumbers.Number
                            FROM dbo.MoneyDistribution
                                 INNER JOIN dbo.MoneyTransferxAgencyNumbers ON dbo.MoneyDistribution.MoneyTransferxAgencyNumbersId = dbo.MoneyTransferxAgencyNumbers.MoneyTransferxAgencyNumbersId
                            WHERE dbo.MoneyDistribution.MoneyDistributionId = @MoneyDistributionId
                        );
                        SET @bankAccountId =
                        (
                            SELECT BankAccountId
                            FROM dbo.MoneyDistribution
                            WHERE dbo.MoneyDistribution.MoneyDistributionId = @MoneyDistributionId
                        );
                    END;
                INSERT INTO [dbo].DailyDistribution
                (DailyId, 
                 ProviderId, 
                 AgencyId, 
                 Code, 
                 BankAccountId, 
                 Usd, 
                 PackageNumber, 
                 ImageName, 
                 ImageNameBook,
                 CreationDate,
                 CreatedBy            
                )
                VALUES
                (@DailyId, 
                 @providerId, 
                 @agencyId, 
                 @code, 
                 @bankAccountId, 
                 @Usd, 
                 @PackageNumber, 
                 @ImageName, 
                 @ImageNameBook,
                 @CreationDate,
                 @CreatedBy          
                );
                SELECT @@IDENTITY;
            END;
            ELSE
            BEGIN
                UPDATE [dbo].DailyDistribution
                  SET 
                      PackageNumber = @PackageNumber, 
                      ImageName = @ImageName, 
                      ImageNameBook = @ImageNameBook,               
                      UpdatedOn    = @UpdatedOn,
                      UpdatedBy     = @UpdatedBy
                WHERE DailyDistributionId = @DailyDistributionId;
                SELECT @DailyDistributionId;
            END;
    END;
GO