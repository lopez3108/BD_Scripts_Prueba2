SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveConcilliationSalesTax]
(@ConciliationSalesTaxId INT      = NULL,
 @Date                   DATETIME,
 @AgencyId               INT,
 @BankAccountId          INT,
 @FromDate               DATETIME,
 @ToDate                 DATETIME,
 @IsCredit               BIT,
 @CreatedBy              INT,
 @CreationDate           DATETIME,
 @Usd DECIMAL (18,2)
)
AS
     BEGIN
         IF(@ConciliationSalesTaxId IS NULL)
             BEGIN
                 INSERT INTO [dbo].ConciliationSalesTaxes
                 (Date,
                  AgencyId,
                  BankAccountId,
                  FromDate,
                  ToDate,
                  IsCredit,
                  CreatedBy,
                  CreationDate,
			   Usd
                 )
                 VALUES
                 (@Date,
                  @AgencyId,
                  @BankAccountId,
                  @FromDate,
                  @ToDate,
                  @IsCredit,
                  @CreatedBy,
                  @CreationDate,
			   @Usd
                 );
                 --SET @IdCreated = @@IDENTITY;
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].ConciliationSalesTaxes
                   SET
                       Date = @Date
                 WHERE ConciliationSalesTaxId = @ConciliationSalesTaxId;
                 --SET @IdCreated = 0;
         END;
     END;
GO