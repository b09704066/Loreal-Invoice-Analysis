#匯出missing_ids
setwd("C:/Users/LIN/Desktop/NTU_DAC/上學期專案/20241020")
library(readxl)
data <- read_excel("ID check.xlsx")
missing_ids <- setdiff(data$invoice_id, data$luxe_id)
print(missing_ids)
str(missing_ids)
library(writexl)
missing_ids_df <- data.frame(missing_ids)
write_xlsx(missing_ids_df, "missing_ids.xlsx")

## 匯入資料
setwd("C:/Users/user/Desktop/NTU_DAC/上學期專案/20241102")
library(readxl)
library(writexl)
invoice <- read_excel("invoice.xlsx")
str(invoice)

#step1 過濾掉 item_name 為 "999999" 的列(共刪掉350筆)
invoice <- invoice[invoice$item_name != "999999", ]

#step2 刪除LUXE_trx 缺失的53位costomer_id(共刪掉4014筆)
delete_ids <- read_excel("missing_ids.xlsx")
delete_ids_list <- delete_ids$missing_ids
cleaned_data <- invoice[!invoice$customer_id %in% delete_ids_list, ]

#step3 刪除負值資料
cleaned_data <- cleaned_data[cleaned_data$amount == cleaned_data$unit_price * cleaned_data$quantity, ]
cleaned_data <- cleaned_data[cleaned_data$amount >0 & cleaned_data$unit_price >0 & cleaned_data$quantity >0, ]

#Step4.amount離群值觀察 
#發現兩筆值異常大=>移除
cleaned_data <- cleaned_data[cleaned_data$amount < 1000000 , ]
options(scipen = 10)
#cleaned_data$inv_date <- format(as.Date(cleaned_data$inv_date), "%Y/%m/%d")
#str(cleaned_data)
#write_xlsx(cleaned_data, "cleaned_data.xlsx")

#Step5.拆分客戶data
LUXE <- read_excel("LUXE_Trx.xlsx")
customer_ids <- LUXE$customer_id
#active
new_customer_ids <- subset(LUXE, R12_IB == 0 & R6_IB == 0 & R2_IB == 0 & P2_IB == 1)$customer_id
inactive_customer_ids <- subset(LUXE, R12_IB == 1 & R6_IB == 0 & R2_IB == 0 & P2_IB == 0)$customer_id

combined_customer_ids <- c(new_customer_ids, inactive_customer_ids)
combined_customer_ids <- data.frame(combined_customer_ids)

active_customer_ids <- LUXE$customer_id[!LUXE$customer_id %in% combined_customer_ids$combined_customer_ids]
active_customer_ids <- data.frame(active_customer_ids)

# LUXE 新增欄位 customer_category
library(dplyr)
LUXE <- LUXE %>%
  mutate(customer_category = case_when(
    customer_id %in% new_customer_ids ~ 1,
    customer_id %in% active_customer_ids ~ 2,
    customer_id %in% inactive_customer_ids ~ 3
  ))
invoice <- cleaned_data %>%
  mutate(customer_category = case_when(
    customer_id %in% new_customer_ids ~ 1,
    customer_id %in% active_customer_ids ~ 2,
    customer_id %in% inactive_customer_ids ~ 3
  ))
invoice$inv_date <- format(as.Date(invoice$inv_date), "%Y/%m/%d")
str(invoice)
options(scipen = 10)
write_xlsx(invoice, "invoice_clean.xlsx")
write_xlsx(LUXE, "LUXE_clean.xlsx")

## 每筆發票是否有打折
## 匯入資料
setwd("C:/Users/user/Desktop/NTU_DAC/上學期專案/20241020")
library(readxl)
discount <- read_excel("negative.xlsx")
str(discount)
discount_invoice_id <- data.frame(column_name = discount$inovice_no)
library(writexl)
write_xlsx(discount_invoice_id, "discount_invoice_id.xlsx")
write_xlsx(invoice, "invoice_negative.xlsx")

## 匯入 discount_invoice_id 資料
setwd("C:/Users/user/Desktop/NTU_DAC/上學期專案/20241106_clinc")
discount_invoice_id <- read_excel("discount_invoice_id.xlsx")
invoice_negative <- read_excel("invoice_negative.xlsx")

# 假設 invoice_negative 是包含發票資料的數據框
# discount_invoice_id 是包含有條件篩選的發票編號的數據框
# 先將 discount_invoice_id 中的 invoice_no 提取成向量
discount_ids <- discount_invoice_id$column_name

# 新增 discount 欄位，判斷每筆發票是否在 discount_ids 名單中
library(dplyr)
invoice_negative <- invoice_negative %>%
  mutate(discount = ifelse(inovice_no %in% discount_ids, 1, 0))
write_xlsx(invoice_negative, "invoice_negative_clean.xlsx")