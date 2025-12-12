# Continuous Experimentation

This document describes the continuous experimentation setup for the SMS Checker application, including the experiment design, hypothesis, metrics, and decision process.

## Experiment Overview

We are conducting a canary release experiment to evaluate the impact of **response caching** in the `app-service` component. The experiment compares two versions:

| Version | Name | Configuration | Description |
|---------|------|---------------|-------------|
| v1 | Stable | `ENABLE_CACHE=false` | Every SMS prediction request calls the model-service |
| v2 | Canary | `ENABLE_CACHE=true` | Repeated SMS messages return cached predictions |

## Changes Compared to Base Design

The canary version (v2) introduces an in-memory cache in `app-service` that stores prediction results:

1. **Cache Implementation**: A `ConcurrentHashMap` stores SMS text → prediction result mappings
2. **Cache Lookup**: Before calling model-service, the system checks if the SMS text exists in cache
3. **Cache Population**: After receiving a prediction from model-service, the result is stored in cache
4. **Cache Benefit**: Subsequent requests with identical SMS text return instantly without network calls

### Code Changes

```java
// v2 behavior: Check cache before calling model-service
if (cacheEnabled && predictionCache.containsKey(sms.sms)) {
    sms.result = predictionCache.get(sms.sms);  // Cache hit - instant response
    cacheHitsCounter.increment();
} else {
    sms.result = getPrediction(sms);  // Cache miss - call model-service
    if (cacheEnabled) {
        predictionCache.put(sms.sms, sms.result);  // Store for future requests
    }
}
```

## Hypothesis

> **Enabling response caching in app-service will reduce average latency for repeated SMS predictions by at least 50%, without negatively impacting prediction accuracy.**

This hypothesis is falsifiable:
- **Accept if**: Canary average latency < 50% of Stable average latency for repeated requests
- **Reject if**: Canary latency is not significantly lower, or errors increase

## Metrics

The following custom metrics are exposed by `app-service` at `/actuator/prometheus` and collected by Prometheus:

| Metric | Type | Description | Labels |
|--------|------|-------------|--------|
| `app_sms_requests_total` | Counter | Total number of SMS prediction requests | `version` |
| `app_sms_latency_seconds` | Histogram | Time taken to process SMS prediction | `version` |
| `app_sms_active_requests` | Gauge | Currently processing requests | `version` |
| `app_cache_hits_total` | Counter | Number of cache hits (v2 only) | `version` |
| `app_cache_misses_total` | Counter | Number of cache misses (v2 only) | `version` |
| `app_cache_size` | Gauge | Current cache entries (v2 only) | `version` |

The `version` label (`stable` or `canary`) enables filtering and comparison between versions in Grafana.

## Traffic Routing

Traffic is split between versions using Istio:

| Configuration | Value |
|---------------|-------|
| Traffic Split | 90% stable / 10% canary |
| Routing Method | Istio VirtualService + DestinationRules |
| Session Affinity | Sticky sessions via `canary-user` cookie |
| Version Consistency | Ensured via sourceLabels matching |

### Routing Rules

```yaml
# 90/10 split for /sms endpoint
- match:
    - uri:
        prefix: "/sms"
  route:
    - destination:
        host: app-service
        subset: v1
      weight: 90
    - destination:
        host: app-service
        subset: v2
      weight: 10
```

## Decision Process

### Data Collection

The Grafana dashboard "Canary Experiment Dashboard" provides real-time visualization of:

1. **Request Rate by Version**: Time series showing requests/second for each version
2. **Traffic Split**: Pie chart confirming the 90/10 distribution
3. **Average Latency Comparison**: Side-by-side latency trends
4. **P95 Latency Comparison**: Tail latency for both versions
5. **Current Latency**: Real-time latency comparison (stat panels)

### Decision Criteria

| Criterion | Threshold | Action |
|-----------|-----------|--------|
| Canary latency ≤ 50% of Stable latency | For repeated requests | ✅ Promote canary |
| Canary latency > Stable latency | Sustained over 5 minutes | ❌ Rollback |
| Error rate increase | > 1% above stable | ❌ Rollback |
| Cache hit ratio | > 80% for repeated messages | ✅ Cache working effectively |

### Evaluation Process

1. **Collect baseline**: Run experiment for minimum 30 minutes with mixed traffic
2. **Analyze latency**: Compare average and P95 latency between versions
3. **Check cache effectiveness**: Monitor cache hit/miss ratio on canary
4. **Verify correctness**: Ensure cached responses match fresh predictions
5. **Make decision**: Based on criteria above, promote or rollback

## Experiment Results

### Dashboard Screenshot

![Canary Experiment Dashboard](./images/experiment-dashboard.png)

### Observed Results

| Metric | Stable (v1) | Canary (v2) | Improvement |
|--------|-------------|-------------|-------------|
| Total Requests | 253 | 22 | N/A (90/10 split) |
| Average Latency | 13.7ms | 516μs | **26x faster** |
| Traffic Distribution | ~92% | ~8% | As configured |

### Analysis

1. **Cache Hit Benefit**: The canary version shows dramatically lower latency (516μs vs 13.7ms) for repeated requests, demonstrating effective caching.

2. **Traffic Split**: The observed ~92/8 split closely matches the configured 90/10 ratio.

3. **Hypothesis Validation**: The canary latency (516μs) is significantly less than 50% of stable latency (13.7ms), **confirming our hypothesis**.

### Decision

**✅ PROMOTE CANARY**

The experiment demonstrates that response caching provides substantial latency improvements (26x faster for cached requests) without introducing errors. The canary version should be promoted to handle 100% of traffic.

## How the Dashboard Supports Decision-Making

The Grafana dashboard enables data-driven decisions by:

1. **Real-time Monitoring**: Auto-refresh every 10 seconds shows current system state
2. **Version Comparison**: Side-by-side panels make differences immediately visible
3. **Historical Trends**: Time series charts reveal patterns and anomalies
4. **Clear Thresholds**: Color-coded stat panels highlight when latency exceeds acceptable limits
5. **Decision Guidance**: Built-in "Promotion Criteria" panel reminds operators of accept/reject rules

The dashboard transforms raw Prometheus metrics into actionable insights, enabling quick and confident release decisions.