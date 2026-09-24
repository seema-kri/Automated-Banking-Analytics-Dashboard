USE Banking_Domain;

-- 1. Which customer segments generate the most transaction value?
SELECT
    c.CustomerSegment,
    COUNT(DISTINCT c.CustomerKey) AS CustomerCount,
    SUM(f.TransactionAmount)      AS TotalTransactionValue,
    AVG(f.TransactionAmount)      AS AvgTransactionValue
FROM dbo.FactTransaction f
JOIN dbo.DimCustomer c ON f.CustomerKey = c.CustomerKey
GROUP BY c.CustomerSegment
ORDER BY TotalTransactionValue DESC;
-- 2. Which branches perform well or need attention?
WITH BranchPerf AS (
    SELECT
        b.BranchKey,
        b.BranchName,
        b.Region,
        SUM(f.TransactionAmount) AS TotalAmount
    FROM dbo.FactTransaction f
    JOIN dbo.DimBranch b ON f.BranchKey = b.BranchKey
    GROUP BY b.BranchKey, b.BranchName, b.Region
),
RegionAvg AS (
    SELECT Region, AVG(TotalAmount) AS RegionAvgAmount
    FROM BranchPerf
    GROUP BY Region
)
SELECT
    bp.BranchName,
    bp.Region,
    bp.TotalAmount,
    ra.RegionAvgAmount,
    CASE
        WHEN bp.TotalAmount < ra.RegionAvgAmount * 0.8 THEN 'Needs Attention'
        WHEN bp.TotalAmount > ra.RegionAvgAmount * 1.2 THEN 'Performing Well'
        ELSE 'On Par'
    END AS PerformanceFlag
FROM BranchPerf bp
JOIN RegionAvg ra ON bp.Region = ra.Region
ORDER BY bp.Region, bp.TotalAmount DESC;

-- 3. Which channels are most successful?
SELECT
    TransactionChannel,
    COUNT(*) AS TotalTransactions,
    SUM(CASE WHEN TransactionStatus = 'Success' THEN 1 ELSE 0 END) AS SuccessCount,
    CAST(SUM(CASE WHEN TransactionStatus = 'Success' THEN 1 ELSE 0 END) AS DECIMAL(10,2))
        / COUNT(*) * 100 AS SuccessRatePct
FROM dbo.FactTransaction
GROUP BY TransactionChannel
ORDER BY SuccessRatePct DESC;

-- 4. Where are transaction failures concentrated?
SELECT
    TransactionChannel,
    COUNT(*) AS TotalTransactions,
    SUM(CASE WHEN TransactionStatus = 'Failed' THEN 1 ELSE 0 END) AS FailedCount,
    CAST(SUM(CASE WHEN TransactionStatus = 'Failed' THEN 1 ELSE 0 END) AS DECIMAL(10,2))
        / COUNT(*) * 100 AS FailureRatePct,
    SUM(CASE WHEN TransactionStatus = 'Failed' THEN TransactionAmount ELSE 0 END) AS RevenueAtRisk
FROM dbo.FactTransaction
GROUP BY TransactionChannel
ORDER BY FailureRatePct DESC;


-- 5. Which account types are most valuable?
SELECT
    a.AccountType,
    COUNT(DISTINCT a.AccountKey) AS TotalAccounts,
    SUM(f.TransactionAmount)     AS TotalTransactionValue,
    AVG(f.TransactionAmount)     AS AvgTransactionValue,
    AVG(a.InterestRate)          AS AvgInterestRate
FROM dbo.DimAccount a
JOIN dbo.FactTransaction f ON a.AccountKey = f.AccountKey
GROUP BY a.AccountType
ORDER BY TotalTransactionValue DESC;

-- 6. Which customers have cross-sell potential?
WITH CustomerAccounts AS (
    SELECT CustomerKey, COUNT(*) AS NumAccounts
    FROM dbo.DimAccount
    GROUP BY CustomerKey
)
SELECT
    c.CustomerKey,
    c.CustomerSegment,
    c.AnnualIncome,
    ca.NumAccounts,
    CASE
        WHEN ca.NumAccounts = 1 AND c.AnnualIncome > 800000 THEN 'High Priority - Cross-sell'
        WHEN ca.NumAccounts = 1 THEN 'Cross-sell Candidate'
        ELSE 'Existing Multi-product Customer'
    END AS CrossSellFlag
