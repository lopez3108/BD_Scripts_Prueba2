SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateInitialConfiguration] @UserPassId       INT  = NULL, 
                                                       @InitialFromDate  DATE = NULL, 
                                                       @InitialToDate    DATE = NULL, 
                                                       @InitialIndefined BIT NULL
AS
    BEGIN
        BEGIN
            UPDATE [dbo].UserPass
              SET 
                  InitialFromDate = @InitialFromDate, 
                  InitialToDate = @InitialToDate, 
                  InitialIndefined = @InitialIndefined
            WHERE UserPassId = @UserPassId;
        END;
    END;
GO