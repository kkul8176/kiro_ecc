---
inclusion: fileMatch
fileMatchPattern: "*.tf,*.tfvars,*.hcl,**/cloud/**,**/infra/**"
description: IaC 거버넌스 - Terraform/CDK 등 IaC 코드를 다루는 모든 작업에서 따라야 하는 공통 규칙
---

# IaC 거버넌스

> 이 규칙은 IaC(Infrastructure as Code) 코드를 작성/수정/리뷰하는 모든 작업에 적용된다.
> Terraform, CDK, CloudFormation 등 도구에 관계없이 적용된다.

## 절대 규칙 (위반 금지)

### 1. plan 없이 apply 금지
`terraform plan` (또는 동등한 검증 단계) 없이 `terraform apply`를 실행하지 않는다.
- plan 결과를 사용자에게 제시하고 승인을 받은 후에만 apply를 실행한다.

### 2. 태그 없는 자원 생성 금지
모든 AWS 자원에 다음 태그를 필수로 적용한다:

| 태그 키 | 설명 | 예시 |
|---------|------|------|
| Project | 프로젝트명 | my-web-app |
| Environment | 환경 | dev / stg / prd |
| ManagedBy | 관리 도구 | terraform / cdk |
| Owner | 소유자/팀 | 사용자에게 확인 |

`CostCenter` 등 추가 태그는 사용자에게 확인 후 적용한다.

### 3. destroy는 사용자 승인 필수
`terraform destroy` 또는 자원 삭제는 반드시 사용자의 명시적 승인을 받는다.
프로덕션 환경은 특히 주의한다.

### 4. state 파일 관리
- state 파일(`terraform.tfstate`)의 위치를 명확히 한다 (로컬 vs S3 원격).
- state 파일을 git에 커밋하지 않는다.
- 원격 state 사용 시 잠금(locking)을 활성화한다.

## 환경 분리

- 환경별로 워크스페이스 또는 디렉토리를 분리한다.
- 개발 환경 변경이 프로덕션에 영향을 주지 않도록 격리한다.
- 환경별 변수 파일을 분리한다 (`dev.tfvars`, `stg.tfvars`, `prd.tfvars`).

## 모듈 변경 시 영향 범위 확인

- 공유 모듈을 수정할 때는 해당 모듈을 사용하는 모든 환경에 대해 plan을 실행한다.
- 영향 범위를 사용자에게 안내한다.

## IaC 코드 품질

- 변수에 `description`과 `type`을 명시한다.
- 출력(output)에 `description`을 명시한다.
- 하드코딩된 값 대신 변수를 사용한다.
- 반복되는 패턴은 모듈로 추출한다.
- `README.md`에 모듈 사용법, 필수 변수, 예제를 문서화한다.

## 체크리스트

- [ ] plan 결과를 확인하고 사용자 승인을 받았는가
- [ ] 모든 자원에 필수 태그가 적용되어 있는가
- [ ] state 파일 위치가 명확하고 안전한가
- [ ] 환경이 적절히 분리되어 있는가
- [ ] 변수에 description과 type이 있는가
- [ ] 모듈 변경 시 영향 범위를 확인했는가