FROM dbo.DimCustomer c
JOIN CustomerAccounts ca ON c.CustomerKey = ca.CustomerKey
ORDER BY CrossSellFlag, c.AnnualIncome DESC;

-- 7. Does income relate to banking activity?
SELECT
    CASE
        WHEN c.AnnualIncome < 300000 THEN '< 3L'
        WHEN c.AnnualIncome < 800000 THEN '3 to 8 Lakhs'
        WHEN c.AnnualIncome < 1500000 THEN '8 to 15 Lakhs'
        ELSE '15L+'
    END AS IncomeBand,
    COUNT(DISTINCT c.CustomerKey) AS CustomerCount,
    COUNT(f.TransactionKey)       AS TotalTransactions,
    SUM(f.TransactionAmount)      AS TotalTransactionValue,
    AVG(f.TransactionAmount)      AS AvgTransactionValue
FROM dbo.DimCustomer c
LEFT JOIN dbo.FactTransaction f ON c.CustomerKey = f.CustomerKey
GROUP BY
    CASE
        WHEN c.AnnualIncome < 300000 THEN '< 3L'
        WHEN c.AnnualIncome < 800000 THEN '3 to 8 Lakhs'
        WHEN c.AnnualIncome < 1500000 THEN '8 to 15 Lakhs'
        ELSE '15L+'
    END
ORDER BY TotalTransactionValue DESC;

-- 8. How is transaction performance changing monthly?
WITH MonthlyPerf AS (
    SELECT
        d.[Year],
        d.[Month],
        d.MonthName,
        SUM(f.TransactionAmount) AS MonthlyAmount,
        COUNT(*)                 AS MonthlyCount
    FROM dbo.FactTransaction f
    JOIN dbo.DimDate d ON f.DateKey = d.DateKey
    GROUP BY d.[Year], d.[Month], d.MonthName
)
SELECT
    [Year],
    MonthName,
    MonthlyAmount,
    MonthlyCount,
    LAG(MonthlyAmount) OVER (ORDER BY [Year], [Month]) AS PrevMonthAmount,
    MonthlyAmount - LAG(MonthlyAmount) OVER (ORDER BY [Year], [Month]) AS MoMChange
FROM MonthlyPerf
ORDER BY [Year], [Month];


-- 9. Which customer groups have high failure rates?
SELECT
    c.CustomerSegment,
    c.Occupation,
    COUNT(*) AS TotalTransactions,
    SUM(CASE WHEN f.TransactionStatus = 'Failed' THEN 1 ELSE 0 END) AS FailedTransactions,
    CAST(SUM(CASE WHEN f.TransactionStatus = 'Failed' THEN 1 ELSE 0 END) AS DECIMAL(10,2))
        / COUNT(*) * 100 AS FailureRatePct
FROM dbo.FactTransaction f
JOIN dbo.DimCustomer c ON f.CustomerKey = c.CustomerKey
JOIN dbo.DimAccount a  ON f.AccountKey  = a.AccountKey
JOIN dbo.DimBranch b   ON f.BranchKey   = b.BranchKey
GROUP BY c.CustomerSegment, c.Occupation
HAVING COUNT(*) > 20
ORDER BY FailureRatePct DESC;


-- 10. Where should management focus operational improvement?
WITH BranchKPI AS (
    SELECT
        b.BranchName,
        b.Region,
        COUNT(*) AS TxnVolume,
        SUM(f.TransactionAmount) AS TotalRevenue,
        CAST(SUM(CASE WHEN f.TransactionStatus = 'Failed' THEN 1 ELSE 0 END) AS DECIMAL(10,2))
            / COUNT(*) * 100 AS FailureRatePct,
        SUM(CASE WHEN f.TransactionStatus = 'Failed' THEN f.TransactionAmount ELSE 0 END) AS RevenueAtRisk
    FROM dbo.FactTransaction f
    JOIN dbo.DimBranch b ON f.BranchKey = b.BranchKey
    GROUP BY b.BranchName, b.Region
),
Scored AS (
    SELECT *,
        (RevenueAtRisk * 0.5) + (FailureRatePct * 1000) + (TxnVolume * 0.1) AS PriorityScore
    FROM BranchKPI
)
SELECT TOP 3
    BranchName,
    Region,
    TxnVolume,
    TotalRevenue,
    FailureRatePct,
    RevenueAtRisk,
    PriorityScore
FROM Scored
ORDER BY PriorityScore DESC;