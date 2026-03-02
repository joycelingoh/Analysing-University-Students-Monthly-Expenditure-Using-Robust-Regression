library(tidyverse)
library(janitor)
library(car)
library(nortest)
library(lmtest)
library(quantreg)
library(robustbase)
library(stringr)

##### Import Data #####
data_raw <- read_csv("pengeluaran_bulanan_mahasiswa_updated45.csv")
head(data_raw)

##### Format Data #####
data <- data_raw %>% clean_names()

names(data)

data_clean <- data %>%
  rename(
    x1  = berapa_rata_rata_uang_saku_yang_anda_terima_per_bulan_rupiah_contoh_1234000,
    x2  = dimana_anda_tinggal_selama_kuliah,
    y   = berapa_total_pengeluaran_anda_dalam_1_bulan_terakhir_rupiah_contoh_1234000,
    x3  = berapa_kali_anda_makan_di_luar_dalam_1_minggu_angka_contoh_6,
    x4  = berapa_kali_anda_melakukan_kegiatan_hiburan_nongkrong_dalam_1_minggu_angka_contoh_2,
    x5  = berapa_total_pengeluaran_transportasi_anda_dalam_1_bulan_terakhir_rupiah_contoh_1234000,
    x6  = saya_membuat_anggaran_budget_bulanan,
    x7  = saya_mencatat_pengeluaran_saya_secara_rutin,
    x8  = saya_menyisihkan_uang_untuk_ditabung_di_awal_bulan,
    x9  = saya_sering_membeli_sesuatu_secara_impulsif,
    x10 = saya_membandingkan_harga_sebelum_membeli_barang
  ) %>%

mutate(
  x1 = as.numeric(x1),
  x3 = as.numeric(x3),
  x4 = as.numeric(x4),
  x5 = as.numeric(x5),
  y  = as.numeric(y),
  
  x2 = case_when(
    str_detect(str_to_lower(x2), "orang tua") ~ "parent",
    str_detect(str_to_lower(x2), "kos") | str_detect(str_to_lower(x2), "apartemen") ~ "boarding",
    str_detect(str_to_lower(x2), "asrama") ~ "dormitory",
    TRUE ~ "lainnya"
  ),
  x2 = factor(x2, levels = c("parent", "boarding", "dormitory", "others")),
  
  x6  = as.numeric(x6),
  x7  = as.numeric(x7),
  x8  = as.numeric(x8),
  x9  = as.numeric(x9), 
  x10 = as.numeric(x10)
)

glimpse(data_clean)
##### Data Exploration #####
library(ggplot2)

# Scatter plot uang saku vs pengeluaran
ggplot(data_clean, aes(x = x1, y = y)) +
  geom_point() +
  geom_smooth(method = "lm") +
  labs(title = "Hubungan Uang Saku dan Pengeluaran Bulanan",
       x = "Uang Saku (Rp/bulan)",
       y = "Total Pengeluaran Bulanan (Rp)") +
  theme_minimal()

# Scatter plot biaya transportasi bulanan vs pengeluaran
ggplot(data_clean, aes(x = x5, y = y)) +
  geom_point() +
  geom_smooth(method = "lm") +
  labs(title = "Hubungan Biaya Transportasi dan Pengeluaran Bulanan",
       x = "Total Biaya Transport per Bulan (Rp)",
       y = "Total Pengeluaran Bulanan (Rp)") +
  theme_minimal()

# Scatter plot kebiasaan menabung vs pengeluaran
ggplot(data_clean, aes(x = x8, y = y)) +
  geom_point() +
  geom_smooth(method = "lm") +
  labs(title = "Hubungan Kebiasaan Menabung dan Pengeluaran Bulanan",
       x = "Frekuensi Menabung (Skala 1–5)",
       y = "Total Pengeluaran Bulanan (Rp)") +
  theme_minimal()

# Box plot pengeluaran bulanan berdasarkan kebiasaan menabung
ggplot(data_clean, aes(x = factor(x8), y = y)) +
  geom_boxplot() +
  labs(title = "Pengeluaran Bulanan berdasarkan Kebiasaan Menabung",
       x = "Frekuensi Menabung (1 = Tidak Pernah, 5 = Sangat Sering)",
       y = "Total Pengeluaran Bulanan (Rp)") +
  theme_minimal()

