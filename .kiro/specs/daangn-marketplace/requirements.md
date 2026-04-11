# 요구사항 문서: 당근마켓 스타일 지역 기반 중고거래 플랫폼

## 소개

지역 기반 중고거래 플랫폼으로, 사용자가 자신의 동네에서 중고 물품을 사고팔 수 있는 서비스입니다. GPS 동네 인증을 통한 신뢰 기반 근거리 거래, 실시간 1:1 채팅을 통한 빠른 거래 협의, 매너온도 시스템을 통한 사용자 간 신뢰 구축을 핵심 가치로 합니다.

기술 스택: NestJS + TypeScript, Prisma ORM, PostgreSQL + PostGIS, Redis, Elasticsearch, WebSocket(Socket.io), Docker Compose

## 용어 사전

- **플랫폼(Platform)**: 당근마켓 스타일 지역 기반 중고거래 백엔드 시스템 전체
- **Auth_Module**: 전화번호 SMS 인증 및 JWT 토큰 관리를 담당하는 인증 모듈
- **User_Module**: 사용자 프로필, 매너온도, 동네 인증을 관리하는 사용자 모듈
- **Product_Module**: 상품 CRUD, 끌어올리기, 이미지 관리를 담당하는 상품 모듈
- **Chat_Module**: WebSocket 기반 실시간 1:1 채팅을 담당하는 채팅 모듈
- **Search_Module**: Elasticsearch 기반 상품 전문 검색을 담당하는 검색 모듈
- **Notification_Module**: 푸시 알림 발송 및 관리를 담당하는 알림 모듈
- **Transaction_Module**: 거래 상태 관리 및 후기 작성을 담당하는 거래 모듈
- **매너온도(Manner_Temperature)**: 거래 후기, 응답 속도, 약속 이행률을 종합한 사용자 신뢰 지표 (초기값 36.5°C)
- **동네_인증(Location_Verification)**: GPS 좌표 기반으로 사용자의 실제 거주 지역을 검증하는 절차
- **끌어올리기(Bump)**: 상품의 `bumped_at` 타임스탬프를 갱신하여 피드 상단에 재노출하는 기능
- **Presigned_URL**: S3에 직접 이미지를 업로드하기 위해 서버가 발급하는 임시 인증 URL
- **JWT(JSON_Web_Token)**: 사용자 인증에 사용되는 토큰 형식 (Access Token + Refresh Token)
- **PostGIS**: PostgreSQL의 공간 데이터 확장으로, 위치 기반 쿼리(ST_DWithin 등)를 지원
- **Redis_Pub_Sub**: Redis의 발행/구독 메시징 패턴으로, 다중 서버 간 실시간 메시지 브로드캐스트에 사용

## 요구사항

### 요구사항 1: SMS 인증번호 발송

**사용자 스토리:** 사용자로서, 전화번호로 SMS 인증번호를 받고 싶다. 그래야 본인 확인을 통해 안전하게 서비스에 가입할 수 있다.

#### 인수 조건

1. WHEN 사용자가 유효한 전화번호를 제출하면, THE Auth_Module SHALL 6자리 인증번호를 생성하여 해당 전화번호로 SMS를 발송한다
2. WHEN 인증번호가 발송되면, THE Auth_Module SHALL 해당 인증번호를 Redis에 저장하고 만료 시간을 3분으로 설정한다
3. IF 동일 전화번호로 1분 이내에 재발송 요청이 들어오면, THEN THE Auth_Module SHALL 요청을 거부하고 남은 대기 시간을 응답한다
4. IF 전화번호 형식이 유효하지 않으면, THEN THE Auth_Module SHALL 400 상태 코드와 형식 오류 메시지를 반환한다

### 요구사항 2: SMS 인증번호 확인 및 로그인

**사용자 스토리:** 사용자로서, 수신한 인증번호를 입력하여 로그인하고 싶다. 그래야 서비스의 모든 기능을 이용할 수 있다.

