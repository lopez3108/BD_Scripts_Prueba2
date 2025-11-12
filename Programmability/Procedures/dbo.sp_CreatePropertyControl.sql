SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreatePropertyControl] @PropertyControlId  INT = NULL,
                                             @Name VARCHAR(40),
											                       @MonthNumberValid INT,
                                             @CheckProperty  BIT = NULL,
                                             @CheckApartment  BIT = NULL

AS
     BEGIN


	 IF(@PropertyControlId IS NULL)
	 BEGIN

	 IF(EXISTS(SELECT * FROM PropertyControls WHERE Name = @Name))
	 BEGIN

	 SELECT -1

	 END
	 ELSE
	 BEGIN


	 INSERT INTO [dbo].[PropertyControls]
           ([Name],
		   [MonthNumberValid],[CheckProperty],[CheckApartment])
     VALUES
           (@Name,
		   @MonthNumberValid,@CheckProperty,@CheckApartment)

		   declare @controlId int
		   set @controlId = (SELECT @@IDENTITY)

		   UPDATE [PropertyControls] SET Code = 'C' + CAST(@controlId as VARCHAR(5))
		   WHERE PropertyControlId = @controlId

		   SELECT @controlId

END
END
ELSE
BEGIN

	  UPDATE [dbo].[PropertyControls]
   SET [Name] = @Name,
        MonthNumberValid = @MonthNumberValid, 
        CheckProperty = @CheckProperty,
        CheckApartment = @CheckApartment
 WHERE PropertyControlId = @PropertyControlId

 SELECT @PropertyControlId


	 END
		   

     END

GO