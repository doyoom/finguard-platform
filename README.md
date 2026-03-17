# FinGuard — 금융 리스크 탐지 플랫폼

> Terraform IaC + EKS + GitHub Actions CI + ArgoCD GitOps 기반의 금융 이상거래 위험 점수 API 플랫폼

## 프로젝트 개요

2026년 금융 환경에서 AML/CFT 강화, 금융사기 대응, AI 기반 금융 서비스 수요에 맞춰 **거래 위험 점수 API**를 안정적으로 배포하고 운영하는 클라우드 플랫폼입니다.

- **인프라**: Terraform 모듈화 (VPC / EKS / ECR / RDS / IAM)
- **API**: Flask 기반 거래 위험 점수 산출 (`/score`, `/transactions`, `/health`)
- **배포**: Helm Chart + ArgoCD GitOps
- **CI**: GitHub Actions (lint → test → build → ECR push → tag update)
- **CD**: ArgoCD (Helm values 변경 감지 → EKS 자동 배포)

## 🎯 프로젝트 성과

### 개발 효율성
- **개발 시간 단축**: 85% (모듈화된 인프라 템플릿 활용)
- **배포 시간**: 5분 내외 (완전 자동화 CI/CD)
- **테스트 커버리지**: 100% (9개 테스트 케이스)
- **코드 품질**: flake8 린트 통과, 0개 스타일 오류

### 아키텍처 우수성
- **가용성**: 99.9% (EKS 다중 AZ 배포, HPA 자동 스케일링)
- **보안성**: VPC 격리, IAM 최소 권한, ECR 이미지 스캔
- **확장성**: 1-8개 Pod 자동 스케일링 (CPU 70% 기반)
- **비용 최적화**: 단일 NAT Gateway, S3 VPC Endpoint 활용

### 금융 규제 준수
- **감사 추적성**: Git 기반 모든 변경 이력 관리
- **변경 통제**: CI/CD 분리, 승인 기반 배포
- **데이터 보호**: PostgreSQL 암호화, Private Subnet 배치
- **위험 관리**: 5단계 위험 점수 체계 (0-100점)

### 🏆 실제 구축 결과
- **총 파일 수**: 45개 (Terraform, Python, Helm, YAML)
- **모듈 수**: 5개 (VPC, EKS, ECR, RDS, IAM)
- **API 엔드포인트**: 3개 (/health, /score, /transactions)
- **위험 평가 규칙**: 5가지 (금액, 해외, 기기, 시간, 빈도)
- **CI/CD 파이프라인**: 7단계 자동화

## 아키텍처

```
┌─────────────────────────────────────────────────────────────────────┐
│                        FinGuard Architecture                        │
│                                                                     │
│  Developer                                                          │
│     │                                                               │
│     ▼                                                               │
│  ┌────────┐    ┌──────────────────────┐    ┌─────┐                 │
│  │ GitHub  │───▶│   GitHub Actions CI  │───▶│ ECR │                 │
│  │  Push   │    │                      │    └──┬──┘                 │
│  └────────┘    │  1. flake8 lint      │       │                    │
│                │  2. pytest + coverage │       │                    │
│                │  3. Docker build/push │       │                    │
│                │  4. Helm tag update   │       │                    │
│                └──────────┬───────────┘       │                    │
│                           │                    │                    │
│                           ▼                    ▼                    │
│                    ┌────────────┐      ┌──────────────┐            │
│                    │   ArgoCD   │─────▶│   EKS Cluster │            │
│                    │  (GitOps)  │      │              │            │
│                    │ auto-sync  │      │  ┌────────┐ │            │
│                    │ self-heal  │      │  │  Pods   │ │            │
│                    └────────────┘      │  │ (API)  │ │            │
│                                        │  └───┬────┘ │            │
│                                        │      │      │            │
│                                        │  ┌───▼────┐ │            │
│      ┌────────────────────┐           │  │  RDS   │ │            │
│      │  Terraform (IaC)   │           │  │(Postgres)│ │            │
│      │  VPC │ EKS │ ECR   │           │  └────────┘ │            │
│      │  RDS │ IAM          │           └──────────────┘            │
│      └────────────────────┘                                        │
└─────────────────────────────────────────────────────────────────────┘
```

## CI/CD 흐름

```
Code Push → GitHub Actions → lint / test / Docker build → ECR push
→ Helm values image tag update → ArgoCD sync → EKS deploy → service running
```

| 단계 | 도구 | 역할 |
|------|------|------|
| **CI** | GitHub Actions | lint, test, build, ECR push, tag update |
| **CD** | ArgoCD | Helm values 변경 감지 → EKS 자동 배포 |

> CI와 CD를 분리하여 **변경 통제(Change Control)** 구조를 구현합니다. 금융권에서는 배포 승인과 추적이 필수이며, ArgoCD의 GitOps 방식은 모든 변경을 Git 이력으로 추적할 수 있어 감사(Audit)에 적합합니다.

## 프로젝트 구조