#### 인수 조건

1. WHEN 사용자가 올바른 인증번호를 제출하면, THE Auth_Module SHALL 인증을 성공 처리하고 JWT Access Token과 Refresh Token을 발급한다
2. WHEN 신규 사용자가 최초 인증에 성공하면, THE Auth_Module SHALL 새로운 사용자 레코드를 생성하고 매너온도를 36.5로 초기화한다
3. IF 인증번호가 일치하지 않으면, THEN THE Auth_Module SHALL 401 상태 코드와 인증 실패 메시지를 반환한다
4. IF 인증번호가 만료되었으면, THEN THE Auth_Module SHALL 401 상태 코드와 만료 안내 메시지를 반환한다
5. IF 5회 연속 인증 실패가 발생하면, THEN THE Auth_Module SHALL 해당 전화번호의 인증 시도를 30분간 차단한다

### 요구사항 3: JWT 토큰 관리

**사용자 스토리:** 사용자로서, 로그인 상태를 안전하게 유지하고 싶다. 그래야 매번 재인증 없이 서비스를 이용할 수 있다.

#### 인수 조건

1. THE Auth_Module SHALL Access Token의 만료 시간을 1시간으로 설정한다
2. THE Auth_Module SHALL Refresh Token의 만료 시간을 14일로 설정하고 Redis에 저장한다
3. WHEN 유효한 Refresh Token이 제출되면, THE Auth_Module SHALL 새로운 Access Token을 발급한다
4. IF 만료되거나 유효하지 않은 Access Token으로 API 요청이 들어오면, THEN THE Auth_Module SHALL 401 상태 코드를 반환한다
5. IF Refresh Token이 만료되었거나 Redis에 존재하지 않으면, THEN THE Auth_Module SHALL 401 상태 코드를 반환하고 재로그인을 요구한다
6. WHEN 사용자가 로그아웃하면, THE Auth_Module SHALL Redis에서 해당 Refresh Token을 삭제한다


### 요구사항 4: 사용자 프로필 관리

**사용자 스토리:** 사용자로서, 내 프로필 정보를 관리하고 싶다. 그래야 다른 사용자에게 신뢰감을 줄 수 있다.

#### 인수 조건

1. WHEN 인증된 사용자가 프로필 조회를 요청하면, THE User_Module SHALL 닉네임, 프로필 이미지 URL, 매너온도, 동네 인증 상태를 반환한다
2. WHEN 인증된 사용자가 닉네임 변경을 요청하면, THE User_Module SHALL 닉네임을 2자 이상 50자 이하로 검증한 후 업데이트한다
3. WHEN 인증된 사용자가 프로필 이미지 변경을 요청하면, THE User_Module SHALL 이미지 업로드용 Presigned_URL을 발급하고 프로필 이미지 URL을 업데이트한다
4. IF 닉네임이 2자 미만이거나 50자를 초과하면, THEN THE User_Module SHALL 400 상태 코드와 유효성 검증 오류 메시지를 반환한다
5. WHEN 다른 사용자의 프로필 조회를 요청하면, THE User_Module SHALL 해당 사용자의 공개 프로필 정보(닉네임, 프로필 이미지, 매너온도, 동네)를 반환한다

### 요구사항 5: 동네 인증

**사용자 스토리:** 사용자로서, GPS를 통해 내 동네를 인증하고 싶다. 그래야 같은 동네 사용자들과 신뢰할 수 있는 거래를 할 수 있다.

#### 인수 조건

