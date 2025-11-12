SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		David Jaramillo
-- Description:	Selecciona cheques retornados
-- =============================================

-- =============================================
-- Author:      LUIS ayuda JF
-- Create date: 9/10/2024 9:57 a. m.
-- Database:    [dev17-09-2024]
-- Description: task 6092 Cambiar fecha filtros cheques retornados
-- =============================================


CREATE   PROCEDURE [dbo].[sp_GetReturnedChecks] @ReturnedCheckId INT         = NULL,
                                             @DateFrom        DATE        = NULL,
                                             @DateTo          DATE        = NULL,
                                             @AgencyId        INT         = NULL,
                                             @ReturnStatusId  INT         = NULL,
                                             @ProviderId      INT         = NULL,
                                             @ClientId        INT         = 0,
                                             @ClientName     VARCHAR(80) = NULL,
                                             @ReasonId        INT         = 0,
                                             @MakerId         INT         = 0,
                                             @CheckNumber     VARCHAR(15) = NULL,
                                             @ClientBlocked   BIT         = NULL,
                                             @MakerBlocked    BIT         = NULL,
                                             @AccountBlocked  BIT         = NULL,
                                             @Account         VARCHAR(50) = NULL,
											 @CreatedBy       INT         = NULL
AS


     BEGIN
	
         SELECT dbo.ReturnedCheck.ReturnedCheckId,
                dbo.ReturnedCheck.CheckDate,
                FORMAT(ReturnedCheck.CheckDate, 'MM-dd-yyyy', 'en-US')	CheckDateFormat ,
                dbo.ReturnedCheck.CheckNumber,
                dbo.ReturnedCheck.USD,
                dbo.ReturnedCheck.Fee,
                dbo.ReturnedCheck.ProviderFee,
                --dbo.ReturnedCheck.USD + dbo.ReturnedCheck.Fee AS TotalReturn,
				[dbo].[fn_CalculateTotalReturned](dbo.ReturnedCheck.ReturnedCheckId) AS TotalReturn,
                [dbo].[fn_CalculateDueReturned](dbo.ReturnedCheck.ReturnedCheckId) AS Due,
                [dbo].[fn_CalculatePaidReturned](dbo.ReturnedCheck.ReturnedCheckId) AS Paid,
                dbo.ReturnedCheck.CreationDate,
                FORMAT(ReturnedCheck.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')	CreationDateFormat ,
                dbo.ReturnedCheck.CreatedBy,
                dbo.ReturnedCheck.LastModifiedDate,
                dbo.ReturnedCheck.LastModifiedBy,
                dbo.ReturnedCheck.ReturnDate,
                FORMAT(ReturnedCheck.ReturnDate, 'MM-dd-yyyy', 'en-US')	ReturnDateFormat ,
                dbo.Agencies.AgencyId,
                Agencies.Code+' - '+Agencies.Name AS AgencyName,
                Agencies_1.AgencyId AS AgencyReturnId,
                Agencies_1.Code+' - '+Agencies_1.Name AS AgencyReturnName,
                dbo.Providers.ProviderId,
                dbo.Providers.Name AS ProviderName,
                dbo.Makers.MakerId,
                dbo.Makers.Name AS MakerName,
                dbo.Makers.FileNumber AS FileNumber,
                dbo.ReturnReason.ReturnReasonId,
                dbo.ReturnReason.Description AS ReturnReason,
                dbo.ReturnReason.Description AS ReturnReasonSaved,
                --dbo.Bank.BankId,
                R.BankName,
                dbo.ReturnStatus.ReturnStatusId,
                dbo.ReturnStatus.Description AS ReturnStatusName,
                dbo.ReturnStatus.Code,
                UPPER(dbo.Users.Name) AS CreatedByName,
                Users_1.Name AS LastModifiedByName,
                Users_2.Name AS ClientName,
                Users_2.Address AS ClientAddress,
                Users_2.Telephone AS Telephone,
                dbo.AddressXMaker.Address AS MakerAddress,
                dbo.AddressXMaker.ZipCode AS MakerZipCode,
                dbo.AddressXMaker.State AS MakerState,
                dbo.AddressXMaker.City AS MakerCity,
                r.BankName,
                --r.BankAddress AS BankAddress,
			                 --r.BankZipCode ZipCode,
                --r.BankState State,
                --r.BankCity City,
                r.RoutingId,
                dbo.AddressXClient.Address AS AddressXClient,
                dbo.AddressXClient.ZipCode AS ClientZipCode,
                dbo.AddressXClient.State AS ClientState,
                dbo.AddressXClient.City AS ClientCity,
                dbo.ReturnedCheck.ClientId,
                (dbo.AddressXClient.Address+' '+dbo.AddressXClient.City+', '+dbo.AddressXClient.State+' '+dbo.AddressXClient.ZipCode) AS AllAddressClient,
                (ar.Address+' '+ ar.City+', '+ ar.State+' '+ ar.ZipCode) AS AllAddressBank,
                (dbo.AddressXMaker.Address+' '+dbo.AddressXMaker.City+', '+dbo.AddressXMaker.State+' '+dbo.AddressXMaker.ZipCode) AS AllAddressMaker,
                ZipCodes.City AS AgencyCity,
                ZipCodes.StateAbre AS AgencyStateAbreviation,
                ZipCodes.ZipCode AS AgencyZipCode,
                Agencies_1.Telephone AS AgencyPhone,
                Agencies_1.Address AS AgencyAddress,
                Users_lost.Name AS LostBy,
                dbo.ReturnedCheck.LostDate,
                dbo.Cashiers.CashierId CashierCreatedId,
                dbo.ReturnedCheck.Account,
                dbo.ReturnedCheck.Routing,
                dbo.ReturnedCheck.ClientBlocked,
                dbo.ReturnedCheck.MakerBlocked,
                dbo.ReturnedCheck.AccountBlocked,
dbo.ReturnedCheck.LawyerFee,
dbo.ReturnedCheck.CourtFee,
				dbo.ReturnedCheck.AdminAgencyId,
                CASE
                    WHEN EXISTS
         (
             SELECT Usd
             FROM [dbo].[LawyerPayments]
             WHERE [dbo].[LawyerPayments].ReturnedCheckId = dbo.ReturnedCheck.ReturnedCheckId
         )
                    THEN
         (
             SELECT SUM(Usd)
             FROM [dbo].[LawyerPayments]
             WHERE [dbo].[LawyerPayments].ReturnedCheckId = dbo.ReturnedCheck.ReturnedCheckId
         )
                    ELSE 0.00
                END AS lawyerusd,
                CASE
                    WHEN(EXISTS
                        (
                            SELECT *
                            FROM LawyerPayments l
                            WHERE l.ReturnedCheckId = dbo.ReturnedCheck.ReturnedCheckId
                        ))
                    THEN CAST(1 AS BIT)
                    ELSE CAST(0 AS BIT)
                END AS LawyerFee,
                CASE
                    WHEN EXISTS
         (
             SELECT Usd
             FROM [dbo].[CourtPayment]
             WHERE [dbo].[CourtPayment].ReturnedCheckId = dbo.ReturnedCheck.ReturnedCheckId
         )
                    THEN
         (
             SELECT SUM(Usd)
             FROM [dbo].[CourtPayment]
             WHERE [dbo].[CourtPayment].ReturnedCheckId = dbo.ReturnedCheck.ReturnedCheckId
         )
                    ELSE 0.00
                END AS courtusd,
                CASE
                    WHEN(EXISTS
                        (
                            SELECT *
                            FROM CourtPayment c
                            WHERE c.ReturnedCheckId = dbo.ReturnedCheck.ReturnedCheckId
                        ))
                    THEN CAST(1 AS BIT)
                    ELSE CAST(0 AS BIT)
                END AS CourtFee,
                dbo.Providers.Name+ISNULL(
                                         (
                                             SELECT TOP 1 CASE
                                                              WHEN dbo.ProviderTypes.Code = 'C02'
                                                              THEN ' - '+ISNULL(mn.Number, 'NOT REGISTERED')
                                                              ELSE ''
                                                          END
                                             FROM dbo.MoneyTransferxAgencyNumbers mn
                                             WHERE mn.ProviderId = dbo.ReturnedCheck.ProviderId
                                                   AND mn.AGencyId = dbo.ReturnedCheck.ReturnedAgencyId
                                         ), '') AS ProviderNameComplete,
                CASE
                    WHEN dbo.ReturnStatus.Code = 'C02'
                    THEN dbo.fn_GetReturnCheckPaidDate(dbo.ReturnedCheck.ReturnedCheckId)
                    ELSE NULL
                END AS PaidDate,
                       CASE
                    WHEN ReturnedCheck.ReturnedCheckId IS NOT NULL
                    THEN CASE
                             WHEN ReturnedCheck.ClientBlocked = 1
                                  AND ReturnedCheck.MakerBlocked = 1
                                  AND ReturnedCheck.AccountBlocked = 1
                             THEN 'CLIENT,MAKER,ACCOUNT'
                             WHEN ReturnedCheck.ClientBlocked = 1
                                  AND ReturnedCheck.MakerBlocked = 1
                             THEN 'CLIENT,MAKER'
                             WHEN ReturnedCheck.ClientBlocked = 1
                                  AND ReturnedCheck.AccountBlocked = 1
                             THEN 'CLIENT,ACCOUNT'
                             WHEN ReturnedCheck.MakerBlocked = 1
                                  AND ReturnedCheck.AccountBlocked = 1
                             THEN 'MAKER,ACCOUNT'
                             WHEN ReturnedCheck.ClientBlocked = 1
                             THEN 'CLIENT'
                             WHEN ReturnedCheck.MakerBlocked = 1
                             THEN 'MAKER'
                             WHEN ReturnedCheck.AccountBlocked = 1
                             THEN 'ACCOUNT'
                         END
                END AS BlockType
         FROM dbo.Makers
              INNER JOIN dbo.Providers
              INNER JOIN dbo.Agencies AS Agencies_1
              INNER JOIN dbo.ReturnedCheck
              LEFT JOIN Routings r ON dbo.ReturnedCheck.Routing = r.Number
              LEFT JOIN dbo.Agencies ON dbo.ReturnedCheck.BelongAgencyId = dbo.Agencies.AgencyId ON Agencies_1.AgencyId = dbo.ReturnedCheck.ReturnedAgencyId ON dbo.Providers.ProviderId = dbo.ReturnedCheck.ProviderId ON dbo.Makers.MakerId = dbo.ReturnedCheck.MakerId
              LEFT JOIN dbo.ReturnReason ON dbo.ReturnedCheck.ReturnReasonId = dbo.ReturnReason.ReturnReasonId
              --INNER JOIN dbo.Bank ON dbo.ReturnedCheck.BankId = dbo.Bank.BankId
              LEFT JOIN dbo.ReturnStatus ON dbo.ReturnedCheck.StatusId = dbo.ReturnStatus.ReturnStatusId
              LEFT JOIN dbo.Users ON dbo.ReturnedCheck.CreatedBy = dbo.Users.UserId
              LEFT JOIN dbo.Cashiers ON dbo.Cashiers.UserId = dbo.Users.UserId
              LEFT JOIN dbo.Users AS Users_1 ON dbo.ReturnedCheck.LastModifiedBy = Users_1.UserId
              LEFT OUTER JOIN dbo.Users AS Users_lost ON dbo.ReturnedCheck.LostBy = Users_lost.UserId
              LEFT JOIN dbo.Clientes ON dbo.ReturnedCheck.ClientId = dbo.Clientes.ClienteId           
              LEFT JOIN dbo.Users AS Users_2 ON dbo.Clientes.UsuarioId = Users_2.UserId
              LEFT JOIN dbo.AddressXMaker ON dbo.ReturnedCheck.AddressXMakerId = dbo.AddressXMaker.AddressXMakerId
              --INNER JOIN dbo.AddressXBank ON dbo.ReturnedCheck.AddressXBankId = dbo.AddressXBank.AddressXBankId
              LEFT JOIN dbo.AddressXClient ON dbo.ReturnedCheck.AddressXClientId = dbo.AddressXClient.AddressXClientId
              LEFT JOIN ZipCodes ON ZipCodes.ZipCode = Agencies_1.ZipCode
              LEFT JOIN dbo.ProviderTypes ON dbo.ProviderTypes.ProviderTypeId = dbo.Providers.ProviderTypeId
        LEFT JOIN AddressXRouting ar ON ar.RoutingId = r.RoutingId
		
		WHERE 
		
		 ( (dbo.ReturnedCheck.ClientBlocked = @ClientBlocked
               OR @ClientBlocked IS NULL)
              and (dbo.ReturnedCheck.MakerBlocked = @MakerBlocked
                  OR @MakerBlocked IS NULL)
              and (dbo.ReturnedCheck.AccountBlocked = @AccountBlocked
                  OR @AccountBlocked IS NULL)
				  )

				--CAST(dbo.ReturnedCheck.CreationDate AS DATE) >= CAST(@DateFrom AS DATE)
				--AND CAST(dbo.ReturnedCheck.CreationDate AS DATE) <= CAST(@DateTo AS DATE)
        AND ( ( (CAST(dbo.ReturnedCheck.CreationDate AS DATE) >= CASE
                                                             WHEN @DateFrom IS NULL
                                                             THEN CAST(dbo.ReturnedCheck.CreationDate AS DATE)
                                                             ELSE CAST(@DateFrom AS DATE)
                                                         END
         AND CAST(dbo.ReturnedCheck.CreationDate AS DATE) <= CASE
                                                                 WHEN @DateTo IS NULL
                                                                 THEN CAST(dbo.ReturnedCheck.CreationDate AS DATE)
                                                                 ELSE CAST(@DateTo AS DATE)
                                                             END) AND @ReturnStatusId != 3 OR @ReturnStatusId IS NULL) 
                                                             
                                                             OR

                                                             (CAST(dbo.ReturnedCheck.LostDate AS DATE) >= CASE
                                                             WHEN @DateFrom IS NULL
                                                             THEN CAST(dbo.ReturnedCheck.LostDate AS DATE)
                                                             ELSE CAST(@DateFrom AS DATE)
                                                         END
         AND CAST(dbo.ReturnedCheck.LostDate AS DATE) <= CASE
                                                                 WHEN @DateTo IS NULL
                                                                 THEN CAST(dbo.ReturnedCheck.LostDate AS DATE)
                                                                 ELSE CAST(@DateTo AS DATE)
                                                             END))
        
		AND (ReturnedCheck.ReturnedAgencyId = @AgencyId OR @AgencyId IS NULL)
		 AND (dbo.ReturnStatus.ReturnStatusId = @ReturnStatusId OR @ReturnStatusId IS NULL)
        
         AND dbo.ReturnedCheck.ProviderId = CASE
                                                WHEN @ProviderId IS NULL
                                                THEN dbo.ReturnedCheck.ProviderId
                                                ELSE @ProviderId
                                            END
         AND dbo.ReturnedCheck.ReturnedCheckId = CASE
                                                     WHEN @ReturnedCheckId IS NULL
                                                     THEN dbo.ReturnedCheck.ReturnedCheckId
                                                     ELSE @ReturnedCheckId
                                                 END                                               

         AND dbo.ReturnedCheck.ClientId = CASE
                                              WHEN @ClientId IS NULL
                                                   OR @ClientId = 0
                                              THEN dbo.ReturnedCheck.ClientId
                                              ELSE @ClientId
                                          END
         AND dbo.ReturnedCheck.ReturnReasonId = CASE
                                                    WHEN @ReasonId IS NULL
                                                         OR @ReasonId = 0
                                                    THEN dbo.ReturnedCheck.ReturnReasonId
                                                    ELSE @ReasonId
                                                END
         AND (dbo.ReturnedCheck.MakerId = @MakerId
              OR @MakerId IS NULL
              OR @MakerId = 0)
       
         AND (dbo.ReturnedCheck.CheckNumber LIKE '%'+@CheckNumber+'%'
              OR @CheckNumber IS NULL)

          AND (Users_2.Name  LIKE '%'+@ClientName+'%'
              OR @ClientName IS NULL)
	          

         AND (dbo.ReturnedCheck.Account = @Account
              OR @Account IS NULL)
			        AND (dbo.ReturnedCheck.CreatedBy = @CreatedBy
              OR @CreatedBy IS NULL)
			  
         ORDER BY dbo.ReturnedCheck.CreationDate ASC;
     END;
GO