SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      JF
-- Create date: 13/07/2024 6:01 p. m.
-- Database:    copiaDevtest
-- Description: task 5916 Aplicar fee a los para los VEHICLE SERVICES RETURNED
-- =============================================

CREATE PROCEDURE [dbo].[sp_SaveReturnsELS]
(@ReturnsELSId   INT          = NULL,
 @InventoryELSId INT,
 @Number         VARCHAR(20),
 @Reason         VARCHAR(100) = NULL,
 @AgencyId       INT,
 @CreatedBy      INT,
 @CreatedOn      DATETIME,
 @LastUpdatedBy      INT,
 @LastUpdatedOn      DATETIME,
 @PackageNumber         VARCHAR(30) = NULL,
 @ShippingDate      DATETIME = NULL,
 @CashierId INT = NULL,
 @ReturnType BIT = NULL,
 @Fee DECIMAL(18, 2)
)
AS
    BEGIN TRY
        BEGIN TRANSACTION;
        
       
	   
	   DECLARE @StatusId INT
	   SET @StatusId = (SELECT TOP 1 ReturnsELSStatusId FROM ReturnELSStatus WHERE Code = 'C01')

	   IF(@PackageNumber IS NOT NULL)
	   BEGIN

	   SET @StatusId = (SELECT TOP 1 ReturnsELSStatusId FROM ReturnELSStatus WHERE Code = 'C02')


	   END


	   IF(@ReturnsELSId IS NULL)
	   BEGIN


	   DECLARE @currentInventory INT


	   IF(@CashierId IS NULL)
	   BEGIN

	   SET @currentInventory = ISNULL((SELECT TOP 1 InStock FROM InventoryELSByAgency WHERE InventoryELSId = @InventoryELSId AND AgencyId = @AgencyId),0)

	   END
	   ELSE
	   BEGIN

	   SET @currentInventory = ISNULL((SELECT TOP 1 InStock FROM InventoryELSByAgency WHERE InventoryELSId = @InventoryELSId AND AgencyId = @AgencyId AND CashierId = @CashierId),0)

	   END
	   -- No puede retornar mas items de los que tiene el inventario
	  IF(@currentInventory < @Number)
	  BEGIN

	  SELECT -1

	  END
	  ELSE
	  BEGIN
	  
	  UPDATE [dbo].[InventoryELSByAgency]
          SET
              InStock = InStock - @Number
        WHERE InventoryELSId = @InventoryELSId
              AND AgencyId = @AgencyId
			  AND (@CashierId IS NULL OR @CashierId = CashierId)
	   
	   INSERT INTO [dbo].[ReturnsELS]
        (
          InventoryELSId,
          Number,
          Reason,
          AgencyId,
          CreatedBy,
          CreatedOn,
          LastUpdatedBy,
          LastUpdatedOn,
          PackageNumber,
          ReturnsELSStatusId,
          ShippingDate,
          CashierId,
          ReturnType,
          Fee
        )
        VALUES
        (
          @InventoryELSId,
          @Number,
          @Reason,
          @AgencyId,
          @CreatedBy,
          @CreatedOn,
          @LastUpdatedBy,
          @LastUpdatedOn,
          @PackageNumber,
          @StatusId,
          @ShippingDate,
          @CashierId,
          @ReturnType,
          @Fee
        );

		SELECT @@IDENTITY

		END

		END
		ELSE
		BEGIN

		DECLARE @currentStatus VARCHAR(3)
		SET @currentStatus = (SELECT TOP 1 ReturnELSStatus.Code
FROM     ReturnELSStatus WHERE ReturnsELSStatusId = (SELECT TOP 1 ReturnsELSStatusId FROM [dbo].[ReturnsELS] WHERE ReturnsELSId = @ReturnsELSId))

-- Solo se pueden editar retornos en estado estado PENDING SHIPPING
IF(@currentStatus = 'C01')
BEGIN
UPDATE [dbo].[ReturnsELS]
   SET [InventoryELSId] = @InventoryELSId
      ,[Number] = @Number
      ,[Reason] = @Reason
      ,[ReturnsELSStatusId] = @StatusId
      ,[PackageNumber] = @PackageNumber
      ,[LastUpdatedOn] = @CreatedOn
      ,[LastUpdatedBy] = @CreatedBy
      ,[ShippingDate] = @ShippingDate
 WHERE ReturnsELSId = @ReturnsELSId

 SELECT @ReturnsELSId
 END

		END
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
    END CATCH;
GO