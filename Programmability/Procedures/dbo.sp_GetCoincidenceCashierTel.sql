SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCoincidenceCashierTel]
(@Email          VARCHAR(50) = NULL, 
 @Telephone      VARCHAR(20) = NULL, 
 @SocialSecurity VARCHAR(9)  = NULL, 
 @UserId         INT         = NULL
)
AS
    BEGIN
        SELECT [Users].UserId
        FROM dbo.Users
        WHERE([User] = @Email
              OR @Email IS NULL)
             AND ((Telephone = @Telephone
                  OR @Telephone IS NULL) and SocialSecurity is not null )
             AND (SocialSecurity = @SocialSecurity
                  OR @SocialSecurity IS NULL)
             AND (dbo.Users.UserId != @UserId
                  OR @UserId IS NULL);
    END;

	--select * from Users where UserId = 1458
	--select * from Users where UserId = 38
GO