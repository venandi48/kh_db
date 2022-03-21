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
    between a and b     : a이상 b이하
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

-- ++++++++++++++++++++++++++++++++++++++++++++++
-- d. 형변환 함수
-- ++++++++++++++++++++++++++++++++++++++++++++++

/*
    to_char         to_date
    ---------->  ----------->
number        char          date
    <----------  <-----------
    to_number       to_char
*/

-- to_char(date,format_char) : char
select
    to_char(sysdate, 'yyyy-mm-dd hh24:mi:ss') 날짜,
    to_char(sysdate, 'yyyy-mm-dd (day) hh:mi:ss') 날짜, -- 12시간제
    to_char(sysdate, 'yyyy-mm-dd (day) (dy) (d)') 날짜, -- 1:일요일, 2:월요일
    to_char(sysdate, 'yyyy"년" mm"월" dd"일"') 날짜,
    to_char(sysdate, 'fmyyyy"년" mm"월" dd"일"') 날짜 -- 포맷으로 생긴 공백(0) 제거
from dual;

-- to_char(number, formar_char) : char
-- 세자리 콤마적용, 소수점이하 처리
-- 실제값보다 자리수가 적으면 표시할 수 없음
select
    to_char(1234567890, '9,999') "###",
    to_char(1234567890, '999,999,999,999') "정상처리",
    to_char(1234567890, 'fm999,999,999,999') "여백제외",
    123 숫자숫자숫자,
    to_char(1234567890, 'fmL999,999,999,999') "지역통화기호", -- L 지역통화기호
    to_char(123.456, '99999.99999') "포맷9", -- 소수점이상 공백, 소수점이하 0채움 처리
    to_char(123.456, 'fm00000.00000') "포맷0" -- 소수점이상, 이하 모두 0채움 처리
from dual;

-- 사원테이블에서 사원명, 급여, 연봉(급여 * 12), 입사일 조회
-- 금액형식지정, 년월일 형식
select
    emp_name "사원명",
    to_char(salary, 'fmL999,999,999') "급여",
    to_char(salary * 12, 'fmL999,999,999') "연봉",
    to_char(hire_date, 'yyyy"년" mm"월" dd"일"') "입사일"
from employee;

-- to_number(char, format_char) : number 리턴
-- 그룹핑처리된 숫자를 순수 숫자로 변환해서 연산처리
select
    to_number('￦8,000,000', 'L999,999,999') + 1000 "금액을 숫자로",
    '1000' + '100' "숫자로 합연산",-- '+'는 숫자사이에만 가능
    '1000' || '100' "문자로 합연산" -- '||'는 문자 연결연산에 사용
from dual;

-- to_date(char, format_char) : date 리턴
select
    to_date('1999년 3월 16일', 'yyyy"년" mm"월" dd"일"') 날짜,
    extract(year from to_date('1955/01/01', ' yyyy/mm/dd')) "년도Y(1995)",
    extract(year from to_date('1955/01/01', ' rrrr/mm/dd')) "년도R(1995)",
    extract(year from to_date('55/01/01', 'yy/mm/dd')) 년도y, -- 현재년도 기준으로 100년(2000~2099)
    extract(year from to_date('55/01/01', 'rr/mm/dd')) 년도r -- 현재년도 기준으로 100년(1950~2049)
    -- 현재년도가 2055년이라면 RR은 2050~2149 내에서 판단
from dual;

-- 나이 구하기
-- 450505(1945), 550505(1955), 070707(2007)
-- yy, rr 둘 다 안됨.
-- 주민번호 뒷자리의 첫번째 값을 근거로 1900 + 생년 2자리, 2000 + 생년 2자리
select
    extract(year from to_date('550505', 'yymmdd')) "YY 550505",
    extract(year from to_date('070707', 'yymmdd')) "YY 070707",
    
    extract(year from to_date('450505', 'rrmmdd')) "RR 450505",
    extract(year from to_date('550505', 'rrmmdd')) "RR 550505",
    extract(year from to_date('070707', 'rrmmdd')) "RR 070707"
from dual;

-- 현재시각으로 부터  1일 2시간 3분 4초 뒤를 시각조회
-- 년월일시분초 형태로 출력
select
    to_char(sysdate,'yy"년"mm"월"dd"일" hh24:mi:ss') "현재시각",
    to_char(sysdate + 1 + (1/24 * 2) + (1/24/60 * 3) + (1/24/60/60 * 4), 'yy"년"mm"월"dd"일" hh24:mi:ss') "1일 2시간 3분 4초 뒤"
