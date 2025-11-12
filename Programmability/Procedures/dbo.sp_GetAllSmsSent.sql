SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllSmsSent]
(@FromDate      DATETIME    = NULL, 
 @EndingDate    DATETIME    = NULL, 
 @SMSCategoryId INT         = NULL, 
 @Telephone     VARCHAR(14) = NULL, 
 @Section       BIT
)
AS
    BEGIN
        SELECT sms.SMSSentId, 
               sms.SMSCategoryId, 
               sms.Message, 
               sms.CreatedBy, 
			   FORMAT(sms.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
               sms.CreationDate, 
               sms.AgencyId, 
               sms.Sent, 
               a.code + ' - ' + a.Name AgencyName, 
               c.Description CategoryName, 
               u.Name CreatedByName, 
               sms.Telephone,
			   p.Name as PropertyName
        FROM SMSSent sms
             INNER JOIN SMSCategories c ON sms.SMSCategoryId = c.SMSCategoryId
             LEFT JOIN Agencies a ON a.AgencyId = sms.AgencyId
			  LEFT JOIN Properties p ON sms.PropertyId = p.PropertiesId
             INNER JOIN Users u ON u.UserId = sms.CreatedBy
        WHERE((@Section = 1
               AND (@SMSCategoryId IS NULL
                    AND c.Code IN('C18', 'C04', 'C07', 'C09', 'C21', 'C23', 'C48'))
             OR (@SMSCategoryId IS NOT NULL
                 AND sms.SMSCategoryId = @SMSCategoryId))
        OR (@Section = 0
            AND (@SMSCategoryId IS NULL
                 AND c.Code NOT IN('C18', 'C04', 'C07', 'C09', 'C21', 'C23', 'C48'))
             OR (@SMSCategoryId IS NOT NULL
                 AND sms.SMSCategoryId = @SMSCategoryId)))

        --(sms.SMSCategoryId = @SMSCategoryId
        --                   OR @SMSCategoryId IS NULL) OR c.Code IN('C18', 'C04', 'C07', 'C09', 'C21', 'C23')
        AND ((CAST(sms.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
              OR @FromDate IS NULL))
        AND ((CAST(sms.CreationDate AS DATE) <= CAST(@EndingDate AS DATE)
              OR @EndingDate IS NULL))
        AND (@Telephone = sms.Telephone
             OR @Telephone IS NULL)
        ORDER BY sms.CreationDate DESC;
    END;
GO