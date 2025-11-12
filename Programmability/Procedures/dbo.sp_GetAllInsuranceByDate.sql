SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created by JT/22-09-2024 Task 6039 new section insurance in report daily
CREATE PROCEDURE [dbo].[sp_GetAllInsuranceByDate] @From DATE,
@To DATE,
@AgencyId INT,
@CreatedBy INT
AS
BEGIN
  -- Temp tbl to save the results from another SP
  CREATE TABLE #InsuranceResume (
    Date DATE
   ,
    --        USD DECIMAL(18, 2),
    NewPolicy DECIMAL(18, 2)
   ,MonthlyPayment DECIMAL(18, 2)
   ,RegistratioRelease DECIMAL(18, 2)
   ,Adjustment DECIMAL(18, 2)
   ,Total DECIMAL(18, 2)
  )

  -- Excecute the another SP and save the result in the temp tbl
  INSERT INTO #InsuranceResume (Date,NewPolicy, MonthlyPayment, RegistratioRelease, Adjustment, Total)
  EXEC dbo.sp_GetInsuranceResumeDailyCashier @CreatedBy
                                            ,@From
                                            ,@To
                                            ,@AgencyId


  
  SELECT
    Date
   ,NewPolicy AS USD
   ,'NEW POLICYS' AS Name
  FROM #InsuranceResume
  UNION ALL
  SELECT
     Date
   ,MonthlyPayment AS USD
   ,'MONTHLY PAYMENTS' AS Name
  FROM #InsuranceResume
  UNION ALL
  SELECT
    Date
   ,RegistratioRelease AS USD
   ,'REGISTRATION RELEASE (S.O.S)' AS Name
  FROM #InsuranceResume

  UNION ALL
  SELECT
    Date
   ,Adjustment AS USD
   ,'ADJUSTMENTS' AS Name
  FROM #InsuranceResume

  -- Clean tmp tbl
  DROP TABLE #InsuranceResume
END;
GO