from dual;

-- 2022/08/29 남은 일수 구하기
select
    '수료일로부터 D-' || ceil(to_date('2022/08/29', 'yyyy/mm/dd') - sysdate) "남은일수"
from dual;

-- 기간(interval) 타입
-- 1. interval year to month
-- 2. interval day to second
select
    numtodsinterval(to_date('2022/08/29', 'yyyy/mm/dd') - sysdate, 'day') 기간,
    extract(day from numtodsinterval(to_date('2022/08/29', 'yyyy/mm/dd') - sysdate, 'day')) 일,
    extract(hour from numtodsinterval(to_date('2022/08/29', 'yyyy/mm/dd') - sysdate, 'day')) 시간,
    extract(minute from numtodsinterval(to_date('2022/08/29', 'yyyy/mm/dd') - sysdate, 'day')) 분,
    extract(second from numtodsinterval(to_date('2022/08/29', 'yyyy/mm/dd') - sysdate, 'day')) 초
from dual;

-- ++++++++++++++++++++++++++++++++++++++++++++++
-- e. 기타 함수
-- ++++++++++++++++++++++++++++++++++++++++++++++

-- nvl(nullable값, null인 경우 사용값) : 값
-- nvl2(nullable값, not null시 사용값,  null인경우 사용값) : 값
select
    emp_name,
    bonus,
    nvl2(bonus, '보너스 있음', '보너스 없음') 보너스여부
from employee;

-- 선택함수 decode
-- decode(표현식, 값1, 결과값1, 값2, 결과값2, ... [, 기본결과값]) : 결과값
-- job _code J1:대표, J2:부사장, J3:부장, J4:차장, J5:과장, J6:대리, J7:사원
select
    emp_name,
    job_code,
    decode(job_code, 'J1', '대표', 'J2', '부사장', 'J3', '부장', 'J4', '차장', 'J5', '과장', 'J6', '대리', 'J7', '사원') 직급명,
    decode(job_code, 'J1', '대표', 'J2', '부사장', 'J3', '부장', 'J4', '차장', 'J5', '과장', 'J6', '대리', '사원') 직급명
from employee;

-- 사원테이블에서 이름, 주민번호, 성별(남/여)조회
select
    emp_name 이름,
    emp_no 주민번호,
    decode(substr(emp_no, 8, 1), 1, '남', 3, '남', '여') 성별
from employee;

-- 선택함수 case
/*
타입1 (조건절로 처리)
    case
        when 조건절1 then 결과값1
        when 조건절2 then 결과값2
        ...
        [else 기본값]
    end

타입2(decode와 유사)
    case 조건절
        when 값1 then 결과값1
        when 값2 then 결과값2
        ...
        [else 기본값]
    end
*/
-- 타입1
select
    emp_name,
    emp_no,
    case
        when substr(emp_no, 8, 1) = 1 then '남'
        when substr(emp_no, 8, 1) = 3 then '남'
        when substr(emp_no, 8, 1) in('2', '4') then '여' -- '' 씌워주는 게 좋음
    end 성별,
    case
        when substr(emp_no, 8, 1) in('2', '4') then '여'
        else '남'
    end 성별
from employee;

-- 타입2
select
    emp_name,
    emp_no,
    case substr(emp_no, 8, 1)
        when '1' then '남'
        when '3' then '남'
        when '2' then '여'
        when '4' then '여'
    end 성별,
     case substr(emp_no, 8, 1)
        when '1' then '남'
        when '3' then '남'
        else '여'
    end 성별
from employee;

-- 사원테이블에서 생일조회
select
    emp_name,
    emp_no,
    to_char(to_date(substr(emp_no, 1, 6), 'yymmdd'), 'yyyy-mm-dd') "YY생일",
    to_char(to_date(substr(emp_no, 1, 6), 'rrmmdd'), 'rrrr-mm-dd') "RR생일",
    decode(substr(emp_no, 8, 1), '1', 1900, '2', 1900, 2000) + substr(emp_no, 1, 2) 출생년도,
    to_char(to_date(decode(substr(emp_no, 8, 1), '1', 1900, '2', 1900, 2000) + substr(emp_no, 1, 2) 
        || substr(emp_no, 3, 4), 'yyyymmdd'), 'yyyy-mm-dd') 생일
from employee;

