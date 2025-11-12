SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetClientesByCriteria]
(@Name      VARCHAR(200) = NULL, 
 @MakerId   INT          = NULL, 
 @Account   VARCHAR(50)  = NULL, 
 @Telephone VARCHAR(50)  = NULL
)
AS
    BEGIN
        IF(@Telephone IS NOT NULL)
            BEGIN
                DECLARE @tel VARCHAR(50);
                SET @tel = REPLACE(@Telephone, ' ', '');
        END;
        IF(@MakerId IS NOT NULL
           OR @Account IS NOT NULL)
            BEGIN
                SELECT DISTINCT 
                       Clientes.ClienteId, 
                       Clientes.Doc1Expire, 
                       Clientes.Doc2Front, 
                       Clientes.Doc2Back, 
                       Clientes.Doc2Type, 
                       Clientes.Doc2Number, 
                       Clientes.Doc2Country, 
                       Clientes.Doc2State, 
                       Clientes.Doc2Expire, 
                       Users.Name, 
                       Users.Telephone, 
                       Users.Telephone2, 
                       Users.ZipCode, 
                       Users.Address,
                    
				       UPPER( Users.Address +' '+ ZipCodes.City +', '+  ZipCodes.StateAbre +' '+ Users.ZipCode ) AS AddressWithZipCode, 					   
                 	   Users.Lenguage, 
                       Users.[User], 
                      UPPER( Countries_1.Name) AS Doc2CountryName, 
                      UPPER( Countries.Name) AS Doc1CountryName, 
                      UPPER( ZipCodes.City) AS City1, 
                       UPPER (ZipCodes.State) AS State1, 
                       UPPER (ZipCodes.City) City , 
                       UPPER (ZipCodes.State) State, 
                       UPPER (ZipCodes.County) County,
                       CheckClientes.Maker, 
--                       CheckClientes.Account,
					   Clientes.CreationDate,
					   FORMAT(Clientes.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
				Clientes.CreatedBy,
				u1.Name as CreatedByName,
        cast(Clientes.IsClientVIP AS bit) AS IsClientVIP,
		    CASE WHEN Clientes.IsClientVIP = 1 
			THEN 'YES'
			ELSE 'NO'
			END
			AS IsClientVIPText
                  FROM Users 
				  INNER JOIN dbo.Clientes ON Users.UserId = Clientes.UsuarioId
				  INNER JOIN dbo.Checks CheckClientes ON CheckClientes.ClientId = dbo.Clientes.ClienteId
				  LEFT JOIN ZipCodes ON ZipCodes.ZipCode = Users.ZipCode
				  LEFT JOIN Countries ON Clientes.Doc1Country = Countries.CountryId
				  LEFT JOIN Users as u1 ON Clientes.CreatedBy = u1.UserId				  
				  LEFT JOIN Countries AS Countries_1 ON Clientes.Doc2Country = Countries_1.CountryId

	
                WHERE  
				(Users.Name LIKE '%' + @Name + '%' OR  @Name IS NULL)
						AND(CheckClientes.Maker = @MakerId OR @MakerId IS NULL)
					  
					  AND (CheckClientes.Account LIKE '%' + @Account + '%' OR  @Account IS NULL)
                      AND REPLACE(Users.Telephone, ' ', '') LIKE CASE
                                                                     WHEN @Telephone IS NULL
                                                                     THEN REPLACE(Users.Telephone, ' ', '')
                                                                     ELSE '%' + @tel + '%'
                                                                 END
                ORDER BY Users.Name ASC;
        END;
            ELSE
            BEGIN
                SELECT DISTINCT 
                       Clientes.ClienteId, 
                       Clientes.Doc1Expire, 
                       Clientes.Doc2Front, 
                       Clientes.Doc2Back, 
                       Clientes.Doc2Type, 
                       Clientes.Doc2Number, 
                       Clientes.Doc2Country, 
                       Clientes.Doc2State, 
                       Clientes.Doc2Expire, 
                       Users.Name, 
                       Users.Telephone Telephone, 
                       Users.Telephone2, 
                       Users.ZipCode, 
                       Users.Address,
                       UPPER (ZipCodes.City) AS City1 ,
                       UPPER (ZipCodes.State) AS State1,
					   UPPER( Users.Address +' '+ ZipCodes.City +', '+  ZipCodes.StateAbre +' '+ Users.ZipCode ) AS AddressWithZipCode, 					   
                       Users.Lenguage, 
                       Users.[User], 
                       Countries.Name AS Doc1CountryName, 
                      -- dbo.fn_GetClientBounced(Clientes.ClienteId) AS IsBounced, 
                       UPPER (ZipCodes.City) City , 
                       UPPER (ZipCodes.State) State, 
                       UPPER (ZipCodes.County) County,
					     Clientes.CreationDate,
						 FORMAT(Clientes.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
				Clientes.CreatedBy,
				u1.Name as CreatedByName,
         cast(Clientes.IsClientVIP AS bit) AS IsClientVIP,
		     CASE WHEN Clientes.IsClientVIP = 1 
			THEN 'YES'
			ELSE 'NO'
			END
			AS IsClientVIPText
                     FROM ZipCodes
                     RIGHT JOIN Users ON ZipCodes.ZipCode = Users.ZipCode
                     RIGHT OUTER JOIN dbo.Clientes ON Users.UserId = Clientes.UsuarioId
                     LEFT OUTER JOIN Countries ON Clientes.Doc1Country = Countries.CountryId
					 LEFT JOIN Users as u1 ON Clientes.CreatedBy = u1.UserId
                WHERE Users.Name LIKE '%' + @Name + '%' OR  @Name IS NULL
                
--                Users.Name LIKE CASE
--                                          WHEN @Name IS NULL
--                                          THEN Users.Name
--                                          ELSE '%' + @Name + '%'
--                                      END
                      AND REPLACE(Users.Telephone, ' ', '') LIKE CASE
                                                                     WHEN @Telephone IS NULL
                                                                     THEN REPLACE(Users.Telephone, ' ', '')
                                                                     ELSE '%' + @tel + '%'
                                                                 END
                ORDER BY Users.Name ASC;
        END;
    END;


GO