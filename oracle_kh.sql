-- ==================================
-- KH 계정
-- ==================================
show user;

-- 사용자의 테이블 조회
select * from tab;

-- 사원테이블
select * from employee;
select * from job;
select * from department;
select * from loacation;
select * from nation;
select * from sal_grade;

-- table(entity, relation) 테이블
-- column(field, attribute) 컬럼(속성)
-- row(record,tuple) 행 - 사원한명, 부서하나의 정보. java app의 VO객체의 내용
-- domain 하나의 속성(컬럼)이 가질 수있는 원자값들의 집합

-- 테이블 명세
desc employee;


-- ==================================
-- 자료형
-- ==================================
-- 컬럼에 지정
-- 1. 문자형
-- 2. 숫자형
-- 3. 날짜형

-------------------------------------
-- 1.문자형
-------------------------------------
-- char     : 고정형(최대 2,000byte)
-- varchar2 : 가변형(최대 4,000byte)
-- long     : 가변형(최대 2GB)
-- clob     : 가변형(Character Large Object)(최대 4BG)

/*
    고정형 char(10)인 컬럼에 'korea'를 입력하면, 실제데이터의 길이는 5byte여도 10byte로 기록
    가변형 varchar2(10)인 컬럼에 'korea'를 입력하면, 실제데이터의 길이는 5byte이므로 5byte로 기록
    
    두 가지 형태 모두 지정한 크기를 초과하는 데이터는 처리할 수 없음
*/

-- 테이블 생성 구문 - 컬럼명, 자료형(크기) 지정
create table tb_type_char(
    a char(10),
    b varchar2(10)
);
-- 테이블 삭제 구문
--drop table tb_type_char;

--
select * from tb_type_char;

-- 데이터 추가 (row단위로 추가)
insert into tb_type_char
values ('korea','korea');

-- lengthb는 실제 사용된 byte수를 반환
select a, lengthb(a), b, lengthb(b)
from tb_type_char;

insert into tb_type_char
values ('I love korea','I love korea');

insert into tb_type_char
values ('홍길동','홍길동'); -- xe버전은 3byte씩 처리, ee버전은 2byte씩 처리

-- 메모리 상 작업내용을 실제 DB에 반영/취소하기
commit;
rollback;

-------------------------------------
-- 2. 숫자형
-------------------------------------
-- number(p, s)
-- p : 표현가능한 전체 자리수
-- s : 소수점 이하 자리수

/*
    1234.567 데이터 처리시...
    
    데이터타입        저장된값
    -------------------------
    number          1234.567
    number(7,1)     1234.6  -- 반올림
    number(7)       1235    -- 반올림
    number(7,-2)    1200    -- 반올림
*/

create table tb_type_number(
    a number,
    b number(7,1),
    c number(7),
    d number(7,-2)
);

insert into tb_type_number
values (1234.567, 1234.567, 1234.567, 1234.567);
insert into tb_type_number
values (1234567, 12345678, 1234567, 1234567);

select * from tb_type_number;

-------------------------------------
-- 3. 날짜형
-------------------------------------
-- date : 년월일시분초
-- timestamp : 년월일시분초 + 밀리초 + 지역대

-- 산술연산 가능
/*
    연산           결과타입    설명
    -----------------------------------------------------------
    날짜 + 숫자     date      날짜에서 지정한 숫자(일단위) 후의 날짜 리턴
    날짜 - 숫자     date      날짜에서 지정한 숫자(일단위) 전의 날짜 리턴
    날짜 - 날짜     number    두 날짜의 차이(일단위) 리턴
*/

-- dual 가상테이블(1행) 사용
-- sysdate 현재날짜 리턴
-- 1 : 하루
-- 1 / 24 : 한시간
-- 1 / 24 / 60 : 1분
select
    to_char(sysdate, 'yyyy-mm-dd hh24:mi:ss'),
    to_char(sysdate + (1 / 24), 'yyyy-mm-dd hh24:mi:ss'),
    to_char(sysdate - (1 / 48), 'yyyy-mm-dd hh24:mi:ss')
from
    dual;