-------------------------------------------------
-- 2. 그룹처리 함수
-------------------------------------------------
-- 그룹단위로 처리되는 함수
-- group by지정이 없다면 전체행을 하나의 그룹으로 처리
-- 일반 컬럼과 혼용하여 사용불가

-- sum(컬럼) : 총합 리턴
select
--    emp_name, -- 일반컬럼 혼용으로 오류!
    sum(salary),
    trunc(avg(salary))
from employee;

-- 컬럼값이 null인 경우, 그룹함수에서 제외됨
select
    sum(bonus)
from employee;

-- 실급여 합계구하기(가상컬럼)
select
    sum(salary + (salary * nvl(bonus, 0)))
from employee;

-- count(컬럼) : 해당 컬럼의 null이 아닌 행 수를 리턴
select
    count(bonus),
    count(dept_code),
    count(*) "전체 행 수"-- *는 한 행을 의미, 행이 존재하면 카운팅
from employee;

-- 전체에서 보너스가 null이 아닌 행 수
select count(*)
from employee
where bonus is not null;

-- sum을 이용해 bonus 받는 사원 조회
select
    sum(
        case
            when bonus is null then 0
            when bonus is not null then 1
        end
    ) "보너스받는 사원",
    count(bonus)
from employee;

-- max/min
-- 숫자, 날짜, 문자열(사전등재순)
select
    max(salary),
    min(salary),
    max(hire_date),
    min(hire_date),
    max(emp_name),
    min(emp_name)
from employee;

-- 1. 남자사원의 급여총합 조회
select
    to_char(sum(salary), 'fmL999,999,999') "남사원 급여합"
from employee
where substr(emp_no, 8, 1) in ('1', '3');

-- 2. 부서코드가 D5인 사원들의 보너스 총합 조회
select to_char(sum(salary * nvl(bonus, 0)), 'fmL999,999,999') 보너스금액합
from employee
where dept_code = 'D5';

-- 3. 남/여 사원의 급여총합/평균 조회
select
    to_char(sum(
        case
            when decode(substr(emp_no, 8, 1), '1', '남', '3', '남', '여') = '남' then salary
            else 0
        end
    ), 'fmL999,999,999') "남사원급여합",
     to_char(sum(
        case
            when decode(substr(emp_no, 8, 1), '1', '남', '3', '남', '여') = '여' then salary
            else 0
        end
    ), 'fmL999,999,999') "여사원급여합",
    to_char(avg(
        case
            when decode(substr(emp_no, 8, 1), '1', '남', '3', '남', '여') = '남' then salary
            else null
        end
    ), 'fmL999,999,999')"남사원급여평균",
    to_char(avg(
        case
            when decode(substr(emp_no, 8, 1), '1', '남', '3', '남', '여') = '여' then salary
            else null
        end
    ), 'fmL999,999,999')"여사원급여평균"
    
from employee;

-- 4. 전사원의 보너스율 평균을 소수점 둘째자리까지 반올림처리하여 출력
select
    round(avg(nvl(bonus, 0)),2) "전사원 보너스율 평균"
from employee;


-- ====================================================
-- DQL2
-- ====================================================
-------------------------------------------------------
-- GROUP BY
-------------------------------------------------------
-- 별도의 그룹지정이 없다면 그룹함수는 전체를 하나의 그룹으로 간주
-- 세부적 그룹지정을 group by절을 이용할 수 있다.

-- 부서별 급여 평균
select
    dept_code,
    avg(salary)
from employee
group by
    dept_code
order by dept_code;

-- 부서별 사원수를 조회
select
    nvl(dept_code, '인턴') 부서,
    count(*) 사원수
from employee
group by dept_code
order by 1;

-- 성별 사원수 조회
-- 가상컬럼을 기준으로 그룹핑 가능
select
    employee.*, --모든 컬럼을 쓰고싶다면 테이블명.* 으로 작성
    decode(substr(emp_no, 8, 1), '1', '남', '3', '남', '여') 성별
from employee;

select
    decode(substr(emp_no, 8, 1), '1', '남', '3', '남', '여') 성별,
    count(*) 사원수
from employee
group by decode(substr(emp_no, 8, 1), '1', '남', '3', '남', '여');

-- 부서별 직급별 인원수
select
    dept_code,
    job_code,
    count(*)
from employee
group by dept_code, job_code
order by 1, 2;

-- 부서별 성별 인원수
select
    nvl(dept_code, '인턴') 부서,
    decode(substr(emp_no, 8, 1), '1', '남', '3', '남', '여') 성별,
    count(*)
