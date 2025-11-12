SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllPayrollOthersByPayrollId](@PayrollId INT = NULL)
AS
     BEGIN
         SELECT p.*,
                p.Usd Value,
                p.Usd moneyvalue,
                'false' Valid,
                'false' AcceptZero,
                'true' AcceptNegative,
                'true' Disabled,
                'true' 'Set',
                A.Code+' - '+A.Name Agency,
                PT.Description OtherDescription,
                p.Description
         FROM PayrollOthers P
              INNER JOIN PayrollOtherTypes PT ON PT.PayrollOtherTypesId = P.PayrollOtherTypesId
              LEFT JOIN Agencies A ON A.AgencyId = P.AgencyId
         WHERE P.PayrollId = @PayrollId;
     END;

GO