-- 날짜 - 날짜 = 숫자(일단위)
select
    to_date('2022/08/29','yyyy/mm/dd') - sysdate
from
    dual;

desc employee;

-- 회원테이블 tb_type_member을 생성한다.
-- id       : 6~15자리 문자
-- password : 8~15자리 문자
-- name     : 한글입력 최대 10자
-- ssn      : 주민번호 -없이 13자리
-- phone    : 전화번호 -없이 11자리
-- point    : 멤버십포인트
-- reg_date : 가입일
create table tb_type_member(
    id varchar2(15),
    password varchar2(15),
    name varchar2(30),
    ssn char(13),
    phone char(11),
    point number,
    reg_date date
);
--drop table tb_type_member;

-- ===============================================
-- DQL 1
-- ===============================================
-- Data Query Language
-- DML의 한 종류로써, 테이블데이터를 검색하는 언어
-- select 명령에 대한 응답을 결과집합(Result Set)이라고 함
-- Result Set에는 0개 이상의 행이 포함된다.
-- Result Set은 특정기준에 따라 필터링되거나 정렬될 수 있다.

/*
    <구조>
    작성                  처리순서
    ----------------------------
    select 컬럼명 -------- (5) 원하는 컬럼 지정
    from 테이블명 -------- (1) 조회할 대상 테이블
    where 조건절 --------- (2) 특정 조건을 만족하는 행만 필터링
    group by 그룹핑컬럼 --- (3) 그룹핑
    having 그룹핑 조건절 -- (4) 그룹핑된 결과를 필터링
    order by 컬럼 -------- (6) 특정 컬럼 기준으로 행 정렬
    
    처리순서에 따라 DQL을 작성하는 습관을 들이는 것을 권장
*/

-- job테이블에서 job_name 컬럼만 조회
select job_name
from job;

-- employee 테이블에서 이름, 이메일, 전화번호, 입사일을 조회
select emp_name, email, phone, hire_date
from employee;

-- employee 테이블에서 급여가 2,500,000원 이상인 사원의 이름과 급여를 조회
select emp_name, salary
from employee
where salary >= 2500000;

-- employee 테이블에서 현재 근무중인 사원을 이름 오름차순으로 조회
select *
from employee
where quit_yn = 'N' -- 같다 비교연산자 : =
order by emp_name;

-- employee 테이블에서 급여가 350만원 이상이면서 직급코드가 J3인 사원의 사원명, 직급코드, 전화번호를 이름순으로 오름차순 정렬하여 출력
select emp_name, job_code, phone
from employee
where salary >= 3500000 and job_code='J3' -- &&(X) and(O)    ||(X) or(O)
order by emp_name;

-------------------------------------------------
-- SELECT
-------------------------------------------------
-- 존재하는 컬럼뿐만 아닌, 연산결과 출력 가능
-- null은 산술연산, 비교연산 불가
-- nvl(nullable값, null일때 처리할 값)
-- 월급, 보너스, 실급여
select
    emp_name as "사원명",
    salary as "급여",
    bonus as "보너스",
    nvl(bonus,0) as "보너스",
    salary + (salary * nvl(bonus, 0)) as "실급여"
from employee;

select
    null + 1, null * 1, null / 1, null - 1
from dual;

-- 별칭 alias
-- as "별칭"
-- as와 쌍따옴표는 생략 가능
select
    emp_name as "사원명",
    emp_no "주민번호",
    phone 전화번호,
    job_code "직급 코드", -- 별칭에 공백이 포함 된 경우 "" 생략불가
    dept_code "5부서코드" -- 숫자로 시작하는 경우 "" 생략불가
from employee;

-- 고정값 출력
-- 모든 행에 같은 값이 반복출력
select
    emp_name, salary, '원'
from employee;

-- distinct 중복값을 제거
-- select 구문에 딱 한번만 사용. 하나 이상의 컬럼에 대해 중복값 검사하여 중복된 행 제거
select
    distinct job_code, dept_code
from employee
order by job_code;

-- || 문자열 연결연산자
select
    emp_name, salary || '원' 급여
from employee;