from employee
group by
    dept_code,
    decode(substr(emp_no, 8, 1), '1', '남', '3', '남', '여')
order by 1, 2;

-------------------------------------------------------
-- HAVING
-------------------------------------------------------
-- grouping한 결과행에 대해 조건절을 작성

-- 부서별 급여평균이 300만원 이상인 부서들만 조회(부서명, 급여평균)
select
    dept_code,
    avg(salary)
from employee
group by dept_code
having avg(salary) >= 3000000;

-- 직급별 인원수가 3명이상인 직급의 정보를 조회(직급코드, 인원수, 급여평균)
select
    job_code 직급코드,
    count(*) 인원수,
    trunc(avg(salary)) 급여평균
from employee
group by job_code
having count(*) >= 3
order by 1;

-- 사원테이블에서 J2직급을 제외하고 직급별 인원수가 3명이상인 직급의 정보를 조회(직급코드, 인원수, 급여평균)
-- 방법1. where절 사용
select
    job_code 직급코드,
    count(*) 인원수,
    trunc(avg(salary)) 급여평균
from employee
where job_code != 'J2'
group by job_code
having count(*) >= 3
order by 1;
-- 방법2. having절 사용
select
    job_code 직급코드,
    count(*) 인원수,
    trunc(avg(salary)) 급여평균
from employee
group by job_code
having job_code != 'J2' and count(*) >= 3
order by 1;

-- 소계를 처리하는 rollup
select
    nvl(job_code, '소계'),
    count(*)
from employee
group by
    rollup(job_code)
order by job_code;

select
    dept_code,
    grouping(dept_code) is_Rollup, -- 0이면 실제데이터, 1이면 rollup에 의해 생성된 데이터
    decode(grouping(dept_code), 0, nvl(dept_code, '인턴'), 1, '총계') "dept_code",
    count(*)
from employee
group by
    rollup(dept_code)
order by dept_code;

select
    decode(grouping(dept_code), 0, nvl(dept_code, '인턴'), 1, '총계') dept_code,
    decode(grouping(job_code), 0, job_code, 1, '소계') job_code,
    count(*)
from employee
group by
    rollup(dept_code, job_code)
order by
    dept_code, job_code;


-- ====================================================
-- JOIN
-- ====================================================
-- 정규화된 테이블과 테이블을 합쳐서 가상테이블(Relation)을 생성

-- join : 특정컬럼을 기준으로 행과 행을 연결(가로)
-- union : 동일한 컬럼을 가진 테이블 연결(세로)

-- join의 종류
/*
    1. Equi Join        : 동등조건(=)에 의해 연결 (대부분의 조인)
        - inner join(내부조인)
        - outer join(외부조인)
        - cross join
        - self join -- 이런게 있다~
        - multiple join -- 이런게 있다~
    2. Non-Equi Join    : 동등조건(=)이 아닌 조건(between and, in, not in ..)에 의해 연결
*/

-- join 문법
-- 1. ANSI 표준문법 : join, on  키워드 사용
-- 2. Oracle 전용문법 : ,콤마 사용

-- 송종기 사원의 부서명을 조회
-- 방법1.
-- 1. employee테이블에서 사원명이 송종기인 행의 dept_code 조회
-- 2. department테이블에서 해당 dept_code로 dept_title 조회
select dept_code
from employee
where emp_name = '송종기';

select dept_title
from department
where dept_id = 'D9';

-- 방법2
-- 조인으로 처리
select
    department.dept_title
from
    employee join department
        on employee.dept_code = department.dept_id
where
    employee.emp_name = '송종기';

-- 테이블 별칭 : as 사용불가
select
    d.dept_title
from
    employee e join department d
        on e.dept_code = d.dept_id
where
    e.emp_name = '송종기';

-------------------------------------------------------
-- EQUI JOIN
-------------------------------------------------------
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- INNER JOIN
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 내부 조인(교집합)
-- 왼쪽/오른쪽테이블의 일치하는 행만 조회
-- 기준컬럼이 null이면 제외, 상대테이블에서 매칭되는 행이 없으면 제외
-- inner 키워드 생략가능

-- employee에서 dept_code가 null인 사원 2행 제외
-- department에서 employee에 참조되지 않은 D3, D4, D7 3행 제외
select *
from
    employee e inner join department d
        on e.dept_code = d.dept_id; -- 22
        
-- [oracle 전용]
select *
from employee e, department d
where e.dept_code = d.dept_id;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- OUTER JOIN
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 외부조인 left outer join, right outer join
-- outer키워드 생략가능

