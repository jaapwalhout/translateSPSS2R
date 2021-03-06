#' Performs a T-Test
#'
#' R implementation of the SPSS \code{T-TEST} function.
#'
#' Performs a Student's T-Test. The \code{xpssTtest} compares the mean by calculating Students-t of the selected distributions.
#' 
#' It is possible to check the samples.
#' 
#' \enumerate{
#' \item against a specific value (one-sample) -> \code{testval}
#' \item in difference of groups (independent-sample)-> \code{groups}
#' \item in difference of variables (paired-sample) -> \code{pairs}
#'  }
#' 
#' Simple statistics will be printed with every t-test.
#' At the one-sample test, the mean difference will be visualized with the statistics \cr
#' At the independend-sample test, the mean differnce and ANOVA will be visualized with the statistics \cr
#' At the paired-sample test, the mean diference and a correlation statistic will be visualizied with the statistics \cr
#'
#' @param x a (non-empty) data.frame or input data of class \code{"xpssFrame"}. 
#' @param variables atomic character or character vector with the names of the variables.
#' @param t_test atomic character definies the type of t-test. Default is \code{testval}, a one-sample t-test. 
#' Optional arguments are \code{groups} for an independent-sample test and \code{pairs} for an paires-sample test 
#' @param testval atomic numeric which indicates the value of mean difference.
#' @param criteria atomic numeric which specifies the confidence interval for the mean differences. Default
#' is \code{"0.95"}, optionally a customized value between 0 and 1 can be used.
#' @param groupvar atomic character with the name of the variable which shall be used for grouping.
#' @param groups factor variable which specify the variables grouped for an independentsample t-test.
#' @param paired logical. Indicating whether the comparison should be pair based or not.
#' @param withvars atomic characters or character vector with the name of the paired variables which shall be used for compare the means. Optionally
#' the argument \code{with} can be chosen to compare the means of 2 pairs.
#' @param missing atomic character determines the method which indicates what should happen when the data contains NAs. Default is analysis.
#' Optionally \code{include} oder \code{listwise} can be used.
#' @return returns a list depending upon the t-test.
#' 
#'  All t-test contain: \cr
#' \tabular{rlll}{
#' 
#' \tab \code{statistics} \tab  simple statistics. \cr
#' \tab \code{parameter} \tab degrees of freedom. \cr
#' \tab \code{p.value} \tab significance level. \cr
#' \tab \code{conf.int} \tab confidence bound. \cr
#' \tab \code{null.value} \tab value of null hypothesis. \cr
#' \tab \code{alternative} \tab value of alternative hypothesis. \cr
#' \tab \code{method} \tab character string with the name of the t-test. \cr
#' \tab \code{data.name} \tab name of the data.} 
#' 
#' The independent t-test includes additonally: \cr
#' \tabular{rlll}{
#' 
#' \tab \code{anova} \tab anova of the groups.}
#' 
#' The paired t-test includes additonally: \cr
#' \tabular{rlll}{
#' 
#' \tab \code{corr} \tab correlation of the pairs.}
#' 
#' @author Bastian Wiessner
#' 
#' @importFrom car leveneTest
#' 
#' @examples
#' # load data
#' data(fromXPSS)
#' 
#' 
#' # one-sample t-test
#' xpssTtest(fromXPSS,
#'                    variables = "V7_2", 
#'                    t_test = "testval", 
#'                    testval= 50, 
#'                    criteria = 0.65)
#'
#' # paired sample t-test             
#' xpssTtest(fromXPSS,
#'                    t_test = "pairs",
#'                    variables=c("V5",
#'                                "V6",
#'                                "V7_1",
#'                                "V7_2"), 
#'                    paired = T,
#'                    missing = "analysis",
#'                    criteria = 0.85)
#'             
#' # independent sample t-test                           
#' xpssTtest(fromXPSS, 
#'                    variables = "V7_2", 
#'                    t_test = "groups",
#'                    groupvar = "V3", 
#'                    groups = c(1, 2), 
#'                    missing = "analysis",
#'                    criteria = 0.99)
#' @export
xpssTtest <- function(x,
                      variables = NULL,
                      t_test = "testval",
                      testval = NULL,
                      criteria = 0.95,
                      groupvar = NULL,
                      groups = NULL,
                      withvars = NULL,
                      paired = FALSE,
                      missing = "analysis") 
{
  t.with <- list(withvars[[1]])
  t.group  <- logvec_withvars <- logvec <- myt <- list()
  t.one <- t.cor <- f.out <-erg <- list()
  t.val <- data.frame(x[,variables])
  ####################################################################
  ####################### Meta - Checks ##############################
  ####################################################################
  ### Globale Zuweisung um TEMPORARY = FALSE zu setzen
  
  functiontype <- "AN"
  dataname <- eval(paste0(deparse(substitute(x))), envir = .GlobalEnv)
  x <- applyMetaCheck(x)
  
  ####################################################################
  ####################################################################
  ####################################################################
  
  if(is.null(variables))
  {
    stop("argument variables is missing, no default available")
  }
  for(i in 1:length(variables))  {
    if(class(x[,variables[i]]) != "numeric"){  
      stop("variables are not numeric")
    } 
  }
  if(t_test != "testval" && t_test != "groups" && t_test != "pairs")  {
    stop("argument 't_test' is wrong. Only the arguments 'testval', 'groups', and 'pairs' are valid.")
  }
  if(t_test == "testval")  {
    if(is.null(testval)){
      stop("argument 'testval' is missing, no default available")
    } 
    if(class(testval) != "numeric"){
      stop("argument 'testval' is not numeric")
    }
    if(is.null(groupvar) ==F || is.null(groups) ==F || is.null(withvars) ==F)
    {
      warning("paired or grouped t-test's aren't possible at the one sample t-test")  
    }
  }
  if(t_test == "groups")  {
    if(is.null(groupvar)){
      stop("argument 'groups' is missing, no default available")
    }
    if(length(groups) > 2 || length(groups) < 2)      {
      stop("grouping factor must have exactly 2 levels")
    }  
    if(is.null(testval) ==T || is.null(withvars) ==F)
    {
      warning("one sample t-tests or paired t-test's aren't possible at indenpendent t-test's")  
    }
  }
  if(t_test == "pairs")  {
    if(is.null(x[,withvars]) == T)  {
      for(i in 1:length(x[,withvars]))    {
        if(class(x[,withvars[i]]) != "numeric"){  
          stop("withvariables are not numeric")
        } 
      }
    }
    if(is.null(testval) ==F || is.null(groupvar) ==F || is.null(groups) ==F)
    {
      warning("one sample t-tests or independent t-test's aren't possible at paired t-test's")  
    }
  }
  if(class(criteria) != "numeric"){  
    stop("argument 'criteria' is not numeric")
  }
  if(criteria >1 || criteria <0)
  {
    stop("valid arguments for 'criteria' are only single numbers between 0 and 1")
  }
  if(missing != "analysis" && missing != "listwise" && missing != "include")  {
    stop("wrong 'missing' argument. Only the arguments 'analysis', 'listwise', and 'include' are valid.")
  }
  
  options(warn=-1) 
  
  
  if(!(is.xpssFrame(x))){
    attributes(x)$SPLIT_FILE <- F
  }
  ###################################
  #
  # data preparation
  # if split file is true
  if(unique(attributes(x)$SPLIT_FILE != FALSE)){
    # split the variablenames
    splitter <- unlist(str_split(attributes(x)$SPLIT_FILE,pattern=" "))
    # exclude the the last statement
    splitter <- splitter[1:length(splitter)-1]
    splitnames <- unlist(str_split(splitter,pattern=","))
    # combine variables and split vars
    vars <- c(variables,splitnames)
    ### create subset
    # which vars and byvars are in the dataset
    if(groupvar != F || withvars != F){
      if(groupvar != F){
        pos <- sort(c(which(names(x)%in%vars),which(names(x)%in%groupvar)))  
      } else{
        pos <- sort(c(which(names(x)%in%vars),which(names(x)%in%withvars)))  
      }
    } else{
      pos <- sort(c(which(names(x)%in%vars)))  
    }
    
    
    # create data.table object
    tinput <- data.table(x[pos])  
    # combine the split vars for data.table operations
    splitter <- paste(splitter,collapse=",")
    tinput <- data.table(x[pos])  
  }else{
    tinput <- data.table(x)
  }
  
  #-----------------------------------------------------------#
  #--------------missings-----------------------
  if("analysis" %in% missing)  {
    if(is.null(withvars) && is.null(groupvar))    {
      for(i in 1:length(variables))      {
        logvec[[i]] <- is.na(tinput[,variables[i], with=F]) 
      } 
      t.val <- tinput[,variables,with=F]
    }
    else {
      if(is.null(withvars) == FALSE) {
        k <- 1
        for(i in 1:length(variables)) {
          for(j in 1:length(withvars))  {
            logvec[[k]] <- (is.na(x[,variables[i]]) | (is.na(x[,withvars[j]])))
            t.val <- x[,variables]
            t.with <- x[,withvars]
            k <- k+1
          }
        }
      }
      if(is.null(groupvar) == FALSE){
        for(i in 1:length(variables))  {
          logvec[[i]] <- is.na(x[,variables[i]]) | is.na(x[,groupvar])
          t.val[i] <- tinput[,variables[i],with=F]
        }
      }
    }
  }
  
  if("listwise" %in% missing)  {
    if(is.null(withvars))    {
      for(i in 1:length(variables))      {
        t.val[[i]] <- x[,variables[i]]
      }
    } else {
      for(i in 1:length(variables))     {
        t.val[[i]] <- x[,variables[i]]
      }
      for(i in 1:length(withvars))     {
        t.with[[i]] <- x[,withvars[i]]
      }
    }
  } 
  if("include" %in% missing)  {    
    if(is.null(withvars))    {
      x[,variables] <- computeValue(x,variables)      
      for(i in 1:length(variables))      {
        logvec[[i]] <- is.na(x[,variables[i]])  
        t.val[[i]] <- x[,variables[i]]
      }
    } else {
      temp <- computeValue(x,variables)
      
      pos <- which(names(temp) %in% variables)
      
      for(i in 1:length(variables)) {
        logvec[[i]] <- is.na(temp[,pos[i]])  
        t.val[[i]] <- temp[,pos[i]]
      }
      
      temp <- computeValue(x,withvars)
      pos <- which(names(temp) %in% withvars)
      for(i in 1:length(withvars)) {
        logvec_withvars[[i]] <- is.na(temp[,pos[i]])  
        t.with[[i]] <- temp[,pos[i]]
      }
    }
  }
  
  
  
  
  #--------------------------tests------------------
  #EinStichprobenT_Test
  
  if(t_test == "testval") {
    for(i in 1:length(variables))  {
      if(missing == "listwise")     {
        logvec <- complete.cases(t.val)
        pos <- which(logvec%in%T)
      }
      if(missing == "include") {
        pos <- which(logvec[[i]]%in%F)
      } 
      if(missing == "analysis")  {
        pos <- which(logvec[[i]]%in%F)
      }
      
      if(unique(attributes(x)$SPLIT_FILE != F)){
        t.one[[i]] <- tinput[,t.test(na.omit(get(variables[[i]])),mu=testval,conf.level=criteria),by=splitter]
        t.one[[i]][,which(is.element(names(t.one[[i]]),c("null.value","alternative","method","data.name")))] <- NULL
        t.one[[i]]$conf.int <- t.one[[i]]$conf.int - testval
        t.one[[i]]$estimate <- t.one[[i]]$conf.int[seq(from=2,to=nrow(t.one[[i]]),by=2)]
        t.one[[i]]$conf.int <- t.one[[i]]$conf.int[seq(from=1,to=nrow(t.one[[i]]),by=2)]
        t.one[[i]] <- t.one[[i]][which(duplicated(t.one[[i]][,1:length(splitnames),with=F])),]
        
      } else{
        t.one[[i]] <- t.test(t.val[pos], mu = testval,conf.level=criteria)
        t.one[[i]]$conf.int <- t.one[[i]]$conf.int - testval
        t.one[[i]]$estimate <-t.one[[i]]$estimate-10
        t.one[[i]]$data.name <- paste(attr(x[,variables[i]],"variable.label")[1])
      }      
      
      if(unique(attributes(x)$SPLIT_FILE != F)){        
        t.one[[i]]$n  <- tinput[,length(na.omit(get(variables[[i]]))),by=splitter]$V1
        t.one[[i]]$mean <- tinput[,mean(na.omit(get(variables[[i]]))),by=splitter]$V1
        t.one[[i]]$sd <- tinput[,sd(na.omit(get(variables[[i]]))),by=splitter]$V1
        t.one[[i]]$semean <- (t.one[[i]]$sd /(sqrt(t.one[[i]]$observation))) 
        t.one[[i]]$diffmean <- t.one[[i]]$mean - testval
        t.one[[i]]$testval <- testval
        
        setnames(t.one[[i]],c("estimate","conf.int","diffmean","statistic","parameter","p-value"),c("upper confidence level of difference","lower confidence level of difference","mean difference","T","df","Sig"))
        levels <- t.one[[i]][,1:length(splitnames),with=F]
        for(j in 1:length(splitnames)){
          for(k in 1:length(attributes(levels[[j]])))
            levels[[j]][which(levels[[j]] %in% attributes(levels[[j]])$value.labels[k])] <- names(attributes(levels[[j]])$value.labels[k])  
        }
        
        t.one[[i]][,1:length(splitnames)] <- levels
        
        erg[[i]] <- list("Descriptive Statistics" = t.one[[i]][,c(1:5,13,12,6,7),with=F], "T-Test"=t.one[[i]][,c(1,2,8:11),with=F])
        
      }else{
        t.one[[i]]$observation  <- length(t.val[,get(variables[[i]])[pos]])
        t.one[[i]]$mean <- t.val[,mean(na.omit(get(variables[[i]])[pos]))]
        t.one[[i]]$sd <- t.val[,sd(na.omit(get(variables)[pos]))]
        t.one[[i]]$semean <- (t.one[[i]]$sd /(sqrt(t.one[[i]]$observation))) 
        
        desc <- cbind("n" = t.one[[i]]$observation,
                      "mean" =  t.one[[i]]$mean,
                      "sd" = t.one[[i]]$sd,
                      "semean" = t.one[[i]]$semean)
        
        out <- cbind("TestVal", testval,
                     "T" =  t.one[[i]]$statistic[[1]], 
                     "Sig" =  t.one[[i]]$p.value[[1]],
                     "df" =  t.one[[i]]$parameter[[1]],
                     "mean difference" = t.one[[i]]$mean - testval,
                     "lower confidence level of difference" = t.one[[i]]$conf.int[[1]],
                     "upper confidence level of difference" = t.one[[i]]$conf.int[[2]])
        
        if(length(erg)==0){
          t.out <- out
          t.desc <- desc
        } else{
          t.out <- rbind(t.out,out)
          t.desc <- rbind(t.desc,desc)
        }
        erg[[i]] <- list("Descriptive Statistics" = t.desc, "T-Test"=t.out)
      }
      names(erg)[[i]]  <- attributes(x[,variables[[i]]])$varname
    }
  }
  #Gruppiert
  if(t_test == "groups") {
    #    k <- 1
    for(i in 1:length(variables))   {
      if(missing == "include")     {
        grp <- which((x[,groupvar] == groups[1]) | (x[,groupvar] == groups[2]) & (logvec[[i]]%in%F))
      } else {
        grp <- which((x[,groupvar] == groups[1]) | (x[,groupvar] == groups[2]))
      }
      if(length(grp) < 4)
      {
        stop("not enough observations for a grouped t-test available, the minimum of observations are 4")
      }
      #Gruppenstatistik unabhaengig
      
      
      if(attributes(x)$SPLIT_FILE != F){
        
        
        message("split-file applied on independent 2-group t-test is not implemented yet")
        
        #         
        #         # get the group indicators
        #         pos <- unique(x[paste(unlist(str_split(splitter,pattern=",")))])
        #         # order indicators
        #         pos <- as.data.table(pos)
        #         setkeyv(x=pos,cols=colnames(pos))
        #         # indicate the group
        #         for(m in 1:nrow(pos)){  
        #           if(any(is.na(pos))){ #& k == 1)
        #             temp[[m]] <- x[which(is.na(x[,splitter])),]
        #           } else{
        #             temp[[m]] <- na.omit(x[eval(parse(text=paste(paste0("x$",splitnames),"==",pos[m],collapse=" & "))),])
        #           }
        #           # combine them        
        #           #         for(k in k:length(temp)){
        #           #           t.one[[i]]  <-      t.test(temp[[k]]$V7_2 ~ temp[[k]]$V5_kl2)  
        #           #         }
        #           
        #           
        #           data <- temp[[m]]
        #           data <- data[,c(variables,splitnames,groupvar)]
        #           
        #           for(l in 1:length(unique(data[,groupvar]))){
        #             if(length(unique(data[,groupvar])) == 1){
        #               grp <- unique(data[,groupvar])
        #               n <- length(data[,variables])
        #               mean <-mean(data[,variables])
        #               sd <-sd(data[,variables])
        #               semean <- sd /(sqrt(length(data[,variables])))
        #               if(grp == groups[1]){
        #                 out <- cbind(unique(data$V3[grp]),unique(data$V4[grp]),grp[1],n,mean,sd,semean)
        #                 out <- rbind(out,c(unique(data$V3[grp]),unique(data$V4[grp]),grp[2],0,-9999,-9999,-9999))
        #               } else{
        #                 out <- cbind(unique(data$V3[grp]),unique(data$V4[grp]),grp[2],"n"=0,"mean"=-9999,"sd"=-9999,"semean"=-9999)
        #                 out <- rbind(out,c(unique(data$V3[grp]),unique(data$V4[grp]),grp[1],n,mean,sd,semean))
        #               }
        #             } else{
        #               grp <- which(data[,groupvar] %in% groups[l])
        #               n <- length(na.omit(data[,variables][grp]))
        #               mean <-mean(data[,variables][grp])
        #               sd <-sd(data[,variables][grp])
        #               semean <- sd /(sqrt(length(data[,variables][grp])))
        #               if(l == 1){
        #                 out <- cbind(unique(data$V3[grp]),unique(data$V4[grp]),groups[l],n,mean,sd,semean)  
        #               } else{
        #                 out <- rbind(out,c(unique(data$V3[grp]),unique(data$V4[grp]),grp[l],n,mean,sd,semean))  
        #               }
        #             }
        #           }
        #           t.group[[m]] <- out
        #         }
        #         for(m in 1:length(t.group)){
        #           if(!(is.element(-9999,t.group[[m]][,5])){
        #             meandiff <- t.group[[m]][1,5] - t.group[[m]][2,5]  
        #             t.group[[m]][2,6] / sqrt(3)
        #           }
        #           var(temp[[m]]$V7_2)
        #           
        #         }
        #         meandiff <- t.group[[m]][1,5] - t.group[[m]][2,5]
        #        
        #         
        
      } else{
        #t.val[[i]] <- t.test(t.val[[i]][pos] ~ x[,groupvar][pos],var.equal=T,conf.level=criteria)
        t.one[[i]] <- t.test(t.val[[i]][grp] ~  x[,groupvar][grp]  ,var.equal=F,conf.level=criteria)
        t.one[[i]]$data.name  <- paste(attr(t.val[[i]],"variable.label")[1],"by", attr(x[,groupvar],"variable.label")[1])
        
        t.one[[i]]$observation  <- list(length(na.omit(t.val[[i]][which(x[,groupvar] %in% 1)])),length(na.omit(t.val[[i]][which(x[,groupvar] %in% 2)])))
        t.one[[i]]$mean <- list(mean(na.omit(t.val[[i]][which(x[,groupvar] %in% 1)])),mean(na.omit(t.val[[i]][which(x[,groupvar] %in% 2)])))
        t.one[[i]]$sd <- list(sd(na.omit(t.val[[i]][which(x[,groupvar] %in% 1)])),sd(na.omit(t.val[[i]][which(x[,groupvar] %in% 2)])))
        t.one[[i]]$semean <- list(t.one[[i]]$sd[[1]] /(sqrt(t.one[[i]]$observation[[1]])),t.one[[i]]$sd[[2]] /(sqrt(t.one[[i]]$observation[[2]])))    
      }
      
      
      #Stichprobenbstatistik
      
      t.group[[i]] <- leveneTest(t.val[[i]][grp], g = x[,groupvar][grp], center="mean")
      #t.group[[i]]$data.name <- paste(attr(t.val[[i]],"variable.label")[1],"by", attr(x[,groupvar],"variable.label")[1])
      t.group[[i]]$names <- list(names(which(attr(x[,groupvar],"value.labels") == groups[[1]])),names(which(attr(x[,groupvar],"value.labels") == groups[[2]])))         
      
      t.cor[[i]] <- anova(lm(t.val[[i]]~1))
      
      myt[[i]] <- list("Gruppe1" = list("n" = t.one[[i]]$observation[[1]],
                                        "mean" =  t.one[[i]]$mean[[1]],
                                        "sd" = t.one[[i]]$sd[[1]],
                                        "semean" = t.one[[i]]$semean[[1]]),
                       "Gruppe2" = list("n" = t.one[[i]]$observation[[2]],
                                        "mean" =  t.one[[i]]$mean[[2]],
                                        "sd" = t.one[[i]]$sd[[2]],
                                        "semean" = t.one[[i]]$semean[[2]]))
      names(myt[[i]]) <- t.group[[i]]$names
      
      t.out <- list("T-Value" =  t.one[[i]]$statistic[[1]], 
                    "Significance Level" =  t.one[[i]]$p.value, 
                    "df" =  t.one[[i]]$parameter[[1]], 
                    "Difference in Mean"= t.one[[i]]$estimate[1][[1]]-t.one[[i]]$estimate[2][[1]])
      
      f.out <- list("F-Value" = t.group[[i]][[2]][1],
                    "Significance Level" =t.group[[i]][[3]][1],
                    "Sum Sq" = t.cor[[i]][[2]][1],
                    "Mean Sq" = t.cor[[i]][[3]][1])
      #        
      #      erg[[i]] <- list("descriptive" =myt[[i]],
      #                       "t.test" =t.out,
      #                       "anova" =f.out)
      
      erg[[i]] <- list(t.one[[i]])
      names(erg[[i]])  <- t.one[[i]]$data.name
      
    }
  }
  #pairs
  
  if(t_test == "pairs" && is.null(withvars)) {
    if(attributes(x)$SPLIT_FILE != F) {
      message("split-file applied on paired t-test is not implemented yet")  
    }   
    
    k <- 1
    for(i in 1:(length(variables)-1))   {
      for(j in 2:length(variables))     {
        if(missing == "listwise")       {
          logicalvec <- complete.cases(x[,variables])
        } else {
          temp <- c(logvec[i],logvec[j])
          logicalvec <- temp[[1]] == temp[[2]]         
        }     
        if(j>i){ 
          pos <- which(logicalvec%in%T)
          t.one[[k]] <- t.test(t.val[[i]][pos],t.val[[j]][pos],paired=T,conf.level=criteria)
          t.one[[k]]$data.name  <- paste(attr(t.val[[i]],"variable.label")[1],"with", attr(t.val[[j]],"variable.label")[1])
          #t.one[[k]]$data.name  <- list(attr(x[,variables[i]],"variable.label")[1],attr(t.val[[j]],"variable.label")[1])
          
          ###Statistiken
          
          t.one[[k]]$observation <- c(length(t.val[[i]][pos]),length(t.val[[j]][pos]))
          t.one[[k]]$mean <- c(mean(na.omit(t.val[[i]][pos])),mean(na.omit(t.val[[j]][pos])))
          t.one[[k]]$sd <- c(sd(na.omit(t.val[[i]][pos])),sd(na.omit(t.val[[j]][pos])))
          t.one[[k]]$semean <- c(t.one[[i]]$sd[1] /(sqrt(t.one[[i]]$observation[1])),t.one[[i]]$sd[2] /(sqrt(t.one[[i]]$observation[2])))
          
          ####Korrelationen
          
          t.cor[[k]] <-cor.test(na.omit(t.val[[i]][pos]),na.omit(t.val[[j]][pos]))
          
          myt[[k]] <- list("Gruppe1" = list("n" = t.one[[k]]$observation[[1]],
                                            "mean" =  t.one[[k]]$mean[[1]],
                                            "sd" = t.one[[k]]$sd[[1]],
                                            "semean" = t.one[[k]]$semean[[1]]),
                           "Gruppe2" = list("n" = t.one[[k]]$observation[[2]],
                                            "mean" =  t.one[[k]]$mean[[2]],
                                            "sd" = t.one[[k]]$sd[[2]],
                                            "semean" = t.one[[k]]$semean[[2]]))
          names(myt[[k]]) <-  t.one[[k]]$data.name
          
          t.cor <- list("Pair" = k,
                        "N" = t.one[[k]]$observation[[1]],
                        "correlation" = t.cor[[k]]$estimate[[1]],
                        "sig" = t.cor[[k]]$p.value)
          
          t.out <- list("T-Value" =  t.one[[k]]$statistic[[1]], 
                        "sig" =  t.one[[k]]$p.value, 
                        "df" =  t.one[[k]]$parameter[[1]])
          #           erg[[k]] <- list(myt[[k]],
          #                            "correlation" = t.cor,
          #                            "t.test" =t.out)
          
          erg[[k]] <- list(t.one[[k]])
          names(erg[[k]])  <- t.one[[k]]$data.name
          k <- k+1
        }
      }
    }
  }
  if(t_test == "pairs" &&  !is.null(withvars) && paired == F) {
    if(attributes(x)$SPLIT_FILE != F) {
      message("split-file applied on paired t-test is not implemented yet")  
    }
    
    k <- 1
    for(i in 1:(length(variables)))   {
      for(j in 1:length(withvars))     {
        
        if(missing == "listwise")       {
          temp <- c(t.val,t.with)
          logvec <- complete.cases(temp)
          pos <- which(logvec%in%T)
        }
        if(missing == "include")       {
          temp <- c(logvec[i],logvec_withvars[j])
          logicalvec <- temp[[1]] == temp[[2]]
          pos <- which(logicalvec%in%T)
        } 
        if(missing == "analysis")       {
          pos <- which(logvec[[k]]%in%F)
        }
        t.one[[k]] <- t.test(t.val[[i]][pos],t.with[[j]][pos],paired=T,conf.level=criteria)
        t.one[[k]]$data.name  <- paste(attr(t.val[[i]],"variable.label")[1],"with", attr(t.with[[j]],"variable.label")[1])
        #t.one[[k]]$data.name  <- list(attr(x[,variables[i]],"variable.label")[1],attr(x[,withvars[j]],"variable.label")[1])
        
        ###Statistiken
        
        t.one[[k]]$observation <- c(length(t.val[[i]][pos]),length(t.with[[j]][pos]))
        t.one[[k]]$mean <- c(mean(na.omit(t.val[[i]][pos])),mean(na.omit(t.with[[j]][pos])))
        t.one[[k]]$sd <- c(sd(na.omit(t.val[[i]][pos])),sd(na.omit(t.with[[j]][pos])))
        t.one[[k]]$semean <- c(t.one[[i]]$sd[1] /(sqrt(t.one[[i]]$observation[1])),t.one[[i]]$sd[2] /(sqrt(t.one[[i]]$observation[2])))
        
        t.cor[[k]] <-cor.test(t.val[[i]][pos],t.with[[j]][pos])
        
        myt[[k]] <- list("Gruppe1" = list("n" = t.one[[k]]$observation[[1]],
                                          "mean" =  t.one[[k]]$mean[[1]],
                                          "sd" = t.one[[k]]$sd[[1]],
                                          "semean" = t.one[[k]]$semean[[1]]),
                         "Gruppe2" = list("n" = t.one[[k]]$observation[[2]],
                                          "mean" =  t.one[[k]]$mean[[2]],
                                          "sd" = t.one[[k]]$sd[[2]],
                                          "semean" = t.one[[k]]$semean[[2]]))
        names(myt[[k]]) <-  t.one[[k]]$data.name
        
        t.cor <- list("Pair" = k,
                      "N" = t.one[[k]]$observation[[1]],
                      "correlation" = t.cor[[k]]$estimate[[1]],
                      "sig" = t.cor[[k]]$p.value)
        
        t.out <- list("T-Value" =  t.one[[k]]$statistic[[1]], 
                      "sig" =  t.one[[k]]$p.value, 
                      "df" =  t.one[[k]]$parameter[[1]])
        
        #           erg[[k]] <- list(myt[[k]],
        #                            "correlation" = t.cor,
        #                            "t.test" =t.out)
        
      }
      erg[[k]] <- list(t.one[[k]])
      names(erg[[k]])  <- t.one[[k]]$data.name
      k <- k+1
    }
  }
  
  if(t_test == "pairs" &&  !is.null(withvars) && paired == T)
  {
    if(attributes(x)$SPLIT_FILE != F) {
      message("split-file applied on paired t-test is not implemented yet")  
    }
    k <- 1
    if(missing == "listwise")       {
      temp <- c(t.val,t.with)
      logvec <- complete.cases(temp)
      pos <- which(logvec%in%T)
    }
    if(missing == "include")       {
      temp <- c(logvec[i],logvec_withvars[j])
      logicalvec <- temp[[1]] == temp[[2]]
      pos <- which(logicalvec%in%T)
    } 
    if(missing == "analysis")       {
      pos <- which(logvec[[k]]%in%F)
    }
    if(length(t.val) == length(t.with))
    {
      for(i in 1:length(variables))
      {
        
        t.one[[i]] <- t.test(t.val[[i]][pos],t.with[[i]][pos],paired=T,conf.level=criteria)
        t.one[[i]]$data.name  <- paste(attr(t.val[[i]],"variable.label")[1],"with", attr(t.with[[i]],"variable.label")[1])
        #t.one[[i]]$data.name  <- list(attr(x[,variables[i]],"variable.label")[1],attr(x[,withvars[i]],"variable.label")[1])
        
        ###Statistiken
        
        t.one[[i]]$observation <- c(length(t.val[[i]][pos]),length(t.with[[i]][pos]))
        t.one[[i]]$mean <- c(mean(na.omit(t.val[[i]][pos])),mean(na.omit(t.with[[i]][pos])))
        t.one[[i]]$sd <- c(sd(na.omit(t.val[[i]][pos])),sd(na.omit(t.with[[i]][pos])))
        t.one[[i]]$semean <- c(t.one[[i]]$sd[1] /(sqrt(t.one[[i]]$observation[1])),t.one[[i]]$sd[2] /(sqrt(t.one[[i]]$observation[2])))
        
        t.cor[[i]] <-cor.test(t.val[[i]][pos],t.with[[i]][pos])
        
        myt[[i]] <- list("Gruppe1" = list("n" = t.one[[i]]$observation[[1]],
                                          "mean" =  t.one[[i]]$mean[[1]],
                                          "sd" = t.one[[i]]$sd[[1]],
                                          "semean" = t.one[[i]]$semean[[1]]),
                         "Gruppe2" = list("n" = t.one[[i]]$observation[[2]],
                                          "mean" =  t.one[[i]]$mean[[2]],
                                          "sd" = t.one[[i]]$sd[[2]],
                                          "semean" = t.one[[i]]$semean[[2]]))
        names(myt[[i]]) <-  t.one[[i]]$data.name
        
        t.cor <- list("Pair" = i,
                      "N" = t.one[[i]]$observation[[1]],
                      "correlation" = t.cor[[i]]$estimate[[1]],
                      "sig" = t.cor[[i]]$p.value)
        
        t.out <- list("T-Value" =  t.one[[i]]$statistic[[1]], 
                      "sig" =  t.one[[i]]$p.value, 
                      "df" =  t.one[[i]]$parameter[[1]])
        
        #           erg[[i]] <- list(myt[[i]],
        #                            "correlation" = t.cor,
        # 
        erg[[i]] <- list(t.one[[i]])
        names(erg[[i]])  <- t.one[[i]]$data.name
        k <- k+1
      }
    } else {
      stop("No the same amount of withvars and variables")
    }
  }
  
  if(!(is.xpssFrame(x))){
    attributes(x)$SPLIT_FILE <- NULL
  }
  
  options(warn=0)
  return(erg)
}