-- @실습문제
-- employee 테이블에서 이름, 급여, 보너스(없으면 0으로처리), 보너스포함 급여, 실수령액(보너스포함 급여 - (보너스포함급여 * 3.3%))을 조회
select
    emp_name 이름, 
    salary || '원' 급여,
    nvl(bonus, 0) 보너스,
    salary + (salary * nvl(bonus, 0)) || '원' "보너스포함 급여",
    salary + (salary * nvl(bonus, 0)) - (salary + (salary * nvl(bonus, 0))) * 0.033 || '원' 실수령액
from employee;

-------------------------------------------------
-- WHERE
-------------------------------------------------
-- 대상 테이블에서 특정 행을 필터링하는 구문
-- 행에 대해서 조건절의 결과를 true/false로 구분, true인 행만 결과집합에 포함시킴

select *
from employee
where dept_code = 'D9'; -- 따옴표 안의 문자열은 실제값이므로 대소문자를 구분

-- 연산자
/*
    =
    >, <, >=, <=
    !=, <>, ^=          : 같지않다
    betweem a and b     : a이상 b이하
    like | not like     : 문자패턴 비교
    is null | is not null : null값 비교
    in | not in         : 값 목록에 포함여부
    
    논리 연결연산
    and                 : 두 조건을 모두 만족시키면 true. &&아님
    or                  : 두 조건 중 하나를 만족시키면 true. ||아님
    not                 : 반전
*/

-- 부서코드가 D6이고, 급여를 200만원보다 많이 받는 사원의 이름, 부서코드, 급여 조회
select emp_name, dept_code, salary
from employee
where dept_code = 'D6' and salary > 2000000;

-- 부서코드가  D9이 아닌 사원 조회
select *
from employee
where dept_code != 'D9';

-- 직급코드가 J1이 아닌 사원들의 월급등급(sal_level)을 중복없이 출력
select DISTINCT sal_level
from employee
where job_code != 'J1';

-- 부서코드가 D5가 아닌 사원과 부서코드가 null인 사원 모두 조회
select *
from employee
where dept_code != 'D5' or dept_code is null;

-- 근무기간이 20년 이상인 사원의 이름, 급여, 보너스율 조회
select emp_name, salary, bonus
from employee
where ((sysdate - hire_date)/365) >= 20;

-- between value1 and value2
-- value1 이상 value2 이하

-- 급여가 350만원 이상, 600만원 이하의 사원 조회
select *
from employee
--where salary >= 3500000 and salary <= 6000000;
where salary between 3500000 and 6000000;

-- 날짜에 대해서 처리
-- 1990년~2000년
select emp_name, hire_date
from employee
where hire_date >= '90/01/01' and hire_date < '00/12/31'; -- 1990년 1월 1일 자정(포함)부터 2001년 1월 1일 자정(미포함) 전까지 조회
--where hire_date between '90/01/01' and '00/12/31';

-- like | not like
-- 문자열 패턴 검사
/*
    wildcart(특수한 의미를 가진 문자)
    1. % : 문자가 0개 이상
        a% -> a다음에 문자 0개 이상 -> a, ab, aaaab, af1212aaaf ...
    2. _ : 문자가 1개
        a% -> a다음에 문자 1개만 -> ab, ac, ad ...
*/

-- 전씨 성을 가진 사원조회
select *
from employee
where emp_name like '전%';

-- 전씨 성 + 이름이 2글자인 사원조회
select *
from employee
where emp_name like '전__';

-- 이름이 3글자, 가운데 글자가 '옹'인 사원조회
select *
from employee
where emp_name like '_옹_';

-- 이름에 '이'가 들어가는 사원조회
select *
from employee
where emp_name like '%이%';

-- 성이 이씨가 아닌 사원 조회
select *
from employee
--where emp_name not like '이%';
where not (emp_name like '이%'); -- 두 가지 방법 모두 가능

-- 이메일 조회
-- '_'앞에 글자가 3글자인 이메일 조회
select email
from employee
--where email like '____%'; -- 4글자 이상인 이메일 조회
--where email like '___#_%' escape '#'; -- 아래와 같은 결과. 데이터에 # escape 문자가 있어서는 안된다.
where email like '___\_%' escape '\';

