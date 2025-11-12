SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_CalculateExtraFundInitialBalance](@AgencyId INT, 
                                                           @EndDate  DATETIME = NULL)
RETURNS DECIMAL(18, 2)
AS
     BEGIN
         RETURN(ISNULL(
         (

             -- Admin to cashiers
             SELECT ISNULL(SUM(dbo.ExtraFund.Usd), 0)
             FROM dbo.ExtraFund
                  INNER JOIN dbo.Users ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
                  INNER JOIN dbo.UserTypes ON dbo.Users.UserType = dbo.UserTypes.UsertTypeId
             WHERE dbo.UserTypes.Code = 'Admin'
                   AND dbo.ExtraFund.AgencyId = @AgencyId
                   AND CAST(dbo.ExtraFund.CreationDate AS DATE) < CAST(@EndDate AS DATE)
         ), 0) - -- Cashiers from Admin

         ISNULL(
         (
             SELECT ISNULL(SUM(dbo.ExtraFund.Usd), 0)
             FROM dbo.ExtraFund
                  INNER JOIN dbo.Users ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
                  INNER JOIN dbo.UserTypes ON dbo.Users.UserType = dbo.UserTypes.UsertTypeId
             WHERE dbo.UserTypes.Code = 'Admin'
                   AND dbo.ExtraFund.AgencyId = @AgencyId
                   AND CAST(dbo.ExtraFund.CreationDate AS DATE) < CAST(@EndDate AS DATE)
         ), 0) + -- Cashiers to Cashiers

         ISNULL(
         (
             SELECT ISNULL(SUM(dbo.ExtraFund.Usd), 0)
             FROM dbo.ExtraFund
                  INNER JOIN dbo.Users ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
                  INNER JOIN dbo.UserTypes ON dbo.Users.UserType = dbo.UserTypes.UsertTypeId
             WHERE dbo.UserTypes.Code = 'Cashier'
			  AND dbo.ExtraFund.IsCashier = 1
                   AND dbo.ExtraFund.AgencyId = @AgencyId
                   AND CAST(dbo.ExtraFund.CreationDate AS DATE) < CAST(@EndDate AS DATE)
         ), 0) - -- Cashiers from Cashiers

         ISNULL(
         (
             SELECT ISNULL(SUM(dbo.ExtraFund.Usd), 0)
             FROM dbo.Users AS Users_1
                  INNER JOIN dbo.ExtraFund ON Users_1.UserId = dbo.ExtraFund.AssignedTo
                  INNER JOIN dbo.UserTypes AS UserTypes_1 ON Users_1.UserType = UserTypes_1.UsertTypeId
                  INNER JOIN dbo.UserTypes
                  INNER JOIN dbo.Users ON dbo.UserTypes.UsertTypeId = dbo.Users.UserType ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
             WHERE dbo.UserTypes.Code = 'Cashier'
                   AND UserTypes_1.Code = 'Cashier'
				   AND dbo.ExtraFund.IsCashier = 1
                   AND dbo.ExtraFund.AgencyId = @AgencyId
                   AND CAST(dbo.ExtraFund.CreationDate AS DATE) < CAST(@EndDate AS DATE)
         ), 0) + -- Cashiers to Admin

         ISNULL(
         (
             SELECT ISNULL(SUM(dbo.ExtraFund.Usd), 0)
             FROM dbo.ExtraFund
                  INNER JOIN dbo.Users ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
                  INNER JOIN dbo.UserTypes ON dbo.Users.UserType = dbo.UserTypes.UsertTypeId
             WHERE dbo.UserTypes.Code = 'Cashier'
                   AND dbo.ExtraFund.CashAdmin = 1
                   AND dbo.ExtraFund.AgencyId = @AgencyId
                   AND CAST(dbo.ExtraFund.CreationDate AS DATE) < CAST(@EndDate AS DATE)
         ), 0) - -- Admin from Cashiers

         ISNULL(
         (
             SELECT ISNULL(SUM(dbo.ExtraFund.Usd), 0)
             FROM dbo.Users AS Users_1
                  INNER JOIN dbo.ExtraFund ON Users_1.UserId = dbo.ExtraFund.AssignedTo
                  INNER JOIN dbo.UserTypes AS UserTypes_1 ON Users_1.UserType = UserTypes_1.UsertTypeId
                  INNER JOIN dbo.UserTypes
                  INNER JOIN dbo.Users ON dbo.UserTypes.UsertTypeId = dbo.Users.UserType ON dbo.ExtraFund.CreatedBy = dbo.Users.UserId
             WHERE dbo.UserTypes.Code = 'Cashier'
                   AND UserTypes_1.Code = 'Cashier'
                   AND dbo.ExtraFund.CashAdmin = 1
                   AND dbo.ExtraFund.AgencyId = @AgencyId
                   AND CAST(dbo.ExtraFund.CreationDate AS DATE) < CAST(@EndDate AS DATE)
         ), 0));
     END;

GO