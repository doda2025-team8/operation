# Deployment
### Team 8
Yanzhi Chen  
Hendrik Lambert  
Vincent Ruijgrok  
Yuchen Sun  
Andriana Tzanidou  
Horia Zaharia  

## Table of Contents

- [Introduction](#introduction)
- [Architecture Overview](#architecture-overview)
- [Deployment Structure](#deployment-structure) 
- [Data Flow of Requests](#data-flow-of-requests)
- [Quick Reference: How to Access the Application](#quick-reference-how-to-access-the-application)


## Introduction 
The goal of this document is to describe the deployment structure  and deployment data flow of the SMS Checker app. The app is deployed in Kubernetes with Istio service mesh. Additionally, it implements a canary release to a small fraction of its users (90/10 traffic split) with sticky sessions and an additional use case, a Shadow Launch, which mirrors traffic to a new model version. An experiment is run to evaluate a canary release of the app to a small fraction of its users which enables caching model responses to improve latency. This document presents an overview of the deployment architecture, provides information on all deployed components and their relationships, a description of the request flow through the deployed cluster and a quick reference guide on how to access the application.

## Architecture Overview 
<!--Add a high level diagram of the architecture and a general description. (Idea: Add kiali diagram)-->

## Deployment Structure
<!--Include all deployed resource types and their relations.
It is unnecessary to include all details for each CRD, but effects and relations should become clear. Mention about canary release(90/10) split, experiment (not in detail has each own doc), additional use case-->

## Data Flow of Requests
<!--Describe the flow of incoming requests to the cluster. Show and elaborate the flow of requests in the cluster, including the
dynamic traffic routing in your experiment. 
• Which path does a typical request take through your deployment?
• Where is the 90/10 split configured? Where is the routing decision taken?
Add data flow diagrams-->

## Quick Reference: How to Access the Application
<!--Here there is a list/table of all hostname, paths, ports, headers.. that are necessary to access the application-->

