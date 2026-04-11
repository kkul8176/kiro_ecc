---
name: terraform-patterns
description: >
  Terraform 구체 패턴 - 모듈 구조, provider 설정, 변수/출력 컨벤션,
  사내 모듈 검색/활용, state 관리 패턴.
  Terraform 코드를 작성하거나 리뷰할 때 활성화한다.
metadata:
  origin: ECC
---

# Terraform Patterns

## 언제 사용하나

- Terraform 코드를 작성할 때
- 기존 Terraform 모듈을 검색/활용할 때
- Terraform 코드를 리뷰할 때
- state 관리 전략을 결정할 때

## 프로젝트 구조

```
cloud/
├── main.tf              # 모듈 호출, 자원 간 연결
├── variables.tf         # 입력 변수 정의
├── outputs.tf           # 출력 값 정의
├── providers.tf         # provider 설정
├── backend.tf           # state 백엔드 설정
├── terraform.tfvars     # 기본 변수 값 (git 제외 가능)
├── dev.tfvars           # 개발 환경 변수
├── prd.tfvars           # 프로덕션 환경 변수
└── modules/             # 로컬 모듈 또는 clone한 외부 모듈
    ├── vpc/
    ├── ecs/
    └── rds/
```

## Provider 설정

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = var.owner
    }
  }
}
```

## 변수 컨벤션

```hcl
variable "project_name" {
  description = "프로젝트 이름 (태그 및 리소스 네이밍에 사용)"
  type        = string
}

variable "environment" {
  description = "배포 환경 (dev, stg, prd)"
  type        = string
  validation {
    condition     = contains(["dev", "stg", "prd"], var.environment)
    error_message = "environment는 dev, stg, prd 중 하나여야 합니다."
  }
}

variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}
```

## 출력 컨벤션

```hcl
output "vpc_id" {
  description = "생성된 VPC의 ID"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "ALB의 DNS 이름 (접속 URL)"
  value       = module.alb.dns_name
}
```

## 모듈 호출 패턴

```hcl
# 자원 간 의존성 순서에 따라 배치
# 1. 네트워크 (선행)
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  cidr_block   = var.vpc_cidr
}

# 2. 보안 그룹 (VPC 의존)
module "security_groups" {
  source = "./modules/sg"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment
}

# 3. 데이터베이스 (VPC, SG 의존)
module "rds" {
  source = "./modules/rds"

  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security_groups.rds_sg_id
}

# 4. 컴퓨팅 (VPC, SG, DB 의존)
module "ecs" {
  source = "./modules/ecs"

  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security_groups.ecs_sg_id
  database_url      = module.rds.connection_string
}
```

## State 관리

### 로컬 State (개발/PoC)
```hcl
# backend.tf 없음 — 기본 로컬 저장
# terraform.tfstate가 cloud/ 폴더에 생성됨
# .gitignore에 *.tfstate, *.tfstate.backup 추가 필수
```

### 원격 State (팀/프로덕션)
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "project/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

## 사내 모듈 검색 (Bitbucket)

사내 IaC 모듈 저장소가 있는 경우:

1. `mcp_bitbucket_list_repositories`로 IaC 프로젝트의 레포지토리 목록 조회
2. 필요한 자원(VPC, ECS, RDS 등)과 매칭되는 레포지토리 검색
3. 매칭되는 모듈이 있으면 `git clone`하여 `modules/` 하위에 배치
4. clone 후 README를 읽어 필수 변수, 출력, 사용법 파악
5. 사내 모듈이 없으면 사용자에게 대안 확인 (공개 모듈 / 직접 작성)

## 공개 모듈 검색

```
mcp_terraform_searchModules(moduleQuery: "aws vpc")
mcp_terraform_moduleDetails(moduleID: "...")
```

## Terraform 명령어 순서

```bash
terraform init                    # 초기화 (provider, 모듈 다운로드)
terraform validate                # 구문 검증
terraform plan -var-file=dev.tfvars -out=tfplan   # 변경 계획
# → 사용자 승인
terraform apply tfplan            # 적용
```

## 리소스 네이밍 컨벤션

```
{project}-{environment}-{resource-type}
예: my-app-dev-vpc, my-app-prd-ecs-cluster
```

## 안티 패턴

- `terraform apply` 직접 실행 (plan 없이)
- 하드코딩된 AMI ID, 서브넷 ID
- 태그 없는 자원
- state 파일을 git에 커밋
- 모듈 없이 main.tf에 모든 자원을 나열 (500줄 이상)
- `count`로 복잡한 조건 분기 (`for_each` 사용 권장)