1. WHEN 인증된 사용자가 GPS 좌표와 함께 동네 인증을 요청하면, THE User_Module SHALL PostGIS ST_DWithin 함수를 사용하여 좌표가 해당 행정동 반경 내에 있는지 검증한다
2. WHEN 좌표가 유효한 행정동 반경 내에 있으면, THE User_Module SHALL 사용자 위치 정보(시/도, 시/군/구, 읍/면/동)를 저장하고 인증 완료 상태로 변경한다
3. THE User_Module SHALL 사용자당 최대 2개의 동네를 등록할 수 있도록 허용한다
4. WHEN 사용자가 주 동네를 변경하면, THE User_Module SHALL 기존 주 동네의 is_primary 플래그를 해제하고 새 동네를 주 동네로 설정한다
5. IF GPS 좌표가 어떤 행정동 반경에도 포함되지 않으면, THEN THE User_Module SHALL 400 상태 코드와 위치 확인 불가 메시지를 반환한다

### 요구사항 6: 매너온도 시스템

**사용자 스토리:** 사용자로서, 거래 상대방의 매너온도를 확인하고 싶다. 그래야 신뢰할 수 있는 상대와 거래할 수 있다.

#### 인수 조건

1. THE User_Module SHALL 신규 사용자의 매너온도를 36.5°C로 초기화한다
2. WHEN 거래 후기가 등록되면, THE User_Module SHALL 후기의 매너 평가 태그에 따라 매너온도를 조정한다
3. THE User_Module SHALL 매너온도의 범위를 0°C 이상 99°C 이하로 제한한다
4. IF 매너온도 조정 결과가 0°C 미만이면, THEN THE User_Module SHALL 매너온도를 0°C로 설정한다
5. IF 매너온도 조정 결과가 99°C를 초과하면, THEN THE User_Module SHALL 매너온도를 99°C로 설정한다

### 요구사항 7: 사용자 차단 및 신고

**사용자 스토리:** 사용자로서, 부적절한 사용자를 차단하거나 신고하고 싶다. 그래야 안전한 거래 환경을 유지할 수 있다.

#### 인수 조건

1. WHEN 인증된 사용자가 다른 사용자를 차단하면, THE User_Module SHALL 차단 관계를 저장하고 차단된 사용자의 상품과 채팅을 숨긴다
2. WHEN 인증된 사용자가 차단을 해제하면, THE User_Module SHALL 차단 관계를 삭제한다
3. WHEN 인증된 사용자가 신고를 접수하면, THE User_Module SHALL 신고 사유와 대상 정보를 저장한다
4. IF 사용자가 자기 자신을 차단하거나 신고하려고 하면, THEN THE User_Module SHALL 400 상태 코드와 오류 메시지를 반환한다


### 요구사항 8: 상품 등록

**사용자 스토리:** 판매자로서, 중고 물품을 등록하고 싶다. 그래야 동네 사용자들에게 판매할 수 있다.

#### 인수 조건

1. WHEN 동네 인증이 완료된 사용자가 상품 등록을 요청하면, THE Product_Module SHALL 제목, 설명, 가격, 카테고리, 이미지를 포함한 상품을 생성하고 상태를 '판매중'으로 설정한다
2. WHEN 상품이 생성되면, THE Product_Module SHALL bumped_at을 현재 시간으로 설정하고 판매자의 주 동네 좌표를 상품 위치로 저장한다
3. WHEN 상품이 생성되면, THE Product_Module SHALL ProductCreatedEvent를 발행하여 Search_Module과 Notification_Module에 알린다
4. THE Product_Module SHALL 상품 제목을 2자 이상 200자 이하로 검증한다
5. THE Product_Module SHALL 가격을 0 이상의 정수로 검증한다 (0은 나눔을 의미)
6. IF 동네 인증이 완료되지 않은 사용자가 상품 등록을 요청하면, THEN THE Product_Module SHALL 403 상태 코드와 동네 인증 필요 메시지를 반환한다
7. IF 필수 항목(제목, 카테고리)이 누락되면, THEN THE Product_Module SHALL 400 상태 코드와 누락 항목 목록을 반환한다

### 요구사항 9: 상품 조회 및 피드

**사용자 스토리:** 구매자로서, 내 동네의 판매 상품 목록을 보고 싶다. 그래야 원하는 물품을 찾을 수 있다.

#### 인수 조건