-- in | not in
-- 값목록에 포함되어있으면 true로 처리

-- D6, D8 부서원 조회
select emp_name, dept_code
from employee
--where dept_code = 'D6' or dept_code = 'D8';
where dept_code in ('D6','D8');

-- D6, D8 부서원을 제외하고 조회
select emp_name, dept_code
from employee
--where dept_code != 'D6' and dept_code != 'D8';
where dept_code not in ('D6','D8');

-- is null | is not null
-- 인턴 사원 조회 1
select *
from employee
where dept_code is null;

-- 인턴 사원 조회 2
select 
    emp_name,
    dept_code
from employee
where nvl(dept_code, '인턴') = '인턴';

-------------------------------------------------
-- ORDER BY
-------------------------------------------------
-- 마지막에 실행되어 행의 순서를 재배치한다.
-- 기본적으로 오름차순(asc)
--      작은수 -> 큰수, 사전등재빠른순 -> 사전등재늦은순, 과거 -> 미래
-- 1개 이상의 정렬기준 컬럼을 작성가능
-- nulls first, nulls last


select
    emp_name,
    dept_code,
    salary,
    hire_date
from employee
-- 부서별 급여 많이받는순, 부서코드 널값 먼저
order by dept_code asc nulls first, salary desc;

-- 컬럼명 대신 별칭, 컬럼순서 사용
-- 별칭 지정하는 select보다 처리순서가 늦은 구문에서 사용가능
select
    emp_name 사원명,
    dept_code 부서코드,
    salary 급여,
    hire_date 입사일
from employee
order by 부서코드 asc nulls first, 3 desc; -- 3번째 컬럼

-- ===============================================
-- FUNCTION
-- ===============================================
-- 일련의 작업 절차를 모아놓은 일종의 서브프로그램
-- 호출 시 매개인자 전달하고, 그에따른 수행결과를 '반드시' 리턴.
--     = 리턴값이 없을 수 없다.

/*
    함수의 종류
    
    1. 단일행처리 함수 - 행마다 처리
        a. 문자처리함수
        b. 숫자처리함수
        c. 날짜처리함수
        d. 형변환함수
        e. 기타함수
        
    2. 그룹처리 함수 - 행을 그룹핑 한 후 그룹마다 처리
*/

-------------------------------------------------
-- 1. 단일행처리 함수
-------------------------------------------------

-- ++++++++++++++++++++++++++++++++++++++++++++++
-- a. 문자처리 함수
-- ++++++++++++++++++++++++++++++++++++++++++++++
-- length(컬럼/값) : 길이값을 리턴
select emp_name, length(emp_name), lengthb(emp_name)
from employee;

-- instr(대상문자열, 검색할문자열[, 시작인덱스, 출현횟수]) : 인덱스를 반환
select
    instr('kh정보교육원 국가정보원 정보문화사', '정보') 정보,
    instr('kh정보교육원 국가정보원 정보문화사', '정보', 9) 시작인덱스9,
    instr('kh정보교육원 국가정보원 정보문화사', '정보', 1 , 3) "시작인덱스1, 3번째",
    instr('kh정보교육원 국가정보원 정보문화사', '정보', -1) "뒤에서부터 찾은 인덱스",
    instr('kh정보교육원 국가정보원 정보문화사', '안녕') 없는문자열
from dual;

-- 사원테이블에서 이메일 아이디의 길이를 조회
select
    email,
    instr(email, '@') - 1 "아이디길이"
from employee;

-- substr(대상문자열, index[, length]) : 문자열 리턴
select
    substr('SHOWMETHEMONEY', 5, 2), -- index부터 length글자 리턴
    substr('SHOWMETHEMONEY', 5), -- index부터 문자열 끝까지 리턴
    substr('SHOWMETHEMONEY', -5) -- 뒤에서부터 index 지정
from dual;

-- 사원테이블에서 이메일 아이디의 길이, 아이디를 조회
select
    email,
    instr(email, '@') - 1 "아이디길이",
    substr(email, 1, instr(email, '@') - 1) "아이디"
from employee;

