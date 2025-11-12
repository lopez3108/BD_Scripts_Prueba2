SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created: FELIPE
--Created: 18-03-2024
--Task 5721 Consultamos si el carpayment ya fue pagado 


CREATE PROCEDURE [dbo].[sp_GetClosedOnCardPaymentsAdminByDailyId]
 ( 
    @AgencyId INT = NULL,
    @CashierId INT = NULL,  
    @CreatedOn DATE = NULL
 )

AS
--    DECLARE @CashierId INT ;
--    SET @CashierId = (SELECT TOP 1
--      c.CashierId
--    FROM Cashiers c 
--    WHERE c.UserId = @CreatedBy )

     BEGIN
        SELECT
          d.ClosedByCardPaymentsAdmin,d.ClosedOnCardPaymentsAdmin,d.ClosedOn,d.ClosedBy
        FROM Daily d       
        WHERE d.AgencyId= @AgencyId AND d.CashierId = @CashierId  AND 
        CAST(d.CreationDate AS DATE) = CAST(@CreatedOn AS DATE)
     END;




GO