SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreatePropertyControlRenews] 
(
@CurrentDate DATETIME
)
AS
     BEGIN

	 
						  INSERT INTO [dbo].[PropertyControlsXProperty]        
SELECT 
      [PropertyControlId]
      ,[PropertiesId]
      ,[ApartmentsId]
      ,@CurrentDate
      ,'RENEWAL'
      ,0
      ,@CurrentDate
      ,[CreatedBy]
      ,1
      ,NULL
      ,NULL
      ,NULL
  FROM [dbo].[PropertyControlsXProperty]
  WHERE 
  Completed = 1 AND
  CAST(ValidThrough as Date) = DATEADD(day, -1, CAST(@CurrentDate as DATE))


     END;
GO