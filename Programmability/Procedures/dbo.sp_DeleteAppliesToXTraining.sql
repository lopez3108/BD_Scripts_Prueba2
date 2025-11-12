SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[sp_DeleteAppliesToXTraining]

@TrainingId INT
AS 

BEGIN

DELETE  [dbo].TrainingAppliesTo WHERE TrainingId = @TrainingId

SELECT @TrainingId

	END
GO