-- 1. left outer join
-- 왼쪽테이블의 모든 행 포함, 오른쪽테이블은 조인조건을 만족하는 행만 포함.
-- 우측테이블에 매칭되는 행이 없다면 모두 null로 채워서 처리
select *
from
    employee e left outer join department d
        on e.dept_code = d.dept_id; -- 24(=22+2)행

-- [oracle 전용]
-- 외부조인 (+)를 상대테이블 컬럼에 추가
select *
from
    employee e, department d
where
    e.dept_code = d.dept_id(+);

-- 2. right outer join
select *
from
    employee e right outer join department d
        on e.dept_code = d.dept_id; -- 25(=22+3)행

-- [oracle 전용]
select *
from
    employee e, department d
where
    e.dept_code(+) = d.dept_id;

-- 3. full outer join
select *
from
    employee e full outer join department d
        on e.dept_code = d.dept_id; -- 27(=22+2+3)행

-- [oracle 전용문법 없음]


-- 사원명, 직급명(job.job_name)
-- employee.job_code ---- job.job_code
-- 1. 기준컬럼 null이면 제외 > 해당없음
-- 2. 상대테이블에서 매칭되는 행이 없으면 제외 > 해당없음
-- inner join, left/right outer join 모두 동일한 조회 결과
-- inner join이 더 효율적이기때문에 이 경우 inner join 사용
-- 동일한 컬럼명을 사용하는 경우, 테이블명이나 별칭을 필수로 사용
select
    e.emp_name,
    e.job_code,
    j.job_name
from employee e join job j
    on e.job_code = j.job_code; 

-- 테이블 별칭 : 가급적 명시하여 사용하는 습관 들이기
select *
from
    employee join department
        on dept_code = dept_id; -- 컬럼명이 다르기때문에 테이블명 없이도 정상 조회

select
    e.emp_name,
    j.job_name
from employee join job
    on job_code = job_code; -- 어느 테이블의 컬럼인지 알 수 없어서 오류 발생

-- 동일한 컬럼명을 사용하는 경우, on조건절 대신 using절 사용가능
-- using절로 사용한 컬럼은 별칭으로 접근불가
select
    *
--    e.* -- 오류
from
    employee e join job j
        using(job_code);


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- CROSS JOIN
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 상호조인
-- Cartesian Product(카테시안곱) - 모든 경우의 수
-- 좌우측테이블이 상대테이블의 행과 만날 수 있는 모든 경우의 수
select *
from
    employee e cross join department d; -- 216(=24*9)행

-- [oracle 전용]
select *
from employee e, department d;


-- 평균급여와 각 사원의 급여차
select
    emp_name,
    salary - avg(salary) -- 오류! 그룹함수는 일반컬럼과 쓸 수 없다
from
    employee;

select
    emp_name,
    salary,
    salary - avg_sal
from
    employee e cross join (select trunc(avg(salary)) avg_sal from employee);

-- 사원정보 조회(사원명, 부서코드, 급여, 부서별 평균급여)
select
    emp_name,
    nvl(e.dept_code, '인턴') dept_code,
    to_char(e.salary, 'fmL999,999,999') salary,
    to_char("부서별 평균급여", 'fmL999,999,999') "부서별 평균급여"
from
    employee e left join (select
                                trunc(avg(salary)) "부서별 평균급여", dept_code
                            from employee
                            group by dept_code) tmp
        on nvl(e.dept_code, 'D0') = nvl(tmp.dept_code,'D0')
order by e.dept_code;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SELF JOIN
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 같은 테이블을 연결하는 조인

-- 사원명, 관리자명을 조회
-- manager_id가 null인 사원, 관리자가 아닌 사원은 제외
select
    e1.emp_id 사원번호,
    e1.emp_name 사원명,
    e1.manager_id 관리자번호,
--    e2.emp_id 관리자번호, -- 위와 동일
    e2.emp_name 관리자명
from
    employee e1 left join employee e2
        on e1.manager_id = e2.emp_id;

-- [oracle 전용]
select
    e1.emp_id 사원번호,
    e1.emp_name 사원명,
    e1.manager_id 관리자번호,
    e2.emp_name 관리자명
from employee e1, employee e2
where e1.manager_id = e2.emp_id(+);


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- MULTIPLE JOIN
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 여러 테이블을 조인

