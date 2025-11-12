SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--10-10-2024 Jt/6085 Add new commissions InsurancePolicy, InsuranceMonthlyPayment, InsuranceRegistration
-- 2024-03-24 Carlos/5761: Employee commissions payment
--This SP is call from sp_SaveExpense(when we save a new payment commissions cashiers, we need to update the all operations that was paid whit this expense)
--This SP is call from sp_DeleteExpenseById(Is when we delete an expense and we need to remove expense to each operation)
CREATE PROCEDURE [dbo].[sp_UpdateEmployeeCommissionsPaid] (@CashierId INT,
@AgencyId INT,
@ExpenseId INT NULL, --PARA CREAR
@ExpenseIdOld INT NULL--PARA ELIMINAR
)
AS
BEGIN

  DECLARE @endDate DATE = NULL
  DECLARE @Year SMALLINT = NULL
  DECLARE @Month TINYINT = NULL

  IF (@ExpenseId IS NOT NULL) -- If adding new expense commission paymente
  BEGIN


    SELECT TOP 1
      @Year = e.Year
     ,@Month = m.Number
    FROM dbo.Expenses e
    INNER JOIN Months m
      ON e.MonthsId = m.MonthId
    WHERE e.ExpenseId = @ExpenseId
    --  SET @endDate = DATEADD(DAY, 1, @endDate)
    SET @endDate = eomonth(datefromparts(@Year, @Month, 1))
  END

  DECLARE @userId INT
  SET @userId = (SELECT TOP 1
      UserId
    FROM dbo.Cashiers c
    WHERE c.CashierId = @CashierId)

  UPDATE dbo.CityStickers
  SET ExpenseId = @ExpenseId
  WHERE CashierCommission > 0
  AND CreatedBy = @userId
  AND AgencyId = @AgencyId
  AND (
  (@ExpenseId IS NOT NULL
  AND ExpenseId IS NULL)
  OR @ExpenseId IS NULL
  AND @ExpenseIdOld IS NOT NULL
  AND ExpenseId = @ExpenseIdOld)
  AND (@endDate IS NULL
  OR CAST(CreationDate AS DATE) <= CAST(@endDate AS DATE))

  UPDATE dbo.Titles
  SET ExpenseId = @ExpenseId

  WHERE CashierCommission > 0
  AND CreatedBy = @userId
  AND AgencyId = @AgencyId
  AND (
  (@ExpenseId IS NOT NULL
  AND ExpenseId IS NULL)
  OR @ExpenseId IS NULL
  AND @ExpenseIdOld IS NOT NULL
  AND ExpenseId = @ExpenseIdOld)
  AND (@endDate IS NULL
  OR CAST(CreationDate AS DATE) <= CAST(@endDate AS DATE))


  --	UPDATE dbo.Notary  SET ExpenseId = @ExpenseId
  --
  --	WHERE  CreatedBy = @userId AND AgencyId = @AgencyId AND (  
  --  (@ExpenseId IS NOT NULL AND ExpenseId IS NULL) OR
  -- @ExpenseId IS NULL AND  @ExpenseIdOld IS NOT NULL and ExpenseId = @ExpenseIdOld)
  --	AND (@endDate IS NULL OR CAST(CreationDate AS DATE) <= CAST(@endDate as DATE))

  UPDATE dbo.Lendify
  SET ExpenseId = @ExpenseId

  WHERE CreatedBy = @userId
  AND AgencyId = @AgencyId
  AND (
  (@ExpenseId IS NOT NULL
  AND ExpenseId IS NULL)
  OR @ExpenseId IS NULL
  AND @ExpenseIdOld IS NOT NULL
  AND ExpenseId = @ExpenseIdOld)
  AND (@endDate IS NULL
  OR CAST(CreationDate AS DATE) <= CAST(@endDate AS DATE))


  --	UPDATE dbo.Financing  SET ExpenseId = @ExpenseId
  --
  --WHERE CreatedBy = @userId AND AgencyId = @AgencyId AND (  
  --  ((@ExpenseId IS NOT NULL AND ExpenseId = NULL) OR
  --  @ExpenseIdOld IS NULL and ExpenseId = @ExpenseIdOld))
  --	AND (@endDate IS NULL OR CAST(CreatedOn AS DATE) <= CAST(@endDate as DATE))



  UPDATE dbo.PlateStickers
  SET ExpenseId = @ExpenseId
  WHERE CashierCommission > 0
  AND CreatedBy = @userId
  AND AgencyId = @AgencyId
  AND (
  (@ExpenseId IS NOT NULL
  AND ExpenseId IS NULL)
  OR @ExpenseId IS NULL
  AND @ExpenseIdOld IS NOT NULL
  AND ExpenseId = @ExpenseIdOld)
  AND (@endDate IS NULL
  OR CAST(CreationDate AS DATE) <= CAST(@endDate AS DATE))

  --	UPDATE dbo.ParkingTickets  SET ExpenseId = @ExpenseId
  --WHERE CreatedBy = @userId AND AgencyId = @AgencyId AND (  
  --  ((@ExpenseId IS NOT NULL AND ExpenseId = NULL) OR
  --  @ExpenseIdOld IS NULL and ExpenseId = @ExpenseIdOld))
  --	AND (@endDate IS NULL OR CAST(CreationDate AS DATE) <= CAST(@endDate as DATE))

  UPDATE dbo.TRP
  SET ExpenseId = @ExpenseId
  WHERE CashierCommission > 0
  AND CreatedBy = @userId
  AND AgencyId = @AgencyId
  AND (
  (@ExpenseId IS NOT NULL
  AND ExpenseId IS NULL)
  OR @ExpenseId IS NULL
  AND @ExpenseIdOld IS NOT NULL
  AND ExpenseId = @ExpenseIdOld)
  AND (@endDate IS NULL
  OR CAST(CreatedOn AS DATE) <= CAST(@endDate AS DATE))

  --	DECLARE @inventoryAgencyId INT
  --	SET @inventoryAgencyId = (SELECT TOP 1 InventoryByAgencyId FROM dbo.InventoryByAgency i WHERE i.AgencyId = @AgencyId)
  --
  --	UPDATE dbo.PhoneSales SET ExpenseId = @ExpenseId
  --	WHERE CreatedBy = @userId AND InventoryByAgencyId = @inventoryAgencyId AND (@ExpenseIdOld IS NULL OR ExpenseId = @ExpenseIdOld)
  --	AND (@endDate IS NULL OR CAST(CreationDate AS DATE) <= CAST(@endDate as DATE))


  UPDATE dbo.PhoneSales
  SET ExpenseId = @ExpenseId
  FROM InventoryByAgency i
  INNER JOIN PhoneSales ps
    ON i.InventoryByAgencyId = ps.InventoryByAgencyId
  WHERE CashierCommission > 0
  AND CreatedBy = @userId
  AND AgencyId = @AgencyId
  AND (
  (@ExpenseId IS NOT NULL
  AND ExpenseId IS NULL)
  OR @ExpenseId IS NULL
  AND @ExpenseIdOld IS NOT NULL
  AND ExpenseId = @ExpenseIdOld)
  AND (@endDate IS NULL
  OR CAST(CreationDate AS DATE) <= CAST(@endDate AS DATE))


  --	UPDATE dbo.ParkingTicketsCards  SET ExpenseId = @ExpenseId 
  --WHERE CreatedBy = @userId AND AgencyId = @AgencyId AND (  
  --  ((@ExpenseId IS NOT NULL AND ExpenseId = NULL) OR
  --  @ExpenseIdOld IS NULL and ExpenseId = @ExpenseIdOld))
  --	AND (@endDate IS NULL OR CAST(CreationDate AS DATE) <= CAST(@endDate as DATE))

  UPDATE dbo.Tickets
  SET ExpenseId = @ExpenseId
  WHERE CashierCommission > 0
  AND CreatedBy = @userId
  AND AgencyId = @AgencyId
  AND (
  (@ExpenseId IS NOT NULL
  AND ExpenseId IS NULL)
  OR @ExpenseId IS NULL
  AND @ExpenseIdOld IS NOT NULL
  AND ExpenseId = @ExpenseIdOld)
  AND (@endDate IS NULL
  OR CAST(CreationDate AS DATE) <= CAST(@endDate AS DATE))

  UPDATE dbo.TicketFeeServiceDetails
  SET ExpenseId = @ExpenseId
  FROM TicketFeeServices tfs
  INNER JOIN TicketFeeServiceDetails
    ON tfs.TicketFeeServiceId = TicketFeeServiceDetails.TicketFeeServiceId


  WHERE TicketFeeServiceDetails.CashierCommission > 0
  AND tfs.CreatedBy = @userId
  AND tfs.AgencyId = @AgencyId
  AND (
  (@ExpenseId IS NOT NULL
  AND ExpenseId IS NULL)
  OR @ExpenseId IS NULL
  AND @ExpenseIdOld IS NOT NULL
  AND ExpenseId = @ExpenseIdOld)
  AND (@endDate IS NULL
  OR CAST(TicketFeeServiceDetails.CompletedOn AS DATE) <= CAST(@endDate AS DATE))


