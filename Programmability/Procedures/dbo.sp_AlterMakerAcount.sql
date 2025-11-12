SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_AlterMakerAcount] @MakerId  INT = NULL,                                       
										     @Account  VARCHAR(30) = NULL,
											 @OldAccount  VARCHAR(30) = NULL,
                       	 @Routing  VARCHAR(30) = NULL
AS
    
        
            BEGIN
			--Actualizamos los checks
                UPDATE [dbo].[Checks]
                SET                   
			    Account =  @Account
                WHERE  Account = @OldAccount AND Routing = @Routing AND Maker = @MakerId
				
				--Actualizamos los checksEls
				UPDATE [dbo].[ChecksEls]
                SET                   
			    Account =  @Account
                WHERE  [dbo].[ChecksEls].Account = @OldAccount AND Routing = @Routing  AND MakerId = @MakerId

--Actualizamos los ruterned checks
				UPDATE [dbo].ReturnedCheck 
                SET                   
			    Account =  @Account
                WHERE  [dbo].ReturnedCheck.Account = @OldAccount	AND Routing = @Routing  AND MakerId = @MakerId
              
              
    END;

GO