1. WHEN 사용자가 상품 피드를 요청하면, THE Product_Module SHALL 사용자의 주 동네 좌표 기준 반경 6km 이내의 '판매중' 상품을 bumped_at 내림차순으로 반환한다
2. THE Product_Module SHALL 피드 응답에 커서 기반 페이지네이션을 적용하고 한 페이지당 20개 상품을 반환한다
3. WHERE 카테고리 필터가 지정되면, THE Product_Module SHALL 해당 카테고리의 상품만 반환한다
4. WHEN 사용자가 상품 상세를 조회하면, THE Product_Module SHALL 상품 정보, 판매자 정보(닉네임, 매너온도), 이미지 목록, 조회수, 채팅수, 관심수를 반환한다
5. WHEN 상품 상세가 조회되면, THE Product_Module SHALL 해당 상품의 조회수를 1 증가시킨다
6. THE Product_Module SHALL 피드 첫 페이지를 지역별로 Redis에 캐싱하고 TTL을 30초로 설정한다

### 요구사항 10: 상품 수정 및 삭제

**사용자 스토리:** 판매자로서, 등록한 상품 정보를 수정하거나 삭제하고 싶다. 그래야 정확한 정보를 유지할 수 있다.

#### 인수 조건

1. WHEN 판매자가 자신의 상품 수정을 요청하면, THE Product_Module SHALL 제목, 설명, 가격, 카테고리를 업데이트한다
2. WHEN 판매자가 자신의 상품 삭제를 요청하면, THE Product_Module SHALL 상품과 연관된 이미지 레코드를 삭제한다
3. IF 판매자가 아닌 사용자가 상품 수정 또는 삭제를 요청하면, THEN THE Product_Module SHALL 403 상태 코드를 반환한다
4. IF 존재하지 않는 상품에 대한 요청이면, THEN THE Product_Module SHALL 404 상태 코드를 반환한다

### 요구사항 11: 상품 상태 변경

**사용자 스토리:** 판매자로서, 상품의 거래 상태를 변경하고 싶다. 그래야 구매자에게 현재 거래 진행 상황을 알릴 수 있다.

#### 인수 조건

1. WHEN 판매자가 상태 변경을 요청하면, THE Product_Module SHALL 상품 상태를 '판매중', '예약중', '거래완료' 중 하나로 변경한다
2. THE Product_Module SHALL '판매중' → '예약중', '판매중' → '거래완료', '예약중' → '거래완료', '예약중' → '판매중' 전이만 허용한다
3. WHEN 상품 상태가 '거래완료'로 변경되면, THE Product_Module SHALL TransactionCompletedEvent를 발행한다
4. IF 허용되지 않는 상태 전이를 요청하면, THEN THE Product_Module SHALL 400 상태 코드와 허용되지 않는 전이 메시지를 반환한다

### 요구사항 12: 끌어올리기(Bump)

**사용자 스토리:** 판매자로서, 상품을 피드 상단에 다시 노출하고 싶다. 그래야 더 많은 구매자에게 상품을 보여줄 수 있다.

#### 인수 조건

1. WHEN 판매자가 '판매중' 상품의 끌어올리기를 요청하면, THE Product_Module SHALL bumped_at을 현재 시간으로 갱신한다
2. WHEN 끌어올리기가 수행되면, THE Product_Module SHALL 해당 지역의 피드 캐시를 무효화한다
3. IF 마지막 끌어올리기로부터 24시간이 경과하지 않았으면, THEN THE Product_Module SHALL 요청을 거부하고 남은 대기 시간을 반환한다
4. IF '판매중'이 아닌 상품에 끌어올리기를 요청하면, THEN THE Product_Module SHALL 400 상태 코드를 반환한다

### 요구사항 13: 관심(찜) 기능

**사용자 스토리:** 구매자로서, 관심 있는 상품을 찜하고 싶다. 그래야 나중에 쉽게 다시 찾을 수 있다.

#### 인수 조건

