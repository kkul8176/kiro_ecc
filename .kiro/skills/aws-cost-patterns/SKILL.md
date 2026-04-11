---
name: aws-cost-patterns
description: >
  AWS 서비스별 비용 패턴, 예상 비용 산출 방법, 비용 최적화 팁.
  클라우드 아키텍처 설계 또는 IaC 구성 시 활성화한다.
metadata:
  origin: ECC
---

# AWS 비용 패턴

## 언제 사용하나

- 클라우드 아키텍처를 설계할 때 (서비스 선정 시 비용 비교)
- IaC로 자원을 구성할 때 (사양 결정)
- 배포 후 비용을 분석할 때
- 비용 최적화를 검토할 때

## 서비스별 비용 감각 (서울 리전 기준, 대략적)

### 컴퓨팅

| 서비스 | 사양 | 월간 비용 (대략) | 용도 |
|--------|------|-----------------|------|
| ECS Fargate | 0.25 vCPU, 0.5GB | ~$10 | 개발/경량 API |
| ECS Fargate | 1 vCPU, 2GB | ~$40 | 일반 API 서버 |
| EC2 t3.micro | 2 vCPU, 1GB | ~$10 | 개발/테스트 |
| EC2 t3.small | 2 vCPU, 2GB | ~$20 | 경량 워크로드 |
| Lambda | 100만 요청, 128MB | ~$2 | 이벤트 기반 |

### 데이터베이스

| 서비스 | 사양 | 월간 비용 (대략) | 용도 |
|--------|------|-----------------|------|
| RDS PostgreSQL db.t3.micro | 2 vCPU, 1GB | ~$15 | 개발 |
| RDS PostgreSQL db.t3.small | 2 vCPU, 2GB | ~$30 | 경량 프로덕션 |
| Aurora Serverless v2 | 0.5~1 ACU | ~$45+ | 가변 워크로드 |
| DynamoDB | 온디맨드, 100만 쓰기 | ~$1.25 | 키-값 저장 |
| ElastiCache t3.micro | 1 노드 | ~$15 | 개발용 캐시 |

### 네트워크/CDN

| 서비스 | 사양 | 월간 비용 (대략) | 비고 |
|--------|------|-----------------|------|
| ALB | 기본 | ~$20+ | 시간당 + LCU |
| NAT Gateway | 기본 | ~$35+ | 시간당 + 데이터 처리 — 비용 주의 |
| CloudFront | 100GB 전송 | ~$10 | 정적 자산 CDN |
| Route 53 | 호스팅 존 1개 | ~$0.50 | DNS |

### 스토리지

| 서비스 | 사양 | 월간 비용 (대략) | 용도 |
|--------|------|-----------------|------|
| S3 Standard | 100GB | ~$2.3 | 정적 파일 |
| EBS gp3 | 100GB | ~$8 | EC2 디스크 |

## 비용 폭탄 주의 항목

| 항목 | 위험 | 대안 |
|------|------|------|
| NAT Gateway | 시간당 과금 + 데이터 처리 비용. 개발 환경에서 월 $35+ | VPC 엔드포인트로 대체, 또는 퍼블릭 서브넷 사용 |
| ALB | 최소 월 $20. 개발 환경에서 불필요할 수 있음 | 개발 환경은 직접 포트 노출 또는 API Gateway |
| RDS 멀티 AZ | 비용 2배 | 개발/스테이징은 싱글 AZ |
| CloudWatch 로그 | 보존 기간 무제한이면 누적 비용 | 개발: 7일, 프로덕션: 90일 |
| 탄력적 IP (미사용) | 연결 안 된 EIP는 시간당 과금 | 사용 안 하면 즉시 해제 |

## 예상 비용 산출 방법

### 1. MCP 도구 활용
```
mcp_awslabsbilling_cost_management_mcp_server_aws_pricing(
  operation: "get_pricing_from_api",
  service_code: "AmazonEC2",
  region: "ap-northeast-2",
  filters: {"instanceType": "t3.micro", "operatingSystem": "Linux"}
)
```

### 2. 수동 산출 템플릿

```markdown
## 예상 월간 비용

| 서비스 | 사양 | 수량 | 월간 비용 |
|--------|------|------|----------|
| ECS Fargate | 1 vCPU, 2GB | 2 태스크 | $80 |
| RDS PostgreSQL | db.t3.small | 1 인스턴스 | $30 |
| ALB | 기본 | 1 | $25 |
| S3 | 10GB | 1 버킷 | $0.25 |
| CloudFront | 50GB 전송 | 1 배포 | $5 |
| **합계** | | | **~$140/월** |

※ 데이터 전송, CloudWatch 로그 등 부수 비용 별도
```

## 환경별 비용 전략

| 환경 | 전략 |
|------|------|
| dev | 최소 사양, NAT Gateway 대신 VPC 엔드포인트, 싱글 AZ, 필요할 때만 실행 |
| stg | 프로덕션 축소판, 싱글 AZ, 스케줄링으로 업무 시간만 실행 |
| prd | 적정 사양, 멀티 AZ, 오토스케일링, Reserved Instance/Savings Plans 검토 |

## 비용 분석 MCP 도구

| 도구 | 용도 |
|------|------|
| `cost_explorer` (getCostAndUsage) | 과거 비용 조회 |
| `cost_explorer` (getCostForecast) | 미래 비용 예측 |
| `cost_optimization` (list_recommendation_summaries) | 비용 절감 권고 |
| `aws_pricing` (get_pricing_from_api) | 서비스별 단가 조회 |
