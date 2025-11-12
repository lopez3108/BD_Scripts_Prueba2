SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_HasPayrollExist] @UserId INT,
@LoginDate DATETIME = null 


AS
BEGIN

DECLARE @payRollExist BIT
  SET @payRollExist = 0
  IF EXISTS
                (
                    SELECT *
                    FROM dbo.Payrolls
                    WHERE CAST(@LoginDate AS DATE) BETWEEN CAST(dbo.Payrolls.FromDate AS DATE) AND CAST(dbo.Payrolls.ToDate AS DATE)
                          AND dbo.Payrolls.UserId = @UserId
                )
                    BEGIN
                       SET @payRollExist = 1
                    END;
 
 
 SELECT
    @payRollExist 

END;


GO