--Update the return operations pay whit this expense, or when is called from deleteexpense, we need to remove the ExpensePaidId paid whit the ExpenseId
  UPDATE dbo.CommissionsEmployeesReturn
  SET ExpensePaidId = @ExpenseId
  WHERE CreatedBy = @userId
  AND AgencyId = @AgencyId
  AND (
  (@ExpenseId IS NOT NULL
  AND ExpensePaidId IS NULL)
  OR @ExpenseId IS NULL
  AND @ExpenseIdOld IS NOT NULL
  AND ExpensePaidId = @ExpenseIdOld)
  AND (@endDate IS NULL
  OR CAST(CreationDate AS DATE) <= CAST(@endDate AS DATE))


 UPDATE dbo.InsurancePolicy
  SET ExpenseId = @ExpenseId
  WHERE CashierCommission > 0
  AND CreatedBy = @userId
  AND CreatedInAgencyId = @AgencyId
  AND (
  (@ExpenseId IS NOT NULL
  AND ExpenseId IS NULL)
  OR @ExpenseId IS NULL
  AND @ExpenseIdOld IS NOT NULL
  AND ExpenseId = @ExpenseIdOld)
  AND (@endDate IS NULL
  OR CAST(CreationDate AS DATE) <= CAST(@endDate AS DATE))


 UPDATE dbo.InsuranceMonthlyPayment
  SET ExpenseId = @ExpenseId
  WHERE CashierCommission > 0
  AND CreatedBy = @userId
  AND CreatedInAgencyId = @AgencyId
  AND (
  (@ExpenseId IS NOT NULL
  AND ExpenseId IS NULL)
  OR @ExpenseId IS NULL
  AND @ExpenseIdOld IS NOT NULL
  AND ExpenseId = @ExpenseIdOld)
  AND (@endDate IS NULL
  OR CAST(CreationDate AS DATE) <= CAST(@endDate AS DATE))


 UPDATE dbo.InsuranceRegistration
  SET ExpenseId = @ExpenseId
  WHERE CashierCommission > 0
  AND CreatedBy = @userId
  AND CreatedInAgencyId = @AgencyId
  AND (
  (@ExpenseId IS NOT NULL
  AND ExpenseId IS NULL)
  OR @ExpenseId IS NULL
  AND @ExpenseIdOld IS NOT NULL
  AND ExpenseId = @ExpenseIdOld)
  AND (@endDate IS NULL
  OR CAST(CreationDate AS DATE) <= CAST(@endDate AS DATE))


END;




GO