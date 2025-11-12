SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-02-22 CB/6365: Insurance quot

CREATE PROCEDURE [dbo].[sp_CreateInsuranceQuoteDriver] 
@InsuranceQuoteDriverId INT = NULL,
@InsuranceQuoteId INT,
@Name VARCHAR(70),
@DOB DATETIME,
@GenderId VARCHAR(4),
@MaritalStatusId VARCHAR(4),
@DriverLicenseNumber VARCHAR(30) = NULL,
@DriverLicenseTypeId INT = NULL
AS
BEGIN


INSERT INTO [dbo].[InsuranceQuoteDriver]
           ([InsuranceQuoteId]
           ,[Name]
           ,[GenderId]
           ,[DriverLicenseNumber]
           ,[DriverLicenseTypeId]
           ,[Dob]
           ,[MaritalStatusId])
     VALUES
           (@InsuranceQuoteId
           ,@Name
           ,@GenderId
           ,@DriverLicenseNumber
           ,@DriverLicenseTypeId
           ,@DOB
           ,@MaritalStatusId)


		   SELECT @@IDENTITY


 

END
GO