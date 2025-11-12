SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCreateRouting] @RoutingId   INT          = NULL,
                                             @Number      VARCHAR(16),
                                             @BankName    VARCHAR(60),
                                             @BankPhone   VARCHAR(15)  = NULL,
                                             @Address VARCHAR(200) = NULL,
                                             @City    VARCHAR(30)  = NULL,
                                             @ZipCode VARCHAR(7)   = NULL,
											 @State   VARCHAR(15)   = NULL,
											 @County   VARCHAR(15)   = NULL
AS
     BEGIN
    
-- EDITING
         IF(@RoutingId IS NOT NULL)
             BEGIN
                 DECLARE @numberOriginal VARCHAR(16);
                 SET @numberOriginal =
                 (
                     SELECT TOP 1 Number
                     FROM Routings
                     WHERE RoutingId = @RoutingId
                 );

-- Checks if the routing number has been modified and there ara another differenting routing with the same number
                 IF(EXISTS
                   (
                       SELECT *
                       FROM Routings
                       WHERE Number = @Number
                             AND RoutingId <> @RoutingId
                   ))
                     BEGIN
                         SELECT-1;
                 END
-- Checks if changing the number, if there are checks that contains the old number;
                     ELSE
                 IF((@numberOriginal <> @Number)
                    AND EXISTS
                   (
                       SELECT *
                       FROM Checks
                       WHERE Routing = @numberOriginal
                   ))
                     BEGIN
                         SELECT-2;
                 END;
                     ELSE
                     BEGIN
                         UPDATE [dbo].[Routings]
                           SET
                               [Number] = @Number,
                               [BankName] = @BankName,
                               [BankPhone] = @BankPhone
                         WHERE RoutingId = @RoutingId;

						 DELETE AddressXRouting
						 WHERE RoutingId = @RoutingId

						 IF(@Address IS NOT NULL)
						 BEGIN

						 INSERT INTO AddressXRouting (
						 RoutingId,
						 Address,
						 ZipCode,
						 State,
						 City,
						 COunty)
						 VALUES(
						 @RoutingId,
						 @Address,
						 @ZipCode,
						 @State,
						 @City,
						 @County)



						 END





                         SELECT @RoutingId;
                 END;
         END
-- ADDING;
             ELSE
             BEGIN

-- Checks if the routing number has been modified and there ara another differenting routing with the same number
                 IF(EXISTS
                   (
                       SELECT *
                       FROM Routings
                       WHERE Number = @Number
                   ))
                     BEGIN
                         SELECT-1;
                 END;
                     ELSE
                     BEGIN
                         INSERT INTO [dbo].[Routings]
                         ([Number],
                          [BankName],
                          [BankPhone]
                         )
                         VALUES
                         (@Number,
                          @BankName,
                          @BankPhone
                         );
                         DECLARE @id INT 
						 SET @id = @@IDENTITY;

						 IF(@Address IS NOT NULL)
						 BEGIN

						 INSERT INTO AddressXRouting (
						 RoutingId,
						 Address,
						 ZipCode,
						 State,
						 City,
						 COunty)
						 VALUES(
						 @id,
						 @Address,
						 @ZipCode,
						 @State,
						 @City,
						 @County)

						 END

						 SELECT @id

                 END;
         END;
     END;
GO