select * from employee; -- dept_code
select * from department; -- dept_id, location_id
select * from location; --local_code, national_code
select * from nation; -- national_code

-- 사원명(employee.emp_name), 부서명(department.dept_title)
-- , 지역명(location.local_name), 국가명(nation.national_name)
select
    e.emp_name,
    d.dept_title,
    l.local_name,
    n.national_name
from
    employee e
        join department d
            on e.dept_code = d.dept_id
        join location l
            on d.location_id = l.local_code
        join nation n
            on l.national_code = n.national_code ;
-- 인턴 포함
-- left join으로 추가된 행이 누락되지 않도록 연속적으로 left join처리해야함
-- join되는 순서가 중요
select
    e.emp_name,
    d.dept_title,
    l.local_name,
    n.national_name
from
    employee e
        left join department d
            on e.dept_code = d.dept_id
        left join location l
            on d.location_id = l.local_code
        left join nation n
            on l.national_code = n.national_code ;

-- 사원명(employee.emp_name), 직급명(job.job_name), 부서명(department.dept_title)
-- , 지역명(location.local_name), 국가명(nation.national_name)
select
    e.emp_name,
    j.job_name,
    d.dept_title,
    l.local_name,
    n.national_name
from
    employee e
        join job j
            on e.job_code = j.job_code
        left join department d
            on e.dept_code = d.dept_id
        left join location l
            on d.location_id = l.local_code
        left join nation n
            on l.national_code = n.national_code ;

-- [oracle 전용]
select *
from
    employee e, department d, location l, nation n
where
    e.dept_code = d.dept_id(+)
    and d.location_id = l.local_code(+)
    and l.national_code = n.national_code(+);


-- 직급 대리, ASIA지역 근무 직원 조회(사번, 이름, 직급명, 부서명, 근무지역명, 급여)
select
    emp_id 사번,
    emp_name 이름,
    j.job_name 직급명,
    d.dept_title 부서명,
    l.local_name || n.national_name 근무지역명,
    to_char(salary, 'fm999,999,999') 급여
from
    employee e
        join job j
            using(job_code)
        left join department d
             on e.dept_code = d.dept_id
        left join location l
            on d.location_id = l.local_code
        left join nation n
            on l.national_code = n.national_code 
where
    j.job_name = '대리' and l.local_name like 'ASIA%';

-- [oracle 전용]
select
    emp_id 사번,
    emp_name 이름,
    j.job_name 직급명,
    d.dept_title 부서명,
    l.local_name || n.national_name 근무지역명,
    to_char(salary, 'fm999,999,999') 급여
from
    employee e, department d, location l, nation n, job j
where
    e.job_code = j.job_code
    and e.dept_code = d.dept_id(+)
    and d.location_id = l.local_code(+)
    and l.national_code = n.national_code(+)
    and j.job_name = '대리' and l.local_name like 'ASIA%';

-------------------------------------------------------
-- NON-EQUI JOIN
-------------------------------------------------------
-- 동등비교(=)가 아닌 조인조건을 사용하는 경우
select * from employee;
select * from sal_grade;

-- employee.salary를 통해 급여등급 조회하기
select
    e.emp_name,
    e.salary,
    s.*
from
    employee e join sal_grade s
        on e.salary between s.min_sal and s.max_sal;

-- [oracle 전용]
select
    e.emp_name,
    e.salary,
    s.*
from employee e, sal_grade s
where e.salary between s.min_sal and s.max_sal;



-- ====================================================
-- SET OPERATOR
-- ====================================================
-- 여러 결과집합을 세로로 연결 후 하나의 가상테이블 생성

-- 조건
-- 1. SELECT절의 컬럼수가 동일
-- 2. SELECT절의 해당컬럼의 자료형이 상호호환 가능 (char-varcahr2 상호호환)
-- 3. 컬럼명이 다른 경우, 첫번째 결과집합의 컬럼명 사용
-- 4. ORDER BY절은 마지막 결과집합에 한번만 사용가능

select
    'a', 123, sysdate
from
    dual
union
select
    'b', 456, sysdate
from
    dual
order by 1 desc;

-- 연산자 종류
/*
    1. union 합집합 - 두 결과집합을 합친 후 중복제거, 첫번째 컬럼기준 오름차순 정렬 
    2. union all 합집합 - 두 결과집합을 모두 포함
    3. intersect 교집합
    4. minus 차집합
*/

