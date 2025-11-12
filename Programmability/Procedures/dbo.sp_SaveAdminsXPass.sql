SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveAdminsXPass] @UserXPassId INT  = NULL, 
                                           @UserPassId  INT  = NULL, 
                                           @UserId      INT, 
                                           @FromDate    DATE = NULL, 
                                           @ToDate      DATE = NULL, 
                                           @Indefined   BIT  = NULL, 
                                           @IsUpdatedInitial   BIT  = NULL
AS
    BEGIN
        IF(@UserXPassId IS NULL)
            BEGIN
                INSERT INTO [dbo].AdminsXPass
                (UserPassId, 
                 UserId, 
                 FromDate, 
                 ToDate, 
                 Indefined
                )
                VALUES
                (@UserPassId, 
                 @UserId, 
                 @FromDate, 
                 @ToDate, 
                 @Indefined
                );
            END;
            ELSE
            BEGIN
                UPDATE [dbo].AdminsXPass
                  SET 
                      UserId = @UserId, 
                      FromDate = @FromDate, 
                      ToDate = @ToDate, 
                      Indefined = @Indefined
                WHERE UserXPassId = @UserXPassId;
                IF(@IsUpdatedInitial = 1) 
                --para actualizar la configuracion inicial
                    BEGIN
                        UPDATE [dbo].UserPass
                          SET 
                              InitialFromDate = @FromDate, 
                              InitialToDate = @ToDate, 
                              InitialIndefined = @Indefined
                        WHERE UserPassId = @UserPassId;
                    END;
            END;
    END;
GO