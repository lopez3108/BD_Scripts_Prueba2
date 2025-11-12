SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      JF
-- Create date: 2/07/2024 5:13 p. m.
-- Database:    copiaDevtest
-- Description: task 5905 Comisión pagada en 0.00 debe reflejarse en el reporte
-- =============================================



CREATE PROCEDURE [dbo].[sp_CreateProviderCommissionPayment]
(@ProviderCommissionPaymentId     INT            = NULL,
 @ProviderId                      INT,
 @AgencyId                        INT,
 @Month                           INT,
 @Year                            INT,
 @ProviderCommissionPaymentTypeId INT,
 @Usd                             DECIMAL(18, 2),
 @UsdMoneyOrders                  DECIMAL(18, 2)  = NULL,
 @BankId                          INT            = NULL,
 @CheckNumber                     VARCHAR(15)    = NULL,
 @Account                         VARCHAR(4)     = NULL,
 @CreationDate                    DATETIME,
 @CreatedBy                       INT,
 @CheckDate                       DATETIME       = NULL,
 @AchDate                         DATETIME       = NULL,
 @AdjustmentDate                  DATETIME       = NULL,
 @LastUpdatedBy                   INT            = NULL,
 @LastUpdatedDate                 DATETIME       = NULL,
 @ValidatedOn                     DATETIME       = NULL,
 @ValidatedBy                     INT            = NULL,
 @BankAccountId                   INT            = NULL,
 @TotalTransactions                   INT            = NULL,
 @IsForex                   BIT
)
AS
     BEGIN
         IF(@ProviderCommissionPaymentId IS NULL)
             BEGIN

			 DECLARE @canCreate BIT 
			 SET @canCreate = CAST(1 as BIT)

			 DECLARE @balanceManualTypeId INT
			 SET @balanceManualTypeId = (SELECT TOP 1 ProviderCommissionPaymentTypeId FROM ProviderCommissionPaymentTypes 
			 WHERE Code = 'CODE08')

       DECLARE @providerTypeCode  VARCHAR(5); --Verifica el tipo de proveedor 
			 SET @providerTypeCode  = (SELECT pt.Code from Providers p
      INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
      WHERE p.ProviderId = @ProviderId)


			 IF( @ProviderCommissionPaymentTypeId = @balanceManualTypeId AND @providerTypeCode = 'C01'  )
			 BEGIN

			 IF(NOT EXISTS (SELECT * FROM dbo.PaymentBalance pb
			 WHERE pb.AgencyId =@AgencyId AND pb.ProviderId = @ProviderId AND
			 pb.Year = @Year AND pb.Month = @Month))
			 BEGIN

			 SET @canCreate = CAST(0 as BIT)

			 END


			 END


			 IF(CAST(@canCreate as BIT) = CAST(1 as BIT))
			 BEGIN

			 IF(EXISTS(SELECT * FROM [dbo].[ProviderCommissionPayments] p
			 WHERE p.ProviderId = @ProviderId AND p.Month = @Month AND p.Year = @Year AND p.AgencyId = @AgencyId AND 
			 ((CAST(@IsForex as BIT) = CAST(0 as BIT) AND p.IsForex IS NULL) OR CAST(p.IsForex AS BIT) = CAST(@IsForex as BIT))))
			 BEGIN

			 SELECT -3

			 END
			 ELSE
			 BEGIN


			 INSERT INTO [dbo].[ProviderCommissionPayments]
                 ([ProviderId],
                  [Month],
                  [Year],
                  [ProviderCommissionPaymentTypeId],
                  [Usd],
                  UsdMoneyOrders,
                  [CheckNumber],
                  [CheckDate],
                  [BankId],
                  [Account],
                  [AgencyId],
                  [CreationDate],
                  [CreatedBy],
                  [LastUpdatedDate],
                  [LastUpdatedBy],
                  [AchDate],
                  [AdjustmentDate],
                  [ValidatedOn],
                  [ValidatedBy],
                  [BankAccountId],
				  TotalTransactions,
				  [IsForex]
                 )
                 VALUES
                 (@ProviderId,
                  @Month,
                  @Year,
                  @ProviderCommissionPaymentTypeId,
                  @Usd,
                  @UsdMoneyOrders,
                  @CheckNumber,
                  @CheckDate,
                  @BankId,
                  @Account,
                  @AgencyId,
                  @CreationDate,
                  @CreatedBy,
                  @LastUpdatedDate,
                  @LastUpdatedBy,
                  @AchDate,
                  @AdjustmentDate,
                  NULL,
                  NULL,
                  @BankAccountId,
				  @TotalTransactions,
				  @IsForex
                 );
                 SELECT @@IDENTITY;

				 END

				 END
			 ELSE
			 BEGIN

			 SELECT -1


			 END
			 END
             ELSE
             BEGIN
                 UPDATE [dbo].[ProviderCommissionPayments]
                   SET
                       [ProviderId] = @ProviderId,
                       [Month] = @Month,
                       [Year] = @Year,
                       [ProviderCommissionPaymentTypeId] = @ProviderCommissionPaymentTypeId,
                       [Usd] = @Usd,
                       UsdMoneyOrders = @UsdMoneyOrders,
                       [CheckNumber] = @CheckNumber,
                       [CheckDate] = @CheckDate,
                       [BankId] = @BankId,
                       [Account] = @Account,
                       [LastUpdatedDate] = @LastUpdatedDate,
                       [LastUpdatedBy] = @LastUpdatedBy,
                       [AchDate] = @AchDate,
                       [AdjustmentDate] = @AdjustmentDate,
                       BankAccountId = @BankAccountId,
					   TotalTransactions = @TotalTransactions
                 WHERE ProviderCommissionPaymentId = @ProviderCommissionPaymentId;
                 SELECT @ProviderCommissionPaymentId;
         END;
     END;
GO