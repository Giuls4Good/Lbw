# Import package for missing data analysis
library("VIM")
library("Amelia")
library("mice")
library("Hmisc")
library("hot.deck")
library("BaylorEdPsych")
library("fBasics")
library("pastecs")
############################ Import the 3 datasets #################################

#setwd("C://Users//Utente 2//Documents//GitHub//Lbw")
lbw_data = read.csv("oxwaspLbw.csv")
bp_data = read.csv("oxwaspbp.csv", sep=" ")
GCSE_data = read.csv("oxwaspGCSE.csv")

##################### Clean and prepare lbw_data for analysis #######################

# Erase income variable - considered as not reliable
drops <- c("incf","incm")
lbw_data = lbw_data[,!(names(lbw_data) %in% drops)]

# Remove missing data in the response variable iqfull (MNAR - cannot do anything)
#lbw_data = lbw_data[!is.na(lbw_data$iqfull),]

# Clean the variables educage and fed
lbw_data$educage[lbw_data$educage == 99] = NA
lbw_data$fed[lbw_data$fed == 9] = NA

# Make mother education (educage) and father education (fed) consistent
lbw_data$educage[lbw_data$educage > 16] = "Greater"
lbw_data$educage[lbw_data$educage <= 16] = "Smaller"
lbw_data$educage[lbw_data$educage == "Greater"] = 1
lbw_data$educage[lbw_data$educage == "Smaller"] = 2
lbw_data$educage = as.numeric(lbw_data$educage)

#Convert to factors
lbw_data$sex = factor(lbw_data$sex)
lbw_data$fed = factor(lbw_data$fed)
lbw_data$educage = factor(lbw_data$educage)
lbw_data$benef = factor(lbw_data$benef)
lbw_data$mcig = factor(lbw_data$mcig)
lbw_data$socstat = factor(lbw_data$socstat)


######################## Clean and prepare GCSE data for analysis #####################

# values from 0 to 8
GCSE_subset = GCSE_data[,c("sciencea", "mathstat", "english", "code")]

# Remove obs in GCSE for wich all three grades (sciencea, english and mathstat) are missing
GCSE_subset_clean = GCSE_subset[!is.na(GCSE_subset$sciencea) | !is.na(GCSE_subset$mathstat) | !is.na(GCSE_subset$english),]


################################ Merge datasets ####################################

# Merge lbw data with bp data
data_1_2 = merge(lbw_data,bp_data,by="code")

# Merge lbw data with GCSE data
data_1_3 = merge(lbw_data, GCSE_subset_clean, by="code")

# Merge all 3 datasets keeping only common obs
data_1_2_3 = merge(data_1_2,GCSE_subset_clean,by="code")

# If we don't use blood pressure measurements and height we use data_1_3
# We loose 43 observations 
total_data = data_1_3

############################### Summarize datasets ###############################

# Summary of lbw dataset
attach(lbw_data)

hist(iqfull)
hist(rcomp)
hist(rrate)
hist(racc)
hist(tomifull)
hist(bw)
table(bw)
hist(rbw)
hist(mcig)
hist(socstat)

table(incm)
table(incf)
table(mcig)
table(socstat)
table(benef)

#lbw_data[is.na(lbw_data$rcomp),20]
#lbw_data[is.na(lbw_data$rrate),20]
lbw_data[is.na(lbw_data$racc),20]
lbw_data[is.na(lbw_data$iqfull),20]
lbw_data[is.na(lbw_data$tomifull),20]
lbw_data[is.na(lbw_data$fed),20] == lbw_data[is.na(lbw_data$educage),20]
lbw_data[lbw_data$fed==9 & !is.na(lbw_data$fed),20] == lbw_data[lbw_data$educage==99 & !is.na(lbw_data$educage),20]

lbw_data[is.na(lbw_data$incm),20] == lbw_data[is.na(lbw_data$incf),20]
lbw_data[is.na(lbw_data$incm),20] == lbw_data[is.na(lbw_data$educage),20]

lbw_data[is.na(lbw_data$socstat),20] == lbw_data[is.na(lbw_data$mcig),20]
lbw_data[is.na(lbw_data$mcig),20] == lbw_data[is.na(lbw_data$educage),20]



