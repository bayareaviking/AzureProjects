# Course Outline

## Module 1 - Voiceover

This is not a "real" module, but represents the brief overview of the module you can view from the courses page.

## Module 2 - Introduction

Learning Objectives

* Receive an overview of the course
* Learn the tools and environment needed to complete the demos in the course.

Demo Description

There is no demo for this module

## Module 3 - Exploring User Analytics

Learning Objectives

* See how to perform User Analysis using KQL
* See the following commands:
  * [sliding_window_counts](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/query/session-count-plugin)
  * [active_users_count](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/query/active-users-count-plugin)
  * [activity_count_metrics](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/query/activity-counts-metrics-plugin)
  * [activity_metrics](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/query/activity-metrics-plugin)
  * [activity_engagement](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/query/activity-engagement-plugin)

Demo Sources

* [User Analytics - Azure Data Explorer](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/query/useranalytics)

Demo Description

Students will see how to use the built-in functions to analyze user activity. They will see examples of performing user counts as well as user activity over a time period.

## Module 4 - Executing Geographic Analysis

Learning Objectives

* Learn the Geo-spatial Analytics functions in KQL

Demo Sources

[Sample queries for geospatial analytics on Azure Data Explorer](https://gist.github.com/cosh/df218b432f07c9382dd25a950aa2bfb9)

* [Azure Data Explorer extends geospatial functionality](https://azure.microsoft.com/en-us/updates/adx-geo-updates/)
* [GeoTraining](https://gist.github.com/cosh/5b46b79529461240112ba392bd0e8622)
* [geo_point_to_geohash() - Azure Data Explorer](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/query/geo-point-to-geohash-function)
* [Geospatial functions support in Azure Data Explorer](https://techcommunity.microsoft.com/t5/azure-data-explorer/just-shipped-geospatial-functions-support-in-azure-data-explorer/ba-p/990724)

Demo Description

Students will see how to use the geographic clustering functions to determine activity within a geographic boundary.

## Module 5 - Performing Diagnostic and Root Cause Analysis

Learning Objectives

* Diagnosis and Root Cause Analysis

Demo Sources

* [Azure/azure-kusto-analytics-lib](https://github.com/Azure/azure-kusto-analytics-lib/blob/master/ML/queries/Clustering-Plugins-Tutorial.csl)
* [Machine learning capability in Azure Data Explorer](https://docs.microsoft.com/en-us/azure/data-explorer/machine-learning-clustering)

Demo Description

Students will see how to use built-in machine learning to diagnose issues and perform root cause analysis.

## Module 6 - Time Series Analysis 1 – Creation and Core Functions

Learning Objectives

* Time series creation and native functions

Demo Sources

* [Analyze time series data using Azure Data Explorer](https://docs.microsoft.com/en-us/azure/data-explorer/time-series-analysis)
* [Azure/azure-kusto-analytics-lib](https://github.com/Azure/azure-kusto-analytics-lib/blob/master/Series/queries/Time-Series-Analysis-Tutorial.csl)

Demo Description
Students will be introduced to the basic time series functions to perform data analysis.Students will then see how to chain core functions to build time series analysis pipeline that can be applied to thousands of time series in near real time.

## Module 7 - Time Series Analysis 2 - Anomaly Detection and Forecasting

Learning Objectives

* Time Series based Anomaly Detection and Forecasting

Demo Sources

* [Time series anomaly detection & forecasting in Azure Data Explorer](https://docs.microsoft.com/en-us/azure/data-explorer/anomaly-detection)
* [Azure/azure-kusto-analytics-lib](https://github.com/Azure/azure-kusto-analytics-lib/blob/master/Series/queries/Time-Series-Analysis-Tutorial.csl)

Demo Description

Students will see how to perform anomaly detection along with forecasting over time series

## Module 8 - Extensibility Using Inline Python / R

Learning Objectives

* Learn that ADX has the ability to embed both Python and R code within a Kusto query.
* See how to incorporate Python code into Kusto queries
* Execute the Python code as part of query execution
* See how to do Machine Learning or Time Series Analysis using embedded Python code

Demo Sources

* [Python plugin - Azure Data Explorer](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/query/pythonplugin?pivots=azuredataexplorer)
* [Azure/azure-kusto-analytics-lib](https://github.com/Azure/azure-kusto-analytics-lib/blob/master/ML/queries/Python-Plugin-Tutorial.csl)
* [Debug Kusto query language inline Python using VS Code - Azure Data Explorer](https://docs.microsoft.com/en-us/azure/data-explorer/debug-inline-python)
* [R plugin (Preview) - Azure Data Explorer](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/query/rplugin?pivots=azuredataexplorer)

Demo Description

Students will see how to use Python code within their KQL code.

## Module 9 - Summary

Learning Objectives

* Students will receive a summary of the course

Demo Description

This module has no demos.
