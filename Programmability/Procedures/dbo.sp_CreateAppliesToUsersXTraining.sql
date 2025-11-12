SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateAppliesToUsersXTraining]

@TrainingId INT,
@UserId INT
AS 

BEGIN

INSERT INTO  [dbo].TrainingAppliesTo
           (TrainingId
           ,UserId)
     VALUES
           (@TrainingId
           ,@UserId)

		   SELECT @@IDENTITY


	END
GO