# Scatter plot membandingkan harga sebelum membeli vs pengeluaran
ggplot(data_clean, aes(x = x10, y = y)) +
  geom_point() +
  geom_smooth(method = "lm") +
  labs(title = "Hubungan Perilaku Membandingkan Harga dan Pengeluaran Bulanan",
       x = "Skor Perbandingan Harga (1–5)",
       y = "Total Pengeluaran Bulanan (Rp)") +
  theme_minimal()

# Box plot pengeluaran bulanan berdasarkan perilaku membandingkan harga
data_clean <- data_clean %>%
  mutate(x10_f = factor(x10,
                        levels = 1:5,
                        labels = c("Tidak Pernah", "Jarang", "Kadang-kadang", "Sering", "Sangat Sering")))

ggplot(data_clean, aes(x = x10_f, y = y)) +
  geom_boxplot() +
  labs(title = "Pengeluaran Bulanan berdasarkan Perilaku Membandingkan Harga",
       x = "Frekuensi Membandingkan Harga",
       y = "Total Pengeluaran Bulanan (Rp)") +
  theme_minimal()

##### Model OLS Full #####
model_full <- lm(
  y ~ x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10,
  data = data_clean
)

summary(model_full)

coeff <- summary(model_full)$coefficients
coeff[, c("t value", "Pr(>|t|)")]

# Uji asumsi untuk model OLS full
# Residual
e <- resid(model_full)

# Normalitas (Lilliefors)
lillie.test(e)

# Homoskedastisitas (Breusch–Pagan)
bptest(model_full)

# Non-autokorelasi (Durbin–Watson)
dwtest(model_full)

# Multikolinearitas (VIF)
vif(model_full)

##### Uji Korelasi #####
vars_cor <- data_clean %>% select(y, x1, x3, x4, x5, x6, x7, x8, x9, x10)
cor_mat <- cor(vars_cor, use = "pairwise.complete.obs")
cor_mat

# Korelasi masing-masing variabel dengan y
cor_with_y <- cor_mat[, "y"]
cor_with_y

cor(vars_cor, use = "pairwise.complete.obs")

cor.test(data_clean$x1, data_clean$y)
cor.test(data_clean$x3, data_clean$y)
cor.test(data_clean$x4, data_clean$y)
cor.test(data_clean$x5, data_clean$y)
cor.test(data_clean$x6, data_clean$y)
cor.test(data_clean$x7, data_clean$y)
cor.test(data_clean$x8, data_clean$y)
cor.test(data_clean$x9, data_clean$y)
cor.test(data_clean$x10, data_clean$y)

# Anova untuk X2
anova_model <- aov(y ~ x2, data = data_clean)
summary(anova_model)

# Uji lanjut (post-hoc, grup mana yang beda)
TukeyHSD(anova_model)

# Kruskal wallis untuk X2
kruskal.test(y ~ x2, data = data_clean)

##### Uji Outlier dan Pengamatan Berpengaruh #####
# Outlier di variabel respons
std_resid <- rstandard(model_full)
outlier_3sd <- which(abs(std_resid) > 3)
outlier_3sd

# Outlier di variabel prediktor (high leverage)
high_leverage <- which(hatvalues(model_full) > 2*(10+1)/45)
high_leverage

# Pengamatan berpengaruh dengan cook's distance
cook <- cooks.distance(model_full)
influential_observation <- which(cook > 1)
influential_observation

##### Model Reduced (X1, X5, X8) #####
# model_ols_red <- lm(
#  y ~ x1 + x5 + x8,
#  data = data_clean
# )

# summary(model_ols_red)

# Uji asumsi untuk model reduced
# e_red <- resid(model_ols_red)
# lillie.test(e_red)
# bptest(model_ols_red)
# dwtest(model_ols_red)
# vif(model_ols_red)


##### Model Robust Regression Full #####
model_rob_full <- lmrob(
  y ~ x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10,
  data = data_clean,
  control = lmrob.control(
    max.it = 100,      
    k.max  = 100,      
    trace.lev = 0
  )
)

summary(model_rob_full)

coeffR <- summary(model_rob_full)$coefficients
coeffR[, c("t value", "Pr(>|t|)")]

# Uji asumsi untuk model robust regression
# Residual
e <- resid(model_rob_full)

# Normalitas (Lilliefors)
lillie.test(e)

# Homoskedastisitas (Breusch–Pagan)
bptest(model_rob_full)

# Non-autokorelasi (Durbin–Watson)
dwtest(model_rob_full)

# Multikolinearitas (VIF)
vif(model_rob_full)





