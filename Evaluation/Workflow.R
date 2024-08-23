#' @title createQualificationReport
#' @description Run a qualification workflow to create a qualification report.
#' @param qualificationRunnerFolder Folder where QualificationRunner.exe is located
#' @param pkSimPortableFolder Folder where PK-Sim is located.
#' If not specified, installation path will be read from the registry (available only in case of full **non-portable** installation).
#' This option is **MANDATORY** for the portable version of PK-Sim.
#' @param createWordReport Logical defining if a `docx` version of the report should also be created.
#' Note that `pandoc` installation is required for this feature
#' [https://github.com/Open-Systems-Pharmacology/OSPSuite.ReportingEngine/wiki/Installing-pandoc]
#' @param maxSimulationsPerCore An integer that set the maximimum number of simulations per core
#' @param versionInfo A `QualificationVersionInfo` object to update title page with Qualification Version Information
#' @param wordConversionTemplate File name of docx template document passed to Pandoc for the conversion of the md report into docx
#' Default template is available using `system.file("extdata", "reference.docx", package = "ospsuite.reportingengine")`
#' @examples
#' # Create a Qualification Report without any option and running v9.1.1 of Qualification Runner
#' createQualificationReport("C:/Software/QualificationRunner9.1.1")
#' 
#' # Create a Qualification Report and turn of the creation of a doc version
#' createQualificationReport("C:/Software/QualificationRunner9.1.1", createWordReport = FALSE)
#' 
#' # Create a Qualification Report and set the number of simulations to be run per core
#' createQualificationReport("C:/Software/QualificationRunner9.1.1", maxSimulationsPerCore = 8)
#' 
#' # Create a Qualification Report and update Qualification Version Information on title page
#' versionInfo <- QualificationVersionInfo$new("1.1", "2.2","3.3")
#' createQualificationReport("C:/Software/QualificationRunner9.1.1", versionInfo = versionInfo)
#' 
createQualificationReport <- function(qualificationRunnerFolder,
                                      pkSimPortableFolder = NULL,
                                      createWordReport = TRUE,
                                      maxSimulationsPerCore = NULL,
                                      versionInfo = NULL,
                                      wordConversionTemplate = NULL) {
  library(ospsuite.reportingengine)

  #-------- STEP 1: Define workflow settings --------#
  #' replace `workingDirectory` and `qualificationPlanName` with your paths
  #'
  #' The directories are assumed the following structure
  #' `workingDirectory`
  #'   - `input`
  #'     - `qualificationPlanName`
  #'   - `re_input`
  #'     - `configurationPlanFile`
  #'   - `re_output`
  #'     - `report`
  #'
  #' In case your folder structure is different from assumed above,
  #' the paths below must be adjusted as well:
  #' - `qualificationPlanFile`: path of qualification plan file run by Qualification Runner
  #' - `reInputFolder`: input path for the Reporting engine
  #' - `reOutputFolder`: outputs of the Reporting Engine will be created here
  #' - `reportName`:  path of final report
  #'
  #' **Template parameters to be replaced below**

  #' `workingDirectory`: current directory is used as default working directory
  workingDirectory <- getwd()

  qualificationPlanName <- "evaluation_plan.json"
  qualificationPlanFile <- file.path(workingDirectory, "Input", qualificationPlanName)

  #' The default outputs of qualification runner should be generated under `<workingDirectory>/re_input`
  reInputFolder <- file.path(workingDirectory, "re_input")
  #' The default outputs or RE should be generated under `<workingDirectory>/re_output`
  reOutputFolder <- file.path(workingDirectory, "re_output")

  #' Configuration Plan created from the Qualification Plan by the Qualification Runner
  configurationPlanName <- "report-configuration-plan"
  configurationPlanFile <- file.path(reInputFolder, paste0(configurationPlanName, ".json"))

  #' Option to record the time require to run the workflow.
  #' The timer will calculate calculation time form internal `Sys.time` function
  recordWorkflowTime <- TRUE

  #' Set watermark that will appear in all generated plots
  #' Default is no watermark. `Label` objects from `tlf` package can be used to specifiy watermark font.
  watermark <- ""

  #' If not set, report created will be named `report.md` and located in the worflow folder namely `reOutputFolder`
  reportFolder <- file.path(workingDirectory, "report")
  reportPath <- file.path(reportFolder, "report.md")
  
  #----- Optional parameters for the Qualification Runner -----#
  #' If not null, `logFile` is passed internally via the `-l` option
  logFile <- NULL
  #' If not null, `logLevel` is passed internally via the `--logLevel` option
  logLevel <- NULL
  #' If `overwrite` is set to true, eventual results from the previous run of the QualiRunner/RE will be removed first
  overwrite <- TRUE

  #-------- STEP 2: Qualification Runner  --------#
  #' Start timer to track time if option `recordWorkflowTime` is set to TRUE
  if (recordWorkflowTime) {
    tic <- as.numeric(Sys.time())
  }

  #' Start Qualification Runner to generate inputs for the reporting engine
  startQualificationRunner(
    qualificationRunnerFolder = qualificationRunnerFolder,
    qualificationPlanFile = qualificationPlanFile,
    outputFolder = reInputFolder,
    pkSimPortableFolder = pkSimPortableFolder,
    configurationPlanName = configurationPlanName,
    overwrite = overwrite,
    logFile = logFile,
    logLevel = logLevel
  )

  #' Print timer tracked time if option `recordWorkflowTime` is set to TRUE
  if (recordWorkflowTime) {
    toc <- as.numeric(Sys.time())
    print(paste0("Qualification Runner Duration: ", round((toc - tic) / 60, 1), " minutes"))
  }

  #-------- STEP 3: Run Qualification Workflow  --------#
  # If version info is provided update title page
  titlePageFile <- file.path(reInputFolder, "Intro/titlepage.md") 
  if(!is.null(versionInfo) & file.exists(titlePageFile)){
    adjustTitlePage(titlePageFile, qualificationVersionInfo = versionInfo)
  }
  
  #' Load `QualificationWorkflow` object from configuration plan
  workflow <- loadQualificationWorkflow(
    workflowFolder = reOutputFolder,
    configurationPlanFile = configurationPlanFile
  )

  #' Set the name of the final report
  workflow$reportFilePath <- reportPath
  workflow$createWordReport <- createWordReport
  workflow$wordConversionTemplate <- wordConversionTemplate

  #' Set watermark. If set, it will appear in all generated plots
  workflow$setWatermark(watermark)

  #' Set the maximimum number of simulations per core if defined
  if(!is.null(maxSimulationsPerCore)){
    workflow$simulate$settings$maxSimulationsPerCore <- maxSimulationsPerCore
  }
  
  #' Activate/Deactivate tasks of qualification workflow prior running
  # workflow$inactivateTasks("simulate")
  # workflow$inactivateTasks("calculatePKParameters")
  # workflow$inactivateTasks("plotTimeProfiles")
  # workflow$inactivateTasks("plotComparisonTimeProfile")
  # workflow$inactivateTasks("plotGOFMerged")
  # workflow$inactivateTasks("plotPKRatio")
  # workflow$inactivateTasks("plotDDIRatio")
  
  workflow$plotPKRatio$settings$units$C_max <- "ng/mL"
  
  #' Run the `QualificatitonWorklfow`
  workflow$runWorkflow()

  #' Print timer tracked time if option `recordWorkflowTime` is set to TRUE
  if (recordWorkflowTime) {
    toc <- as.numeric(Sys.time())
    print(paste0("Qualification Workflow Total Duration: ", round((toc - tic) / 60, 1), " minutes"))
  }
  return(invisible())
}
