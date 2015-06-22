## Project 2 - Course 4 - Exploratory Data Analysis
## Coursera
## John Hopkins University
##
## Daniel Ambrosio
##
## Original data file available at:
## https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip
##

## Get the zip file needed for this exercise and unzip it
## This should be supplied as a different source file, however this exercise
## is not to be uploaded to git, but to copy/paste on the coursera page
get_files <- function() {
    zipFile <- paste(dir.data,"projectdata.zip",sep="/")
    
    #
    # Get the remote data into a working data folder and unzip it
    #
    if(!file.exists(dir.data)) {dir.create(dir.data)}
    if(!file.exists(zipFile)) {
        print("downloading zip file...")
        zipFileURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
        download.file(zipFileURL, destfile=zipFile, method="curl")    
    } else {
        print("zip file found - no need to download again")
    }
    
    if(!file.exists(file.NEI)) {
        print(paste("unzipping file... ",file.NEI))
        unzip(zipFile, exdir=dir.data)
    } else {
        print(paste("unzipped file found - ",file.NEI, " - skipping"))
    }
    
    if(!file.exists(file.SCC)) {
        print(paste("unzipping file... ",file.SCC))
        unzip(zipFile, exdir=dir.data)
    } else {
        print(paste("unzipped file found - ",file.SCC, " - skipping"))
    }
    
}



# save current directory and change wd to current source file's path
# this assumes that the data files are in the same folder as the source
dir.old <- getwd()
dir.wd <- dirname(parent.frame(2)$ofile)
setwd(dir.wd)

dir.data <- paste(dir.wd,"data",sep="/")
dir.images <- paste(dir.wd,"images",sep="/")
file.NEI <- paste(dir.data,"summarySCC_PM25.rds",sep="/")
file.SCC <- paste(dir.data,"Source_Classification_Code.rds",sep="/")


get_files()

# Checks if the needed files are actually in the working directory
if (length(dir(path=dir.data,pattern="summarySCC_PM25.rds")) == 0) {
    print("Working files not found!")
} else {
    
    if (!exists("NEI")) {
        print("Reading NEI data...")
        s <- system.time({
            NEI <- readRDS(file.NEI)
        })
        print(s)    
    } else {
        print("NEI data found in memory - will not load!")
    }
    
    if (!exists("SCC")) {
        print("Reading SCC data...")
        s <- system.time({
            SCC <- readRDS(file.SCC)
        })
        print(s)    
    } else {
        print("SCC data found in memory - will not load!")
    }
    
    ## 
    ## How have emissions from motor vehicle sources changed from 1999–2008 
    ## in Baltimore City?
    ##

    print("Subsetting to have Baltimore City only")
    subset <- NEI[NEI$fips == "24510", ] 
    
    if(!file.exists(dir.images)) {dir.create(dir.images)}    
    
    ## find all emission types that have Motor Vehicle in the name
    ## filtering by "Motor Vehicle" there seems to be not enough data, so I 
    ## changed the filter into "Motor" only, which will include Motorcycles - 
    ## a matter of semantics, whether a Motorcycle is a Motor Vehicle
    print("Identifying Motor Vehicles code...")
    scc_motor <- SCC[grep("motor", SCC$Short.Name, ignore.case = T), ]
    nei_motor <- subset[subset$SCC %in% scc_motor$SCC, ]
    
    print("Aggregating Motor Vehicles Emissions...")
    motorEmissions <- aggregate(nei_motor$Emissions, list(nei_motor$year), FUN = "sum")
    
    png(filename = paste(dir.images,"plot5.png",sep="/"), 
        width = 480, height = 480, 
        units = "px")
    
    plot(motorEmissions, type = "l", xlab = "Year", 
         main = "Total Emissions From Motor Vehicles-related\n Sources in Baltimore (1999-2008)", 
         ylab = "Total PM2.5 Emission")
    
    dev.off()
    
}


# go back to old working directory
setwd(dir.old)
