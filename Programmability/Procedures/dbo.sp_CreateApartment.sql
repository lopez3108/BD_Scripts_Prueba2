SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Returns apartments list
-- =============================================
-- =============================================
-- Author:      JF
-- Create date: 2/09/2024 10:50 a. m.
-- Database:    developing
-- Description: task 6037  Ampliar los caracteres del campo apartment number
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreateApartment] 
@ApartmentsId INT = NULL,
@PropertiesId INT,
@Number VARCHAR(10),
@Bathrooms INT,
@Bedrooms INT,
@Size DECIMAL(18,02) = NULL,
@Description VARCHAR(500) = NULL,
@CreationDate DATETIME,
@CreatedBy INT
AS
     BEGIN
         
		 IF (@ApartmentsId IS NULL)
		 BEGIN

		 IF(EXISTS(SELECT 1 FROM Apartments WHERE Number = @Number AND PropertiesId = @PropertiesId))
		 BEGIN

		 SELECT -1

		 END
		 ELSE
		 BEGIN

		INSERT INTO [dbo].[Apartments]
           ([PropertiesId]
           ,[Number]
           ,[Bathrooms]
           ,[Bedrooms]
           ,[Description]
           ,[Size]
           ,[CreatedBy]
           ,[CreationDate])
     VALUES
           (@PropertiesId
           ,@Number
           ,@Bathrooms
           ,@Bedrooms
           ,@Description
           ,@Size
           ,@CreatedBy
           ,@CreationDate)

		   DECLARE @apartmentId INT
		   SET @apartmentId = (SELECT @@IDENTITY)

		    INSERT INTO [dbo].[PropertyControlsXProperty]
                               SELECT pr.[PropertyControlId], 
                                      NULL, 
                                      @apartmentId, 
                                      @CreationDate, 
                                      NULL, 
                                      0, 
                                      @CreationDate, 
                                      @CreatedBy, 
                                      1, 
                                      NULL, 
                                      NULL, 
                                      NULL
                               FROM [dbo].[PropertyControls] pr
							   WHERE CAST(pr.CheckApartment as BIT) = CAST(1 as BIT) 
                        SELECT @apartmentId;

		   SELECT @@IDENTITY
		   END
		   END
		   ELSE
		   BEGIN

		   IF(EXISTS(SELECT 1 FROM Apartments WHERE 
		   PropertiesId = @PropertiesId AND
		   Number = @Number AND
		   ApartmentsId <> @ApartmentsId))
		   BEGIN

		   SELECT -2

		   END
       -- NO SE PUEDE EDITAR APARTAMENTOS CON  CONTRACTOS, SOLO SU DESCRIPCION 4857
      ELSE IF EXISTS(SELECT 
            ContractId
          FROM dbo.Contract c
           INNER JOIN Apartments a ON c.ApartmentId = a.ApartmentsId
          WHERE c.ApartmentId = @ApartmentsId
          AND c.Status = (SELECT
              ContractStatusId
            FROM ContractStatus
            WHERE Code = 'C01') AND (a.Number <> @Number OR a.Bathrooms <> @Bathrooms OR a.Bedrooms <> @Bedrooms OR a.Size <> @Size)   )
      BEGIN  

      SELECT -3
      END
      ELSE


		   BEGIN


		   UPDATE [dbo].[Apartments]
   SET [PropertiesId] = @PropertiesId
      ,[Number] = @Number
      ,[Bathrooms] = @Bathrooms
      ,[Bedrooms] = @Bedrooms
      ,[Description] = @Description
      ,[Size] = @Size
      ,[LastUpdatedBy] = @CreatedBy
      ,[LastUpdatedOn] = @CreationDate
 WHERE ApartmentsId = @ApartmentsId

		   SELECT @ApartmentsId

		   END

		   END

		 END




GO