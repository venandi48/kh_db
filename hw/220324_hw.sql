-------------------------------------------------------
-- 220324
-------------------------------------------------------
-- 테이블을 적절히 생성하고, 테이블, 컬럼주석을 추가하세요.



/*
    1. 첫번째 테이블 명 : EX_MEMBER
    * MEMBER_CODE(NUMBER) - 기본키                        -- 회원전용코드 
    * MEMBER_ID (varchar2(20) ) - 중복금지                    -- 회원 아이디
    * MEMBER_PWD (char(20)) - NULL 값 허용금지                    -- 회원 비밀번호
    * MEMBER_NAME(varchar2(30))                             -- 회원 이름
    * MEMBER_ADDR (varchar2(100)) - NULL값 허용금지                    -- 회원 거주지
    * GENDER (char(3)) - '남' 혹은 '여'로만 입력 가능                -- 성별
    * PHONE(char(11)) - NULL 값 허용금지                     -- 회원 연락처
*/

-- 테이블생성
create table ex_member(
    member_code number,
    member_id varchar2(20),
    member_pwd char(20) not null,
    member_name varchar2(30),
    member_addr varchar2(100) not null,
    gender char(3),
    phone char(11) not null,
    
    constraint pk_ex_member_code primary key(member_code),
    constraint uq_ex_member_id unique(member_id),
    constraint ck_ex_member_gender check(gender in ('남', '여'))
);
-- drop table ex_member;


-- 주석추가
comment on table ex_member is '220324 hw 1번';

comment on column ex_member.member_code is '회원전용코드';
comment on column ex_member.member_id is '회원 아이디';
comment on column ex_member.member_pwd is '회원 비밀번호';
comment on column ex_member.member_name is '회원 이름';
comment on column ex_member.member_addr is '회원 거주지';
comment on column ex_member.gender is '회원 성별';
comment on column ex_member.phone is '회원 연락처';


-- 주석조회
select *
from
    user_tab_comments join user_col_comments
        using(table_name)
where table_name = 'EX_MEMBER';





/*
    2. EX_MEMBER_NICKNAME 테이블을 생성하자. (제약조건 이름 지정할것)
    (참조키를 다시 기본키로 사용할 것.)
    * MEMBER_CODE(NUMBER) - 외래키(EX_MEMBER의 기본키를 참조), 중복금지        -- 회원전용코드
    * MEMBER_NICKNAME(varchar2(100)) - 필수                         -- 회원 이름
*/

-- 테이블 생성
create table ex_member_nickname(
    member_code number,
    member_nickname varchar2(100) not null,
    
    constraint fk_ex_nickname_code
        foreign key(member_code) references ex_member(member_code),
    constraint pk_ex_nickname_code primary key(member_code)
);
-- drop table ex_member_nickname;


-- 주석추가
comment on table ex_member_nickname is '220324 hw 2번';
comment on column ex_member_nickname.member_code is '회원전용코드';
comment on column ex_member_nickname.member_nickname is '회원 이름';


-- 주석조회
select *
from
    user_tab_comments join user_col_comments
        using(table_name)
where table_name = 'EX_MEMBER_NICKNAME';