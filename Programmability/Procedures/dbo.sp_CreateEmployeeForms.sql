SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Crea una nota de una propiedad
-- =============================================

-- date 21-05-2025 task 6487 MODULO SICK HOURS - ADJUSTMENT PAID SICK TIME JF

CREATE PROCEDURE [dbo].[sp_CreateEmployeeForms]
            @CashierFormsId int = null,
            @W4 varchar(1000) = NULL,
	        @Confidentiality varchar(1000) = NULL,
	        @DirectDeposit varchar(1000) = NULL,
	        @BiometricInformation varchar(1000) = NULL,
          @ComplianceOfficer varchar(1000) = NULL,
          @EmploymentApplication  varchar(1000) = NULL,
              @EmploymentWarning  varchar(1000) = NULL,
               @PaidSickTime varchar(1000) = NULL
 		 AS
		  
BEGIN

IF(@CashierFormsId IS NULL)
BEGIN

INSERT INTO [dbo].[CashierForms]
           ([W4]
		   ,[Confidentiality]
		   ,[DirectDeposit]
		   ,[BiometricInformation]
       ,[ComplianceOfficer],
       EmploymentApplication,
       EmploymentWarning,
       PaidSickTime)
     VALUES
            (@W4
		   ,@Confidentiality
		   ,@DirectDeposit
		   ,@BiometricInformation
       ,@ComplianceOfficer,
       @EmploymentApplication,
       @EmploymentWarning
       ,@PaidSickTime)
                      
   		   SELECT @@IDENTITY
		     END
		   ELSE
		   BEGIN

		    UPDATE [dbo].CashierForms SET 
		   W4 =                   @W4, 		 
		   Confidentiality =      @Confidentiality, 
		   DirectDeposit =        @DirectDeposit,
		   BiometricInformation = @BiometricInformation,
       ComplianceOfficer =    @ComplianceOfficer,
       EmploymentApplication = @EmploymentApplication,
       EmploymentWarning = @EmploymentWarning,
        PaidSickTime = @PaidSickTime

		 
		   WHERE CashierFormsId	 = @CashierFormsId

		   SELECT @CashierFormsId
		   END
		  

END





GO