-- 부서코드 D5인 사원 조회
-- salary가 300만 이상인 사원 조회
-- union all : 두개의 결과집합을 추가작업 없이 연결. 작업속도 빠름.
-- union : 두개의 결과집합을 합친 후 중복된 행 제거, 첫번째 컬럼 기준 오름차순 정렬. 작업속도 느림
select
    emp_id
    , emp_name
    , dept_code
    , salary
from employee
where dept_code = 'D5' -- 6행
union
select
    emp_id
    , emp_name
    , dept_code
    , salary
from employee
where salary >= 3000000; -- 9행

-- intersect : 중복된 행만 출력, 모든 컬럼값이 같을 때 중복으로 취급.
-- minus : 첫번째 결과집합에서 두번째 결과집합과의 중복된 행을 제거 후 출력 
select
    emp_id
    , emp_name
    , dept_code
    , salary
from employee
where dept_code = 'D5' -- 6행
minus
select
    emp_id
    , emp_name
    , dept_code
    , salary
from employee
where salary >= 3000000; -- 9행



-- 판매데이터 관리
create table tb_sales(
    p_name varchar2(50),
    pcount number,
    sale_date date
);
--drop table tb_sales;

-- 두달전 판매 데이터
insert into tb_sales values('버터링', 10, add_months(sysdate, -2));
insert into tb_sales values('칸쵸', 15, add_months(sysdate, -2) + 1);
insert into tb_sales values('와클', 10, add_months(sysdate, -2) + 2);
insert into tb_sales values('버터링', 30, add_months(sysdate, -2) + 5);
insert into tb_sales values('포카칩', 10, add_months(sysdate, -2) + 7);
-- 한달전 판매 데이터
insert into tb_sales values('스윙칩', 10, add_months(sysdate, -1));
insert into tb_sales values('초코칩쿠키', 15, add_months(sysdate, -1) + 1);
insert into tb_sales values('와클', 10, add_months(sysdate, -1) + 2);
insert into tb_sales values('버터링', 20, add_months(sysdate, -1) + 5);
insert into tb_sales values('포카칩', 30, add_months(sysdate, -1) + 7);
insert into tb_sales values('와클', 10, add_months(sysdate, -1) + 10);
-- 이번달 판매 데이터
insert into tb_sales values('스윙칩', 10, sysdate - 10);
insert into tb_sales values('초코칩쿠키', 22, sysdate - 9);
insert into tb_sales values('와클', 10, sysdate - 7);
insert into tb_sales values('버터링', 15, sysdate - 5);
insert into tb_sales values('포카칩', 3, sysdate - 2);
insert into tb_sales values('야채타임', 15, sysdate - 1);

-- 테이블 확인
select * from tb_sales;

-- 2달 전의 판매내역 조회
-- 1달후, 내년, 10년후에도 동일하게 2달 전을 조회
select *
from tb_sales
where
    to_char(add_months(sysdate, -2), 'yyyymm') = to_char(sale_date, 'yyyymm');

-- 테이블쪼개기
-- tb_sales에는 현재달의 판매데이터만 관리, 지난달데이터는 tb_sales_yyyymm테이블을 별도 생성 후 관리
-- 두달전
create table tb_sales_202201
as
select *
from tb_sales
where
    to_char(add_months(sysdate, - 2), 'yyyymm') = to_char(sale_date, 'yyyymm');
select * from tb_sales_202201; -- 조회
-- 한달전
create table tb_sales_202202
as
select *
from tb_sales
where
    to_char(add_months(sysdate, - 1), 'yyyymm') = to_char(sale_date, 'yyyymm');
select * from tb_sales_202202; -- 조회

-- 기존 테이블에서 쪼개진 데이터 삭제
--delete from tb_sales
--where to_char(add_months(sysdate, - 2), 'yyyymm') = to_char(sale_date, 'yyyymm');
--delete from tb_sales
--where to_char(add_months(sysdate, - 1), 'yyyymm') = to_char(sale_date, 'yyyymm');

select * from tb_sales;
commit; -- f11 키로 대체가능

-- 지난 3개월 판매내역 데이터를 조회
select *
from tb_sales_202201
union
select *
from tb_sales_202202
union
select *
from tb_sales;

-- 지난 3개월의 제품별 판매량 조회
select
    p_name 제품명,
    sum(pcount) 판매량
from (
        select *
        from tb_sales_202201
        union
        select *
        from tb_sales_202202
        union
        select *
        from tb_sales
    )
group by p_name
order by 2 desc; -- 많이 팔린 순