######################## Missing data plots (lbw data) with VIM #####################

# Missing data pattern
lbw_data_toplot = lbw_data[,c(-4,-5,-6,-18)] 
lbw_aggr = aggr(lbw_data_toplot, numbers=TRUE, prop = FALSE, sortVars=TRUE, labels=names(lbw_data), cex.axis=.7, gap=3, ylab=c("Frequency of missingness","Missingness Pattern"))

# Margin plot (scatter plot + box plots)

#marginplot(lbw_data[, c("benef", "educage", "socstat","mcig", "incm", "incf")], col = mdc(1:2), cex.numbers = 1.2, pch = 19)
#marginplot(lbw_data[, c("benef", "educage")], col = mdc(1:2), cex.numbers = 1.2, pch = 19)

# distribution of the educage for benefit missing and benefit not missing.
# no big difference : the fact that benef is missing does not depend on the educational level
marginplot(lbw_data[, c("educage", "benef")], col = mdc(1:2), cex.numbers = 1.2, pch = 19)

marginplot(lbw_data[, c("educage", "socstat")], col = mdc(1:2), cex.numbers = 1.2, pch = 19)

# The socstat for non observed educage seems to be higher thus socstat (only 9 NA) could be used to infer educage
marginplot(lbw_data[, c("socstat", "educage")], col = mdc(1:2), cex.numbers = 1.2, pch = 19)
marginplot(lbw_data[, c("matage", "socstat")], col = mdc(1:2), cex.numbers = 1.2, pch = 19)

# The mother age is higher when educage educage is missing 
marginplot(lbw_data[, c("matage", "educage")], col = mdc(1:2), cex.numbers = 1.2, pch = 19)

# Difference in the number of cigarette when educage is missing.  
marginplot(lbw_data[, c("mcig", "educage")], col = mdc(1:2), cex.numbers = 1.2, pch = 19)


# Matrix plot : no big correlation
matrixplot(lbw_data, interactive = F, sortby = "matage")
matrixplot(lbw_data, interactive = F, sortby = "ga")
matrixplot(lbw_data, interactive = F, sortby = "mcig")
matrixplot(lbw_data, interactive = F, sortby = "socstat")
matrixplot(lbw_data, interactive = F, sortby = "educage")

######### Correlation plots ###########
pairs(lbw_data[,c(-2,-3,-4,-5,-6,-7)])

######### Test for data MCAR ###########
# The null hp is data MCAR - pvalue small, null hp rejected
# Data not completely at random
LittleMCAR(lbw_data) 


################################ Table for the report ###################################
attach(lbw_data)
dataToDescribe<-cbind(iqfull, iqverb, iqperf, tomifull, bw, rbw, ga, educage, fed, benef, matage, mcig, socstat)
stat.desc(dataToDescribe)
options(scipen=100)
options(digits=2)
stat.desc(dataToDescribe)
totable = t(as.matrix(stat.desc(dataToDescribe)))
totable = totable[,c(3,4,5,8,9,13)]
totable = totable[, c(2,3,4,5,6,1)]
colnames(totable) = c("Minimum", "Maximum", "Median", "Mean", "Standard deviation", "NA values")
stargazer::stargazer(totable,title = "Dataset summary")

educageFreq = as.matrix(table(educage))
colnames(educageFreq) = c("Mother education")
fedFreq = as.matrix(table(fed))
colnames(fedFreq) = c("Father education")

sexFreq = as.matrix(table(sex))
colnames(sexFreq) = c("Sex")

benefFreq = as.matrix(table(benef))
colnames(benefFreq) = c("Social benefit")

CigFreq = as.matrix(table(mcig))
colnames(CigFreq) = c("Cig.")

socstatFreq = as.matrix(table(socstat))
colnames(socstatFreq) = c("Socio economic status")

n <- max(length(sexFreq), length(educageFreq), length(fedFreq), length(benefFreq), length(CigFreq), length(socstatFreq))

length(sexFreq) = n
length(educageFreq)= n
length(fedFreq)= n
length(benefFreq)= n
length(CigFreq)= n
length(socstatFreq)= n

totable2 = t(cbind(sexFreq, educageFreq, fedFreq, benefFreq, CigFreq, socstatFreq))