1. WHEN 인증된 사용자가 상품 관심 등록을 요청하면, THE Product_Module SHALL 관심 레코드를 생성하고 해당 상품의 favorite_count를 1 증가시킨다
2. WHEN 인증된 사용자가 이미 관심 등록된 상품에 다시 요청하면, THE Product_Module SHALL 관심 레코드를 삭제하고 favorite_count를 1 감소시킨다
3. WHEN 관심이 등록되면, THE Product_Module SHALL FavoriteCreatedEvent를 발행한다
4. IF 사용자가 자신의 상품에 관심 등록을 요청하면, THEN THE Product_Module SHALL 400 상태 코드를 반환한다

### 요구사항 14: 상품 이미지 업로드

**사용자 스토리:** 판매자로서, 상품 사진을 업로드하고 싶다. 그래야 구매자가 상품 상태를 확인할 수 있다.

#### 인수 조건

1. WHEN 인증된 사용자가 이미지 업로드 URL을 요청하면, THE Product_Module SHALL S3 Presigned_URL을 생성하여 반환한다
2. THE Product_Module SHALL 상품당 최대 10개의 이미지를 허용한다
3. THE Product_Module SHALL 이미지의 정렬 순서(sort_order)를 관리한다
4. IF 이미지 개수가 10개를 초과하면, THEN THE Product_Module SHALL 400 상태 코드와 이미지 개수 초과 메시지를 반환한다


### 요구사항 15: 채팅방 생성 및 목록 조회

**사용자 스토리:** 구매자로서, 상품에 대해 판매자와 채팅을 시작하고 싶다. 그래야 거래 조건을 협의할 수 있다.

#### 인수 조건

1. WHEN 구매자가 상품 기반 채팅방 생성을 요청하면, THE Chat_Module SHALL 해당 상품의 판매자와 구매자 간 채팅방을 생성한다
2. WHEN 동일 상품에 대해 동일 구매자가 채팅방 생성을 재요청하면, THE Chat_Module SHALL 기존 채팅방을 반환한다
3. WHEN 사용자가 채팅방 목록을 요청하면, THE Chat_Module SHALL 해당 사용자가 참여한 모든 채팅방을 last_message_at 내림차순으로 반환한다
4. THE Chat_Module SHALL 채팅방 목록에 상대방 닉네임, 상품 썸네일, 마지막 메시지, 읽지 않은 메시지 수를 포함한다
5. IF 판매자가 자신의 상품에 대해 채팅방 생성을 요청하면, THEN THE Chat_Module SHALL 400 상태 코드를 반환한다
6. IF 차단된 사용자와의 채팅방 생성을 요청하면, THEN THE Chat_Module SHALL 403 상태 코드를 반환한다

### 요구사항 16: 실시간 메시지 송수신

**사용자 스토리:** 사용자로서, 실시간으로 메시지를 주고받고 싶다. 그래야 빠르게 거래를 진행할 수 있다.

#### 인수 조건

1. WHEN 사용자가 WebSocket 연결을 요청하면, THE Chat_Module SHALL JWT 토큰을 검증한 후 연결을 수립한다
2. WHEN 사용자가 텍스트 메시지를 전송하면, THE Chat_Module SHALL 메시지를 데이터베이스에 저장하고 상대방에게 실시간으로 전달한다
3. THE Chat_Module SHALL 메시지 타입으로 텍스트(TEXT), 이미지(IMAGE), 가격 제안(OFFER)을 지원한다
4. WHEN 메시지가 전송되면, THE Chat_Module SHALL 채팅방의 last_message와 last_message_at을 갱신한다
5. WHEN 메시지가 전송되면, THE Chat_Module SHALL ChatMessageSentEvent를 발행하여 Notification_Module에 알린다
6. THE Chat_Module SHALL Redis Pub/Sub을 사용하여 다중 서버 인스턴스 간 메시지를 브로드캐스트한다
7. IF WebSocket 연결 시 JWT 토큰이 유효하지 않으면, THEN THE Chat_Module SHALL 연결을 거부한다

