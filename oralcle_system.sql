-- ==================================
-- SYSTEM 관리자계정
-- ==================================
show user

-- oracle설치 시 자동으로 sys, system계정이 생성된다.
-- 1. sys 슈퍼관리자
--      db 생성/삭제권한 보유. 그 외 모든 DB관련 처리 가능.
--      로그인 시 sysdba역할 로 접속해야함
-- 2. system 일반관리자
--      db 생성/삭제 권한 없음. 그 외 모든 DB관련 처리 가능.

-- sql문법은 대소문자를 구분하지 않는다.
-- 실제데이터와 사용자의 비밀번호, 별칭은 대소문자 구분

-- ORA-65096: 공통 사용자 또는 롤 이름이 부적합합니다.
-- 12c버전부터 일반사용자는 c##, C## 접두사를 사용해야 함.
-- 우회방법
alter session set "_oracle_script" = true;


-- 일반사용자(kh) 추가
create user kh
IDENTIFIED by kh -- 비밀번호
default tablespace users; -- 실제 데이터 저장공간

-- 접속권한(create, session), 테이블생성권한 부여
-- connect롤(역할)안에 접속권한 포함
grant connect, resource to kh;

-- tablespace users에 사용량 무제한으로 설정
alter user kh quota unlimited on users;