SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-07-23 DJ/5969: Move-in fee incorrect, must be taken from RentPayments table
-- 2025-06-06 DJ/6572: Cambiar labels modulo propiedades
-- 2025-06-18 DJ/6589: Requerir ACH date para RENT PAYMENT y DEPOSIT MANAGEMENT
-- 2025-10-20 DJ/6775: Permitir pagos con créditos y débitos

CREATE PROCEDURE [dbo].[sp_GetRentPaymentsByContract] (@ContractId INT,
@Date DATETIME)
AS

BEGIN

  CREATE TABLE #PartCosts (
    RentPaymentId INT NOT NULL
   ,ContractId INT NOT NULL
   ,Usd DECIMAL(18, 2) NOT NULL
   ,CreationDate DATETIME NOT NULL
   ,Month VARCHAR(20) NOT NULL
   ,UserId INT NOT NULL
   ,CreatedBy VARCHAR(50)
   ,AgencyId INT  NULL
   ,Agency VARCHAR(50) NULL
   ,NoPaid BIT NOT NULL
   ,FeeDue DECIMAL(18, 2) NULL,
    CardPayment BIT  NULL,
    CardPaymentFee DECIMAL(18, 2) NULL,
    Cash DECIMAL(18, 2) NULL, 
   PaymentType VARCHAR(40),
   Type VARCHAR(40),
   BankAccount VARCHAR(40),
   UsdPayment DECIMAL(18,2),
   FeeDuePending DECIMAL(18,2),
   RentPending DECIMAL(18,2),
   InitialBalance DECIMAL(18,2),
   FinalBalance DECIMAL(18,2),
   MoveInFee DECIMAL(18,2) NULL,
   AchDate DATETIME NULL
  );

  

    INSERT INTO #PartCosts
      SELECT
        r.RentPaymentId
       ,r.ContractId
       ,r.Usd
       ,r.CreationDate
       ,''
       ,dbo.Users.UserId
       ,dbo.Users.Name AS CreatedBy
       ,r.AgencyId
       ,dbo.Agencies.Code + ' - ' + dbo.Agencies.Name AS Agency
       ,0
       ,ISNULL(r.FeeDue, 0) AS FeeDue,
        r.CardPayment,
        r.CardPaymentFee,
        r.Cash,
		CASE 
		WHEN r.Cash > 0 THEN
		'CASH' WHEN CardPayment = 1 THEN
		'CARD PAYMENT' ELSE
		'ACH' END as PaymentType,
    	CASE 
		WHEN r.IsCredit = 1 THEN
		'CREDIT'   ELSE
		'DEBIT' END as Type,
		ba.AccountNumber as BankAccount,
		r.UsdPayment,
		r.FeeDuePending,
		r.RentPending,
		r.InitialBalance,
		r.FinalBalance,
		ISNULL(r.MoveInFee, 0) as MoveInFee, --5969
		r.AchDate
      FROM dbo.RentPayments r
      LEFT JOIN dbo.Agencies
        ON r.AgencyId = dbo.Agencies.AgencyId
      INNER JOIN dbo.Users
        ON r.CreatedBy = dbo.Users.UserId
		LEFT JOIN dbo.BankAccounts ba ON ba.BankAccountId = r.BankAccountId 
		INNER JOIN dbo.Contract c ON r.ContractId = c.ContractId
      WHERE r.ContractId = @ContractId
      ORDER BY r.CreationDate


  SELECT
    *
  FROM #PartCosts
  ORDER BY CreationDate

  DROP TABLE #PartCosts



END



GO