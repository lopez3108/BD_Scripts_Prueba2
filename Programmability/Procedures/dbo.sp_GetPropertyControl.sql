SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetPropertyControl] 
AS
     BEGIN



SELECT [PropertyControlId]
      ,[Code]
      ,[Name]
	  ,[MonthNumberValid]
    ,[CheckProperty]
    ,[CheckApartment] 
  FROM [dbo].[PropertyControls]
  ORDER BY [Name]


     END;

GO