#Final Project Forecasting Method

library(TSA)
library(forecast)
library(tseries)
library(normtest)
library(Hmisc)

data <- GOOG

View(data)

summary(data)
describe(data)
max(data)
min(data)
mean(data)
var(data)
plot(data)

#Stationary Test
x <- ts(data.matrix(data),frequency = 1)
plot(x)
adf.test(x)

#differencing
difinaf<-diff(x,differences = 1)
plot(difinaf)

adf.test(difinaf)

#MODEL SPECIFICATION
tsdisplay(difinaf)
acf(difinaf) #ARIMA(0,1,6)
pacf(difinaf) #ARIMA(6,1,0)
eacf(difinaf)

#ARIMA Candidate Model Test
model1 <- Arima(x,order=c(0,1,6),include.constant = TRUE)
model2 <- Arima(x,order=c(6,1,0),include.constant = TRUE)
model3 <- Arima(x,order=c(0,1,1),include.constant = TRUE)
model4 <- Arima(x,order=c(1,1,1),include.constant = TRUE)

cbind(model1,model2,model3,model4)

#Parameter Estimation
#The Best Model
fit <- Arima(x,order=c(1,1,1),include.constant = TRUE)
fit

#Diagnostik Checking model fit
#Residual Analysis: Uji stasioner residual, independensi, normalitas

#Residual Stationary Test
adf.test(fit$residuals)

#Independency Test 
#ljung box ho: residual independen
checkresiduals(fit)

#Normality Test
#h0: berdistribusi normal
qqnorm(fit$residuals)
qqline(fit$residuals, col = 'red', lwd=3)

shapiro.test(fit$residuals)
ks.test(fit$residuals,'pnorm',0,sd(fit$residuals))

jb.norm.test(fit$residuals)

#Overfitting
overfit1 <-Arima(x,order=c(2,1,1),include.constant = TRUE)
overfit1
overfit2 <-Arima(x,order=c(1,1,2),include.constant = TRUE)
overfit2

cbind(fit,overfit1,overfit2)

#H0: phi(parameter)=0
#uji-t
#Overfit1 : ar2
stat_uji_ar2 <- overfit1$coef[['ar2']]/0.1103
df <- length(x)-1

#t-tabel
daerah_kritis <- qt(0.025,df)
daerah_kritis; stat_uji_ar2

#p-value
2*(pt(stat_uji_ar2,df))

#Overfit2 : ma2
stat_uji_ma2 <- overfit2$coef[['ma2']]/0.0986
df <- length(x)-1

#t-tabel
daerah_kritis <- qt(0.025,df)
daerah_kritis; stat_uji_ma2

#p-value
2*(pt(stat_uji_ma2,df))

#FORECASTING
#cross-validation
train <- window(x, end=106)
test <- window(x, start=107)

train_fit <- Arima(train,order=c(1,1,1),include.constant = TRUE)
forecast_train <- forecast(train_fit, 5)
cbind(test,forecast_train)

plot(forecast_train,
     fcol="blue",lwd=2,
     main = 'Perbandingan data test vs hasil prediksi ARIMA(1,1,1)',
     xlab = 'periode',
     ylab = 'harga')
lines(seq(107,111),
      test[1:5],
      col = 'red',
      lwd = 2)
legend('bottomright',
       col=c('blue','red'),
       legend = c('nilai prediksi','nilai aktual'),
       lwd=2,
       bty='n')

mean(abs(test-forecast_train$mean))

#Forecast final (new data)
fit #use all data
forecast_final <- forecast(fit,h=5)
forecast_final

plot(forecast_final,
     fcol="blue",lwd=2,
     main = 'Hasil prediksi ARIMA(1,1,1) untuk 5 Periode',
     xlab = 'periode',
     ylab = 'harga')
legend('bottomright',
       col=c('blue'),
       legend = c('nilai prediksi'),
       lwd=2,
       bty='n')
