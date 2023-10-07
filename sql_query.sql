-- define customer table
SELECT * 
FROM `transaction.customer_detail`

-- define order table
SELECT * 
FROM `transaction.order_detail`

-- define payment table
SELECT * 
FROM `transaction.payment_detail`

-- define sku table
SELECT * FROM `transaction.sku_detail`

-- CASE 1 : Bulan dengan total transaksi terbesar selama tahun 2021
SELECT 
  EXTRACT(MONTH FROM order_date) AS month
  , ROUND(SUM(after_discount)) AS total
FROM 
  `transaction.order_detail`
WHERE
  EXTRACT(YEAR FROM order_date) = 2021 
  AND is_valid = 1
GROUP BY 
  month
ORDER BY 
  total DESC

-- CASE 2 : Kategori yang menghasilkan nilai transaksi paling besar selama tahun 2022
SELECT 
  sd.category
  , ROUND(SUM(od.after_discount)) as total
FROM
  `transaction.order_detail` od
FULL OUTER JOIN
  `transaction.sku_detail` sd
ON 
  od.sku_id = sd.id
WHERE
  EXTRACT(YEAR FROM od.order_date) = 2022
  AND is_valid = 1
GROUP BY category
ORDER BY total DESC

-- CASE 3 : Kategori yang mengalami peningkatan dan penurunan selama tahun 2021 - 2022
WITH compare AS (
  SELECT 
    category
    , ROUND(SUM(CASE WHEN EXTRACT(YEAR FROM order_date)=2021 THEN after_discount END)) AS total_of_2021
    , ROUND(SUM(CASE WHEN EXTRACT(YEAR FROM order_date)=2022 THEN after_discount END)) AS total_of_2022
  FROM 
    `transaction.order_detail` as od
    LEFT JOIN `transaction.sku_detail` as sd
    ON od.sku_id = sd.id
  WHERE
    is_valid = 1
  GROUP BY
    category
)
SELECT 
  *
  , (total_of_2022 - total_of_2021) AS total 
FROM compare
ORDER BY total DESC

-- CASE 4 : 5 metode pembayaran paling populer pada tahun 2022
SELECT 
  pd.payment_method
  , COUNT(DISTINCT od.id) as order_total
FROM `transaction.order_detail` as od
LEFT JOIN `transaction.payment_detail` as pd
  ON od.payment_id = pd.id
WHERE 
  EXTRACT(YEAR FROM od.order_date)=2022
  AND is_valid = 1
GROUP BY 
  pd.payment_method
ORDER BY 
  order_total DESC
LIMIT 5;


-- CASE 5 : Urutan produk berdasarkan nilai transaksi (Samsung, Apple, Sony, Huawei, Lenovo)
WITH top_brand AS (
  SELECT 
    CASE 
      WHEN LOWER(sku_name) LIKE '%samsung%' THEN 'Samsung'
      WHEN LOWER(sku_name) LIKE '%apple%'
        OR LOWER(sku_name) LIKE '%iphone%'
        OR LOWER(sku_name) LIKE '%macbook%' THEN 'Apple'
      WHEN LOWER(sku_name) LIKE '%sony%' THEN 'Sony'
      WHEN LOWER(sku_name) LIKE '%huawei%' THEN 'Huawei'
      WHEN LOWER(sku_name) LIKE '%lenovo%' THEN 'Lenovo'
    END AS brand_name,
    ROUND(SUM(od.after_discount)) AS total_sales
  FROM `transaction.order_detail` as od
  FULL JOIN `transaction.sku_detail` as sd
    ON od.sku_id = sd.id
  WHERE is_valid = 1
  GROUP BY brand_name
  ORDER BY total_sales DESC
)
SELECT * 
FROM top_brand
WHERE brand_name IS NOT NULL