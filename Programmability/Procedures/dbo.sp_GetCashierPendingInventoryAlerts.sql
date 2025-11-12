SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--2025-07-23 JF/ 6661: Nueva alerta QA Vehicle services PENDING TO RECEIVE

CREATE PROCEDURE [dbo].[sp_GetCashierPendingInventoryAlerts] (@UserId INT = NULL,
@AgencyId INT = NULL,
@Date DATETIME,
@IsManager AS BIT = NULL,
@UserLoginId INT = NULL)
AS
BEGIN

  DECLARE @pendingStatus INT
  SET @pendingStatus = (SELECT TOP 1
      InventoryELSOrdersStatusId
    FROM InventoryELSOrdersStatus
    WHERE Code = 'C01')

  DECLARE @pendingOrders INT

  SET @pendingOrders = ISNULL((SELECT
      COUNT(*)
    FROM InventoryELSOrders
    INNER JOIN InventoryELSByAgency
      ON InventoryELSByAgency.InventoryELSByAgencyId = InventoryELSOrders.InventoryELSByAgencyId


    WHERE (InventoryELSByAgency.AgencyId = @AgencyId
    OR @AgencyId IS NULL)
    AND InventoryELSOrders.InventoryELSOrdersStatusId = @pendingStatus
    AND CAST(InventoryELSOrders.OrderDate AS DATE) <= CAST(@Date AS DATE))
  , 0)


  DECLARE @sentStatus INT
  SET @sentStatus = (SELECT TOP 1
      InventoryELSOrdersStatusId
    FROM InventoryELSOrdersStatus
    WHERE Code = 'C03')


  DECLARE @sentOrders INT

  SET @sentOrders = ISNULL((SELECT
      COUNT(*)
    FROM InventoryELSOrders
    INNER JOIN InventoryELSByAgency
      ON InventoryELSByAgency.InventoryELSByAgencyId = InventoryELSOrders.InventoryELSByAgencyId
    WHERE (InventoryELSByAgency.AgencyId = @AgencyId
    OR @AgencyId IS NULL)
    AND InventoryELSOrders.InventoryELSOrdersStatusId = @sentStatus
    AND CAST(InventoryELSOrders.OrderDate AS DATE) <= CAST(@Date AS DATE))
  , 0)


  DECLARE @pendingShippingStatus INT
  SET @pendingShippingStatus = (SELECT TOP 1
      ReturnsELSStatusId
    FROM ReturnELSStatus
    WHERE Code = 'C01')

  DECLARE @pendingReturns INT

  SET @pendingReturns = ISNULL((SELECT
      COUNT(*)
    FROM ReturnsELS
    WHERE (ReturnsELS.CreatedBy = @UserId
    OR @UserId IS NULL)
    AND ((@IsManager = 0
    AND (ReturnsELS.AgencyId = @AgencyId
    OR @AgencyId IS NULL))
    OR (@IsManager = 1
    AND ReturnsELS.AgencyId IN (SELECT
        AgencyId
      FROM AgenciesxUser
      WHERE UserId = @UserLoginId)
    ))
    AND ReturnsELS.ReturnsELSStatusId = @pendingShippingStatus
    AND CAST(ReturnsELS.CreatedOn AS DATE) <= CAST(@Date AS DATE))
  , 0)


  SELECT
    @pendingOrders AS PendingOrders
   ,@pendingReturns AS PendingReturns
   ,@sentOrders AS SentOrders

END;
GO