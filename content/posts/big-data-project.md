---
date: "2025-06-09T10:36:50+02:00"
title: "Analyzing U.S. Air Flights with Apache Spark and Hadoop"
tags: ["big data", "spark", "hadoop", "university project", "data engineering"]
description: "A university project that explores large-scale flight data analysis using Apache Spark, Hadoop, and the U.S. DOT air travel dataset."
searchable: true
---

For my university course in **Big Data and Cloud Computing**, I developed a hands-on project to process and analyze U.S. domestic flight data using a big data pipeline built on **Apache Spark**, **Hadoop** and **Hive**.

📂 [Project Repository on GitHub](https://github.com/umbertocicciaa/air-flights-big-data-unical)

## ✈️ Project Overview

The dataset comes from the **U.S. Department of Transportation (DOT)** and includes over **20 years of flight records** across domestic U.S. routes. It contains rich details such as:

- Flight numbers, carriers, and tail numbers  
- Origin and destination airports  
- Scheduled and actual times  
- Delays and cancellations  

With millions of rows and numerous fields, the dataset is an ideal candidate for distributed processing.

## ⚙️ Technologies Used

- **Apache Spark (Scala API)** — For distributed processing and querying  
- **HDFS** — As the primary distributed file system for data storage  
- **Hive** - For datawarehousing flights
- **Docker Compose** — To setuo a local dev environment
- **K8s** - For the future deploy of the application

The infrastructure is designed to simulate a real-world Big data ecosystem on a developer machine.

## 🧠 Analysis Goals

The goal was to answer questions such as:

- Which U.S. airports are the busiest?
- What carriers experience the most delays?
- Which routes have the highest cancellation rates?
- Are there noticeable patterns in delays based on time of year?

We used **Spark DataFrames** and SQL for efficient querying and **Python** for ETL logic.

## 📊 Sample Insights

Here are just a few of the findings:

- **Hartsfield–Jackson Atlanta International Airport (ATL)** consistently ranks as the busiest hub.
- Certain routes exhibit **seasonal delay patterns**, especially in the Northeast during winter.
- Flights operated by low-cost carriers showed higher cancellation rates, likely due to tighter fleet logistics.

## 🎓 Educational Value

This project helped me solidify core big data concepts:

- Working with large-scale tabular data

- Tuning Spark jobs and understanding data shuffling and partitioning

- Managing multi-node workflows via YARN and HDFS

- Applying functional programming in Scala for clean and scalable ETL pipelines
