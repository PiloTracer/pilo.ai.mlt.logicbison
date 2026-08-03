# MLOps and Deployment

**Slug:** `mlops-and-deployment`
**Duration:** 4-6 weeks · 3 sessions/week
**Level:** Advanced
**Prerequisites:** `llm-engineering` (all modules)

## Audience
Learners who can build ML systems and want to productionize them. Common misconception: "MLOps is just DevOps for ML."

## Duration & Cadence
4-6 weeks, 3 sessions/week. Sessions: 90 min (infra setup + operations). Async: pipelines, monitoring config, incident drills.

## Outcomes
1. Set up experiment tracking with MLflow for reproducibility
2. Deploy an LLM service with FastAPI and Docker
3. Implement monitoring for drift, latency, and data quality
4. Build CI/CD pipelines for ML testing and deployment
5. Design batch and real-time inference patterns

## Modules

### Module 1: Experiment Tracking (Week 1-2)
**Objectives:** Make ML experiments reproducible and auditable.
**Content:** Tracking concepts (params, metrics, artifacts, lineage). MLflow (tracking server, experiments, model registry). W&B (projects, runs, sweeps). Reproducibility (seeds, environment capture, DVC).
**Lab:** Set up local MLflow server. Integrate into fine-tuning script: log hyperparams, loss, eval metrics, model artifacts. Compare two configs with structured experiment.
**Sources:** [MLflow](https://mlflow.org/docs/latest/index.html) · [W&B](https://docs.wandb.ai/) · [Made With ML](https://madewithml.com/#experiment-tracking) · [DVC](https://dvc.org/doc)
**Exit check:** Reproduce any experiment from MLflow tracking data within 30 minutes.

### Module 2: Model Serving (Week 2-3)
**Objectives:** Deploy models as reliable, scalable services.
**Content:** FastAPI (async, Pydantic validation, streaming, background tasks). Docker (multi-stage builds, GPU containers). Serving (TorchServe, vLLM, Triton). API design (REST, batching, rate limiting). Scaling (horizontal, load balancing, autoscaling).
**Lab:** FastAPI + vLLM service for fine-tuned LLM. Request validation, streaming tokens, health checks, Prometheus metrics. Dockerize and load test.
**Sources:** [FastAPI](https://fastapi.tiangolo.com/) · [vLLM Docker](https://docs.vllm.ai/en/latest/serving/deploying_with_docker.html) · [Full Stack DL](https://fullstackdeeplearning.com/course/2022/)
**Exit check:** Containerized service handling 10+ concurrent requests with <2s p95.

### Module 3: Monitoring (Week 3-4)
**Objectives:** Detect and respond to production ML failures.
**Content:** Drift detection (data drift, concept drift, degradation). Data quality (schema validation, distribution monitoring). Model performance (prediction distribution, calibration). Infra (latency percentiles, error rates, GPU util). Observability (Prometheus, Grafana, structured logging).
**Lab:** Grafana dashboard: inference latency, token throughput, error rates, input distribution shifts. Alerts for spikes. Simulate drift and detect it.
**Sources:** [Prometheus](https://prometheus.io/docs/) · [Grafana](https://grafana.com/docs/) · [Evidently AI](https://docs.evidentlyai.com/) · [MLOps Maturity Model](https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/mlops-maturity-model)
**Exit check:** Detect simulated drift within 5 minutes of occurrence.

### Module 4: CI/CD for ML (Week 4-5)
**Objectives:** Automate testing and deployment of ML systems.
**Content:** ML testing (data unit tests, model behavior tests, integration tests). CI (GitHub Actions, linting, type checking). Validation gates (perf thresholds, fairness, size limits). Deployment (blue-green, canary, shadow, rollback).
**Lab:** GitHub Actions pipeline: data validation, train, evaluate against quality gates, deploy to staging if gates pass. Rollback on failure.
**Sources:** [Made With ML — CI/CD](https://madewithml.com/#cicd) · [Full Stack DL](https://fullstackdeeplearning.com/course/2022/) · [GitHub Actions](https://docs.github.com/en/actions) · [Great Expectations](https://docs.greatexpectations.io/)
**Exit check:** Pipeline auto-validates, trains, gates, and deploys on push.

### Module 5: Production Patterns (Week 5-6)
**Objectives:** Design robust production architectures.
**Content:** Batch inference (scheduled jobs, large-scale, cost optimization). Streaming (real-time, Kafka, backpressure). Edge (ONNX Runtime, mobile, compression). Cost (spot instances, autoscaling, caching, distillation). Reliability (circuit breakers, fallbacks, disaster recovery).
**Lab:** Implement: (1) nightly batch inference pipeline, (2) streaming endpoint with backpressure and fallback to smaller model under load.
**Sources:** [Google MLOps](https://cloud.google.com/architecture/mlops-continuous-delivery-and-automation-pipelines) · [AWS ML Best Practices](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/) · [Full Stack DL](https://fullstackdeeplearning.com/course/2022/)
**Exit check:** Both patterns handle failure scenarios with documented fallbacks.

## Assessment

| Criterion | Pass condition |
|-----------|----------------|
| Experiment tracking | Reproduce experiment from tracking data in <30 min |
| Model serving | 10+ concurrent requests, <2s p95 latency |
| Monitoring | Detect simulated drift in <5 minutes |
| CI/CD | Pipeline validates, trains, gates, deploys on push |
| Production patterns | Batch + streaming handle failures gracefully |

## Exit Criteria
All exit checks met. Artifacts in `.training.mlt/`: MLflow config, FastAPI service, Grafana dashboard, CI/CD pipeline, architecture docs.
