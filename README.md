# Loreal-Invoice-Analysis

## 00 GPT Missing Category Imputation
Since the invoice data contains over 30% missing value in item category, which is critical for customer purchase preference analysis, I used chatgpt to effectively impute missing values.
1. Utilized App script to retrieve missing value cells and indices from gsheet and save to json files
2. Designed classification prompt and uploaded json files to OpenAI batch API to retrive classifications
3. Verify classification accuracy and conduct manual cleaning with app script before imputing
4. 資料清洗前後比較.ipynb evaluate performance after imputing

## 01 資料前處理 R
Conducted data preprocessing to transform messy invoice data to clean dataset for analysis. Topics I dealt with include: outliers (customers with abnormal expenditures), discount unmatches (invoices that contains dicounts are in noth nagative and positive values), format inconsistencies (different shops and vendors' way of recording invoices differs, making it hard to analyze)

## 02 通路重分類
Purchase channels are not clean and consistent. For example, a convenience store in the mall could have its channel classified as "Department Store", which may affect our analysis in customers purchase channel preference.

## 03 品類重分類
After GPT classification, though accuracy increase 14%, there are some minor inaccuracies in classifications due to chatgpt's randomness and its unfamiliarity with local item names. Therefor, I evaluate the top 50 item keywords to ensure their accuracies and perform manual modification. This adjustion ensures that our analysis will not be biased due to large amount of inaccurate classifications.

## 04 潛力分群
To tag the customers with highest potential of repurchasing this brands product, I segmented the buyers to active/ inactive/ sleep customers by last purchase time and frequencies, and focus on analyzing the inactive customers to provide reactivation strategy.
I further segmented the inactive cutomers with its annual purchase power and current spenditure on cosmetics, in order to locate those with high purchase power but have not yet spend a lot in cosmetics.
