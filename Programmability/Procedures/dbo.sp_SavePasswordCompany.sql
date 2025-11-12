SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Upadte by Juan Felipe--Date    09-mayo-2023--Task 5060 
--Upadte by JT --Date    09-ENERO-2025--Task 6290 Aumentar tamaño token number para My users admin 

CREATE PROCEDURE [dbo].[sp_SavePasswordCompany]
(@UserPassId       INT          = NULL, 
 @Company          VARCHAR(100) = NULL, 
 @Pass             VARCHAR(20), 
 @User             VARCHAR(50), 
 @Url              VARCHAR(400) = NULL, 
 @UserId           INT, 
 @AgencyId         INT          = NULL, 
 @UpdatedBy        INT, 
 @UpdatedOn        DATETIME, 
 @InitialFromDate  DATE = null, 
 @InitialToDate    DATE = null, 
 @InitialIndefined BIT null, 
 @Saved            INT OUTPUT,
 @AgencyNumber     VARCHAR(10) = NULL, 
 @TokenNumber      VARCHAR(30) = NULL 
)
AS
    BEGIN
        SET @Saved = 0;
        IF(@UserPassId IS NULL)
            BEGIN
                IF NOT EXISTS
                (
                    SELECT 1
                    FROM UserPass
                    WHERE Company = @Company
                          AND UserId = @UserId
                          AND AgencyId = @AgencyId
                )
                    BEGIN
                        INSERT INTO [dbo].UserPass
                        (Company, 
                         Pass, 
                         UserId, 
                         AgencyId, 
                         [User], 
                         Url, 
                         UpdatedBy, 
                         UpdatedOn,
						             InitialFromDate,
						             InitialToDate,
						             InitialIndefined,
                         AgencyNumber,
                         TokenNumber 
                        )
                        VALUES
                        (UPPER(@Company), 
                         @Pass, 
                         @UserId, 
                         @AgencyId, 
                         @User, 
                         @Url, 
                         @UpdatedBy, 
                         @UpdatedOn,
						             @InitialFromDate,
						             @InitialToDate,
						             @InitialIndefined,
                         @AgencyNumber,
                         @TokenNumber
                        );
                        SET @Saved = @@IDENTITY;
                    END;
            END;
            ELSE
            BEGIN
                UPDATE [dbo].UserPass
                  SET 
                      Pass = @Pass, 
                      [User] = @User, 
                      Url = @Url, 
                      UpdatedBy = @UpdatedBy, 
                      UpdatedOn = @UpdatedOn,
                      AgencyNumber = @AgencyNumber,
                      TokenNumber = @TokenNumber
                WHERE UserPassId = @UserPassId;
                SET @Saved = @UserPassId;
            END;
    END;
GO