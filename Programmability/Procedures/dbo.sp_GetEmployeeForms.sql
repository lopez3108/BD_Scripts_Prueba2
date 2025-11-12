SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetEmployeeForms]
AS
     BEGIN
         SELECT *,C.w4 w4Saved, C.Confidentiality ConfidentialitySaved
		         ,C.DirectDeposit DirectDepositSaved, C.BiometricInformation BiometricInformationSaved
             ,C.ComplianceOfficer ComplianceOfficerSaved,
             c.EmploymentApplication AS EmploymentApplicationSaved,
             c.EmploymentWarning AS EmploymentWarningSaved
 FROM CashierForms AS C
		
                
     END;




GO