-- lpad(문자열, 길이[, 패딩문자]) : 문자열 리턴
-- rpad(문자열, 길이[, 패딩문자]) : 문자열 리턴
select
    lpad('hello', 10, '#'),
    rpad('hello', 10, '#'),
    lpad(123, 5, 0),
    'kh-' || to_char(sysdate, 'yymmdd') || '-' || lpad(123, 5, 0)
from dual;

-- replace(대상문자열, 검색문자열, 치환문자열) : 문자열 리턴
select
    replace('hello@naver.com', 'naver.com', 'google.com') "new_email"
from dual;

-- 사원테이블에서 남자사원의 사번, 이름, 주민번호를 조회
-- 주민번호의 뒤 6자리는 *로 숨김처리
select
    emp_id,
    emp_name,
    rpad(substr(emp_no, 1, 8), 14, '*'),
    substr(emp_no, 1, 8) || '******' --위와 동일
from employee
where substr(emp_no, 8, 1) in ('1', '3');

-- ++++++++++++++++++++++++++++++++++++++++++++++
-- b. 숫자처리 함수
-- ++++++++++++++++++++++++++++++++++++++++++++++

-- +, -, *, /
-- mod(피제수, 제수) : 나머지 리턴
-- % 나머지 연산은 없음
select
    10 + 3,
    10 - 3,
    10 * 3,
    10 / 3,
    mod(10, 3) --나머지
from dual;

-- 생일 끝자리가 짝수인 사원만 조회
select
    *
from employee
where
    mod(substr(emp_no, 6, 1), 2) = 0;

-- ceil(number) : 숫자리턴
select
    ceil(123.456), --124
    ceil(123.456 * 100) / 100 --123.46
from dual;

-- round(number, 소수점이하 자리수) : 숫자리턴
select
    round(1234.56),
    round(1234.56, 1),
    round(1234.56, -2)
from dual;

-- floor(number) : 숫자리턴
select
    floor(234.567),
    floor(234.567 * 100) / 100
from dual;

-- trunc(number, 소수점이하 자리수) : 숫자리턴
select
    trunc(234.567),
    trunc(234.567, 2),
    trunc(234.567, -2)
from dual;

-- ++++++++++++++++++++++++++++++++++++++++++++++
-- c. 날짜처리 함수
-- ++++++++++++++++++++++++++++++++++++++++++++++

-- add_months(date, number) : date 반환
select
    add_months(sysdate, -1) 한달전,
    sysdate,
    add_months(sysdate, 1) 한달뒤,
    add_months(to_date('22/03/31', 'yy/mm/dd'), 1) "3/31로부터 한달뒤",
    add_months(to_date('22/04/30', 'yy/mm/dd'), 1) "4/30로부터 한달뒤"
from dual;

-- months_between(미래날짜, 과거날짜) : 개월수 차이 리턴
select
    MONTHS_BETWEEN(to_date('22/08/29', 'yy/mm/dd'), sysdate)
from dual;

-- 사원테이블에서 사원별 근무개월수1(n개월), 근무개월수2(k년 j개월)를 출력
select
    emp_name,
    floor(months_between(sysdate, hire_date)) || '개월' 근무개월수1,
    floor(months_between(sysdate, hire_date) / 12) || '년 ' ||
    floor(mod((months_between(sysdate, hire_date)), 12)) || '개월' 근무개월수2
from employee;

-- extract(year | month | day from date) :  숫자리턴
-- extract(hour | minute | second from cast(date as timestamp)) : 숫자리턴
select
    extract(year from sysdate) 년,
    extract(month from sysdate) 월,
    extract(day from sysdate) 일,
    extract(hour from cast(sysdate as timestamp)) 시,
    extract(minute from cast(sysdate as timestamp)) 분,
    extract(second from cast(sysdate as timestamp)) 초
from dual;

-- trunc(date) : 날짜형을 리턴(시분초를 제거)
select
    to_char(sysdate, 'yy/mm/dd hh24:mi:ss') "sysdate",
    to_char(trunc(sysdate), 'yy/mm/dd hh24:mi:ss') "trunc_sysdate"
from dual;