### 요구사항 17: 메시지 읽음 확인

**사용자 스토리:** 사용자로서, 상대방이 메시지를 읽었는지 확인하고 싶다. 그래야 응답을 기다릴지 판단할 수 있다.

#### 인수 조건

1. WHEN 사용자가 채팅방에 입장하면, THE Chat_Module SHALL 해당 채팅방의 읽지 않은 메시지의 read_at을 현재 시간으로 갱신한다
2. WHEN 메시지가 읽음 처리되면, THE Chat_Module SHALL 상대방에게 읽음 확인 이벤트를 실시간으로 전달한다
3. WHEN 사용자가 메시지 히스토리를 요청하면, THE Chat_Module SHALL 커서 기반 페이지네이션으로 메시지를 created_at 내림차순으로 반환한다

### 요구사항 18: 오프라인 메시지 처리

**사용자 스토리:** 사용자로서, 오프라인 상태에서 받은 메시지를 나중에 확인하고 싶다. 그래야 메시지를 놓치지 않을 수 있다.

#### 인수 조건

1. WHILE 수신자가 오프라인 상태이면, THE Chat_Module SHALL 메시지를 데이터베이스에 저장하고 Notification_Module을 통해 푸시 알림을 발송한다
2. WHEN 오프라인 사용자가 다시 접속하면, THE Chat_Module SHALL 읽지 않은 메시지 목록을 제공한다

### 요구사항 19: 상품 검색

**사용자 스토리:** 구매자로서, 키워드로 상품을 검색하고 싶다. 그래야 원하는 물품을 빠르게 찾을 수 있다.

#### 인수 조건

1. WHEN 사용자가 검색어를 입력하면, THE Search_Module SHALL Elasticsearch를 사용하여 상품 제목과 설명에서 전문 검색을 수행한다
2. THE Search_Module SHALL 검색 결과에 지역, 카테고리, 가격 범위, 상태 필터를 적용할 수 있도록 한다
3. THE Search_Module SHALL 검색 결과를 최신순, 인기순, 거리순으로 정렬할 수 있도록 한다
4. WHEN 상품이 생성, 수정, 삭제되면, THE Search_Module SHALL Elasticsearch 인덱스를 동기화한다
5. THE Search_Module SHALL 검색 결과에 커서 기반 페이지네이션을 적용한다
6. IF 검색어가 비어있으면, THEN THE Search_Module SHALL 400 상태 코드를 반환한다

### 요구사항 20: 검색어 자동완성 및 인기 검색어

**사용자 스토리:** 구매자로서, 검색어 자동완성과 인기 검색어를 보고 싶다. 그래야 더 편리하게 검색할 수 있다.

#### 인수 조건

1. WHEN 사용자가 검색어를 입력하는 중이면, THE Search_Module SHALL 입력된 접두사와 일치하는 검색어 후보를 최대 10개 반환한다
2. WHEN 사용자가 인기 검색어를 요청하면, THE Search_Module SHALL 최근 24시간 기준 검색 빈도가 높은 검색어를 최대 10개 반환한다
3. THE Search_Module SHALL 인기 검색어를 Redis에 캐싱하고 TTL을 1시간으로 설정한다

### 요구사항 21: 푸시 알림 발송

**사용자 스토리:** 사용자로서, 중요한 이벤트에 대해 푸시 알림을 받고 싶다. 그래야 실시간으로 거래 상황을 파악할 수 있다.

#### 인수 조건

1. WHEN ChatMessageSentEvent가 수신되고 상대방이 오프라인이면, THE Notification_Module SHALL 해당 사용자에게 새 메시지 푸시 알림을 발송한다
2. WHEN 관심 상품의 가격이 변경되면, THE Notification_Module SHALL 해당 상품을 찜한 사용자들에게 가격 변경 푸시 알림을 발송한다
3. WHEN TransactionCompletedEvent가 수신되면, THE Notification_Module SHALL 구매자에게 거래 후기 작성 요청 푸시 알림을 발송한다
4. THE Notification_Module SHALL 알림 내역을 데이터베이스에 저장한다
5. THE Notification_Module SHALL FCM을 사용하여 푸시 알림을 발송한다