-- ====================================================
-- SUB QUERY
-- ====================================================
-- 하나의 SQL문 안에 포함된 또 하나의 SQL문
-- main query하위에 subquery가 포함되어 있음
-- main query실행 도중 subquery 실행하고, 그 결과를 main query에 전달

-- 유의사항
-- 1. subquery는 반드시 소괄호로 묶여야 한다.
-- 2. 비교연산 시 우항에 작성할 것.
-- 3. order by 문법 지원하지 않음.

-- 서브쿼리의 유형
/*
    1. 단일행 단일컬럼 (1행 1열)
    2. 다중행 단일컬럼 (n행 1열)
    3. 다중열(단일행/다중행) (n행 m열)
    4. 상관 - 메인쿼리에서 값을 전달받아 처리
    5. 스칼라 - select절에 사용된 단일값 상관서브쿼리
    6. 인라인뷰 - from절에 사용된 서브쿼리
*/


-- 노옹철 사원의 관리자이름을 조회

-- 방법1
-- step1. 관리자 아이디 조회
select manager_id
from employee
where emp_name = '노옹철';
-- step2. 관리자 아이디의 사원정보 조회
select emp_name
from employee
where emp_id = '201';

-- 방법2
select emp_name
from employee
where emp_id = (
            select manager_id
            from employee
            where emp_name = '노옹철');


-------------------------------------------------------
-- 단일행 단일컬럼 서브쿼리
-------------------------------------------------------
-- 서브쿼리 조회결과가 1행 1열인 경우

-- 전 직원의 평균 급여보다 많은 급여를 받는 사원 조회(사번, 이름, 직급코드, 급여)
select
    emp_id,
    emp_name,
    dept_code,
    salary,
    trunc((select avg(salary) from employee)) 평균급여
from employee
where
    salary > (select avg(salary) from employee);

-- 윤은해와 같은 금액의 급여를 받는 사원을 조회(사번 사원명 급여)
select emp_id, emp_name, salary
from employee
where
    salary = (select salary from employee where emp_name = '윤은해')
    and emp_name != '윤은해';

-- 사원테이블에서 급여가 최대/최소인 사원 조회(사번 사원명 급여)
select emp_id, emp_name, salary
from employee
where
    salary in ((select max(salary) from employee), (select min(salary) from employee));

-------------------------------------------------------
-- 다중행 단일컬럼 서브쿼리
-------------------------------------------------------
-- 서브쿼리 조회결과가 1열n행일 때 서브쿼리
-- in | not in, any(some), all, exists | not exists 연산자와 함께 사용가능

-- in : 값목록에 포함되어있는지 검사
-- in(값1, 값2, 값3 ...) - 인자위치에 다중행 서브쿼리를 넣어 사용가능

-- 송중기 하이유 사원이 속한 부서원 조회
select
    emp_name,
    dept_code
from employee
where
    dept_code in (
                select
                    dept_code
                from employee
                where emp_name in ('송종기', '하이유'));

-- 차태연, 박나라, 이오리사원과 같은 직급 사원 조회 (사원명, 직급명(직급코드))
select
    emp_name 사원명,
    job_name || '(' || job_code || ')' "직급명(직급코드)"
from employee e join job j
    using(job_code)
where
    job_code in (
                select job_code
                from employee
                where
                    emp_name in ('차태연', '박나라', '이오리') );

-------------------------------------------------------
-- 다중열 서브쿼리
-------------------------------------------------------
-- 서브쿼리의 결과가 n열 m행(1행이상)인 경우

-- 퇴사한 직원과 같은 부서, 같은 직급에 해당하는 사원 조회(이름, 직급코드, 부서코드)
-- = 연산자인 경우 서브쿼리 리턴결과가 딱 1행일 때만 처리 할 수 있다.
-- in 연산자인 경우 서브쿼리 리턴결과 1~n행 일때 처리 할 수 있다.
select
    emp_name, job_code, dept_code
from employee
where (dept_code, job_code) in (
            select
                dept_code, job_code
            from employee
            where quit_yn = 'Y'
        );

select * from employee;
-- 퇴사처리
update employee
set
    quit_date = sysdate,
    quit_yn = 'Y'
where
    emp_id = '221';


-- 직급별 최소 급여를 받는 사원 조회 (이름, 직급코드, 급여)
select
    emp_name 이름, 
    job_code 직급코드,
    salary 급여
from employee
where
    (job_code, salary) in (
        select job_code, min(salary)
        from employee
        group by job_code)
order by job_code;