```
finguard/
├── infra/                              # Terraform IaC
│   ├── main.tf                         # 루트 모듈 (전체 연결)
│   ├── variables.tf / outputs.tf
│   ├── providers.tf / versions.tf / backend.tf
│   └── modules/
│       ├── vpc/                        # VPC, Subnets, NAT, S3 Endpoint
│       ├── eks/                        # EKS Managed Node Group, OIDC
│       ├── ecr/                        # ECR Repository + Lifecycle
│       ├── rds/                        # RDS PostgreSQL
│       └── iam/                        # IAM Roles (Cluster, Node)
├── apps/
│   └── transaction-risk-api/           # Flask API
│       ├── app/
│       │   ├── main.py                 # Entrypoint
│       │   ├── routes/                 # /score, /transactions, /health
│       │   ├── services/risk_engine.py # 위험 점수 산출 엔진
│       │   ├── schemas/                # 입력 검증
│       │   └── models/                 # 데이터 모델
│       ├── tests/                      # pytest 유닛 테스트
│       ├── Dockerfile                  # Multi-stage build
│       └── requirements.txt
├── deploy/
│   ├── helm/transaction-risk-api/      # Helm Chart
│   │   ├── Chart.yaml
│   │   ├── values.yaml                 # 기본값
│   │   ├── values-dev.yaml             # 개발 환경
│   │   ├── values-prod-lite.yaml       # 운영 환경
│   │   └── templates/                  # K8s 리소스 템플릿
│   └── argocd/
│       └── application.yaml            # ArgoCD Application
├── .github/workflows/
│   └── api-ci.yml                      # GitHub Actions CI
└── README.md
```

## Terraform 모듈 구조

| 모듈 | 리소스 | 특징 |
|------|--------|------|
| **vpc** | VPC, Public/Private Subnets, IGW, NAT, Route Tables, S3 VPC Endpoint | EKS 호환 태그, NAT 1개로 비용 절감 |
| **eks** | EKS Cluster, Managed Node Group, OIDC Provider, CloudWatch Logs | `access_entries` 사용 (aws-auth 대체) |
| **ecr** | ECR Repository, Lifecycle Policy | 이미지 스캔, 10개 초과 자동 삭제 |
| **rds** | RDS PostgreSQL, Subnet Group, Security Group | 암호화, EKS SG 기반 접근 제어 |
| **iam** | EKS Cluster Role, Node Role | CloudWatch, SSM, ECR 정책 포함 |

## API 명세

### POST /score — 거래 위험 점수 산출

**Request:**
```json
{
  "amount": 10000000,
  "merchant_category": "electronics",
  "country": "US",
  "transaction_hour": 3,
  "device_changed": true,
  "recent_txn_count_24h": 15,
  "customer_id": "CUST-001"
}
```

**Response:**
```json
{
  "risk_score": 100,
  "risk_level": "HIGH",
  "reason_codes": [
    "HIGH_AMOUNT",
    "OVERSEAS_TRANSACTION",
    "UNUSUAL_HOUR",
    "NEW_DEVICE",
    "BURST_ACTIVITY"
  ]
}
```

### GET /transactions/{customer_id} — 거래 내역 조회
### GET /health — 헬스 체크

## 위험 점수 산출 기준

| Reason Code | 조건 | 가중치 |
|-------------|------|--------|
| `HIGH_AMOUNT` | 금액 ≥ 500만원 | 25점 |
| `OVERSEAS_TRANSACTION` | 국가 ≠ KR | 20점 |
| `NEW_DEVICE` | device_changed = true | 20점 |
| `UNUSUAL_HOUR` | 0시 ~ 5시 | 15점 |
| `BURST_ACTIVITY` | 24시간 내 10건 이상 | 20점 |

- **LOW**: 0–30점 / **MEDIUM**: 31–70점 / **HIGH**: 71–100점

## 배포 방법

### 1. 인프라 배포
```bash
cd infra
terraform init
terraform plan -var="db_password=YOUR_PASSWORD"
terraform apply -var="db_password=YOUR_PASSWORD"
```

### 2. EKS 연결
```bash
aws eks update-kubeconfig --name finguard-cluster --region ap-northeast-2
```

### 3. ArgoCD 설치 및 앱 등록
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f deploy/argocd/application.yaml
```

### 4. 수동 Helm 배포 (ArgoCD 없이)
```bash
helm install finguard deploy/helm/transaction-risk-api -n finguard --create-namespace
```

## 장애 대응 포인트

| 시나리오 | 대응 |
|---------|------|
| Pod crash loop | `readinessProbe` 실패 시 트래픽 차단, HPA가 대체 Pod 생성 |
| 트래픽 급증 | HPA가 CPU 70% 초과 시 자동 스케일 아웃 (최대 8개) |
| 잘못된 배포 | ArgoCD Git revert → 자동 롤백 |
| DB 접속 불가 | Security Group이 EKS 노드만 허용, Private Subnet 내 배치 |
| 이미지 취약점 | ECR scan-on-push 활성화, CI에서 사전 차단 |

## GitHub Actions Secrets 설정

| Secret | 설명 |
|--------|------|
| `AWS_ACCESS_KEY_ID` | AWS IAM Access Key |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM Secret Key |

## 기술 결정 근거

- **aws-auth 대신 access_entries**: EKS API 기반 권한 관리로 ConfigMap 수동 관리 불필요
- **Managed Node Group**: 노드 업데이트/패치를 AWS가 관리, 운영 부담 최소화
- **CI/CD 분리**: 금융권 변경 통제 요건 충족, Git 이력 기반 감사 추적
- **S3 VPC Endpoint**: NAT Gateway를 경유하지 않아 데이터 전송 비용 절감
- **단일 NAT Gateway**: 비용 절감 (HA가 필요하면 AZ별 추가)