### 요구사항 22: 알림 설정 관리

**사용자 스토리:** 사용자로서, 알림 유형별로 수신 여부를 설정하고 싶다. 그래야 원하는 알림만 받을 수 있다.

#### 인수 조건

1. THE Notification_Module SHALL 채팅 알림, 관심 상품 알림, 거래 후기 알림 유형별로 on/off 설정을 지원한다
2. WHEN 사용자가 알림 설정을 변경하면, THE Notification_Module SHALL 해당 설정을 저장한다
3. WHILE 특정 알림 유형이 off로 설정되어 있으면, THE Notification_Module SHALL 해당 유형의 푸시 알림을 발송하지 않는다
4. THE Notification_Module SHALL 신규 사용자의 모든 알림 유형을 기본적으로 on으로 설정한다

### 요구사항 23: 거래 관리

**사용자 스토리:** 사용자로서, 거래 내역을 관리하고 싶다. 그래야 구매 및 판매 이력을 확인할 수 있다.

#### 인수 조건

1. WHEN 상품 상태가 '거래완료'로 변경되면, THE Transaction_Module SHALL 거래 레코드를 생성한다
2. WHEN 사용자가 거래 내역을 요청하면, THE Transaction_Module SHALL 구매 내역과 판매 내역을 구분하여 반환한다
3. THE Transaction_Module SHALL 거래 내역에 상품 정보, 거래 상대방 정보, 거래 일시를 포함한다
4. THE Transaction_Module SHALL 거래 내역을 커서 기반 페이지네이션으로 반환한다

### 요구사항 24: 거래 후기 작성

**사용자 스토리:** 사용자로서, 거래 후 상대방에 대한 후기를 작성하고 싶다. 그래야 다른 사용자들이 거래 상대를 판단하는 데 도움을 줄 수 있다.

#### 인수 조건

1. WHEN 거래 완료 후 사용자가 후기 작성을 요청하면, THE Transaction_Module SHALL 후기 내용과 매너 평가 태그를 저장한다
2. WHEN 후기가 저장되면, THE Transaction_Module SHALL User_Module에 매너온도 업데이트를 요청한다
3. THE Transaction_Module SHALL 동일 거래에 대해 사용자당 1회만 후기 작성을 허용한다
4. IF 거래에 참여하지 않은 사용자가 후기 작성을 요청하면, THEN THE Transaction_Module SHALL 403 상태 코드를 반환한다
5. IF 이미 후기를 작성한 거래에 대해 재작성을 요청하면, THEN THE Transaction_Module SHALL 409 상태 코드와 중복 후기 메시지를 반환한다

### 요구사항 25: 인프라 및 공통 설정

**사용자 스토리:** 개발자로서, Docker Compose로 전체 개발 환경을 구성하고 싶다. 그래야 일관된 개발 환경에서 작업할 수 있다.

#### 인수 조건

1. THE 플랫폼 SHALL Docker Compose를 사용하여 PostgreSQL, Redis, Elasticsearch 서비스를 구성한다
2. THE 플랫폼 SHALL 환경 변수를 .env 파일로 관리하고 .env.example 파일을 제공한다
3. THE 플랫폼 SHALL 모든 API 응답에 일관된 JSON 형식(status, data, message)을 사용한다
4. THE 플랫폼 SHALL 모든 API 엔드포인트에 요청 유효성 검증을 적용한다
5. THE 플랫폼 SHALL 글로벌 예외 필터를 통해 예상치 못한 오류를 처리하고 적절한 HTTP 상태 코드를 반환한다
6. THE 플랫폼 SHALL 모든 모듈 간 통신에 이벤트 버스 패턴을 사용하여 느슨한 결합을 유지한다