SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


-- 🔹 Procedimiento: sp_GetTelephones
-- 🔸 Recibe una lista de teléfonos (tipo dbo.TelephoneList)
-- 🔸 Busca coincidencias en múltiples tablas del sistema
CREATE PROCEDURE [dbo].[sp_GetTelephones]
    @TempTelephones dbo.TelephoneList READONLY
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #Temp (
        Telephone VARCHAR(10) NOT NULL,
        TypeTel INT NOT NULL
    );

    -- 1️⃣ Users
    INSERT INTO #Temp
    SELECT CAST(u.Telephone AS VARCHAR(10)), 1
    FROM Users u
    INNER JOIN @TempTelephones t ON t.Telephone = u.Telephone
    WHERE u.Telephone IS NOT NULL;

    -- 2️⃣ Tenants
    INSERT INTO #Temp
    SELECT CAST(te.Telephone AS VARCHAR(10)), 2
    FROM Tenants te
    INNER JOIN @TempTelephones t ON t.Telephone = te.Telephone
    WHERE te.Telephone IS NOT NULL;

    -- 3️⃣ TRP
    INSERT INTO #Temp
    SELECT CAST(trp.Telephone AS VARCHAR(10)), 3
    FROM TRP trp
    INNER JOIN @TempTelephones t ON t.Telephone = trp.Telephone
    WHERE trp.Telephone IS NOT NULL;

    -- 4️⃣ Titles
    INSERT INTO #Temp
    SELECT CAST(ti.Telephone AS VARCHAR(10)), 4
    FROM Titles ti
    INNER JOIN @TempTelephones t ON t.Telephone = ti.Telephone
    WHERE ti.Telephone IS NOT NULL;

    -- 5️⃣ Financing
    INSERT INTO #Temp
    SELECT CAST(f.Telephone AS VARCHAR(10)), 5
    FROM Financing f
    INNER JOIN @TempTelephones t ON t.Telephone = f.Telephone
    WHERE f.Telephone IS NOT NULL;

    -- 6️⃣ Cancellations
    INSERT INTO #Temp
    SELECT CAST(c.Telephone AS VARCHAR(10)), 6
    FROM Cancellations c
    INNER JOIN @TempTelephones t ON t.Telephone = c.Telephone
    WHERE c.Telephone IS NOT NULL;

    -- 7️⃣ Telephones
    INSERT INTO #Temp
    SELECT CAST(tel.Telephone AS VARCHAR(10)), 7
    FROM Telephones tel
    INNER JOIN @TempTelephones t ON t.Telephone = tel.Telephone
    WHERE tel.Telephone IS NOT NULL;

    -- 8️⃣ GeneralNotes
    INSERT INTO #Temp
    SELECT CAST(gn.ClientTelephone AS VARCHAR(10)), 8
    FROM GeneralNotes gn
    INNER JOIN @TempTelephones t ON t.Telephone = gn.ClientTelephone
    WHERE gn.ClientTelephone IS NOT NULL;

    -- 9️⃣ ProvisionalReceipts
    INSERT INTO #Temp
    SELECT CAST(pr.Telephone AS VARCHAR(10)), 9
    FROM ProvisionalReceipts pr
    INNER JOIN @TempTelephones t ON t.Telephone = pr.Telephone
    WHERE pr.Telephone IS NOT NULL;

    -- 🔟 InstructionChange
    INSERT INTO #Temp
    SELECT CAST(ic.Telephone AS VARCHAR(10)), 10
    FROM InstructionChange ic
    INNER JOIN @TempTelephones t ON t.Telephone = ic.Telephone
    WHERE ic.Telephone IS NOT NULL;

    -- 11️⃣ MoneyTransferModifications
    INSERT INTO #Temp
    SELECT CAST(mtm.Telephone AS VARCHAR(10)), 11
    FROM MoneyTransferModifications mtm
    INNER JOIN @TempTelephones t ON t.Telephone = mtm.Telephone
    WHERE mtm.Telephone IS NOT NULL;

    -- 12️⃣ SMSSent
    INSERT INTO #Temp
    SELECT CAST(sms.Telephone AS VARCHAR(10)), 12
    FROM SMSSent sms
    INNER JOIN @TempTelephones t ON t.Telephone = sms.Telephone
    WHERE sms.Telephone IS NOT NULL;

    -- 13️⃣ DiscountChecks
    INSERT INTO #Temp
    SELECT CAST(dc.ActualClientTelephone AS VARCHAR(10)), 13
    FROM DiscountChecks dc
    INNER JOIN @TempTelephones t ON t.Telephone = dc.ActualClientTelephone
    WHERE dc.ActualClientTelephone IS NOT NULL;

    -- 14️⃣ DiscountCityStickers
    INSERT INTO #Temp
    SELECT CAST(dcs.ActualClientTelephone AS VARCHAR(10)), 14
    FROM DiscountCityStickers dcs
    INNER JOIN @TempTelephones t ON t.Telephone = dcs.ActualClientTelephone
    WHERE dcs.ActualClientTelephone IS NOT NULL;

    -- 15️⃣ DiscountMoneyTransfers
    INSERT INTO #Temp
    SELECT CAST(dmt.ActualClientTelephone AS VARCHAR(10)), 15
    FROM DiscountMoneyTransfers dmt
    INNER JOIN @TempTelephones t ON t.Telephone = dmt.ActualClientTelephone
    WHERE dmt.ActualClientTelephone IS NOT NULL;

    -- 16️⃣ DiscountPhones
    INSERT INTO #Temp
    SELECT CAST(dp.ActualClientTelephone AS VARCHAR(10)), 16
    FROM DiscountPhones dp
    INNER JOIN @TempTelephones t ON t.Telephone = dp.ActualClientTelephone
    WHERE dp.ActualClientTelephone IS NOT NULL;

    -- 17️⃣ DiscountPlateStickers
    INSERT INTO #Temp
    SELECT CAST(dps.ActualClientTelephone AS VARCHAR(10)), 17
    FROM DiscountPlateStickers dps
    INNER JOIN @TempTelephones t ON t.Telephone = dps.ActualClientTelephone
    WHERE dps.ActualClientTelephone IS NOT NULL;

    -- 18️⃣ DiscountTitles
    INSERT INTO #Temp
    SELECT CAST(dt.ActualClientTelephone AS VARCHAR(10)), 18
    FROM DiscountTitles dt
    INNER JOIN @TempTelephones t ON t.Telephone = dt.ActualClientTelephone
    WHERE dt.ActualClientTelephone IS NOT NULL;

    -- 19️⃣ DocumentInformation
    INSERT INTO #Temp
    SELECT CAST(di.Telephone AS VARCHAR(10)), 19
    FROM DocumentInformation di
    INNER JOIN @TempTelephones t ON t.Telephone = di.Telephone
    WHERE di.Telephone IS NOT NULL;

    -- 20️⃣ ClientCompany
    INSERT INTO #Temp
    SELECT CAST(cc.CompanyTelephone AS VARCHAR(10)), 20
    FROM ClientCompany cc
    INNER JOIN @TempTelephones t ON t.Telephone = cc.CompanyTelephone
    WHERE cc.CompanyTelephone IS NOT NULL;

    -- 21️⃣ Insurance
    INSERT INTO #Temp
    SELECT CAST(i.Telephone AS VARCHAR(10)), 21
    FROM Insurance i
    INNER JOIN @TempTelephones t ON t.Telephone = i.Telephone
    WHERE i.Telephone IS NOT NULL;

    -- 22️⃣ InsurancePolicy
    INSERT INTO #Temp
    SELECT CAST(ip.ClientTelephone AS VARCHAR(10)), 22
    FROM InsurancePolicy ip
    INNER JOIN @TempTelephones t ON t.Telephone = ip.ClientTelephone
    WHERE ip.ClientTelephone IS NOT NULL;

    -- 23️⃣ InsuranceQuote
    INSERT INTO #Temp
    SELECT CAST(iq.ClientTelephone AS VARCHAR(10)), 23
    FROM InsuranceQuote iq
    INNER JOIN @TempTelephones t ON t.Telephone = iq.ClientTelephone
    WHERE iq.ClientTelephone IS NOT NULL;

    -- 24️⃣ InsuranceRegistration
    INSERT INTO #Temp
    SELECT CAST(ir.ClientTelephone AS VARCHAR(10)), 24
    FROM InsuranceRegistration ir
    INNER JOIN @TempTelephones t ON t.Telephone = ir.ClientTelephone
    WHERE ir.ClientTelephone IS NOT NULL;

    -- 25️⃣ Tickets
    INSERT INTO #Temp
    SELECT CAST(tk.ClientTelephone AS VARCHAR(10)), 25
    FROM Tickets tk
    INNER JOIN @TempTelephones t ON t.Telephone = tk.ClientTelephone
    WHERE tk.ClientTelephone IS NOT NULL;

    -- Resultado final sin duplicados
    SELECT DISTINCT Telephone
    FROM #Temp;

    DROP TABLE #Temp;
END;
GO