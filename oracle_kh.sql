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


-------------------------------------------------------
-- 상관 서브쿼리
-------------------------------------------------------
-- 상관(상호연관)
-- 메인쿼리의 값을 전달받아 서브쿼리를 수행하고, 그 결과값을 반환
-- 일반서브쿼리와는 다르게 단독실행이 불가능

-- 직급별 평균급여보다 많은 급여를 받는 사원 조회
-- JOIN (직급별 평균급여 가상테이블) 사용
select e.*, tmp.avg_sal_by_job
from
    employee e
        join (select job_code, avg(salary) avg_sal_by_job
                    from employee
                    group by job_code) tmp
            on e.job_code = tmp.job_code
where e.salary > tmp.avg_sal_by_job;

-- 상관 서브쿼리로 처리
select
    emp_name, job_code, salary
from
    employee e
where
    salary > (select avg(salary)
                from employee
                where job_code = e.job_code);

-- 부서별  평균급여보다 많은 급여를 받는 사원 조회(인턴포함)
select
    e.emp_name,
    nvl(e.dept_code, '인턴'),
    e.salary
--    , trunc((select avg(salary)
--        from employee 
--        where nvl(dept_code,'D0') = nvl(e.dept_code, 'D0'))) avg_sal -- 스칼라 서브쿼리 select 절의 상관 서브쿼리
from employee e
where salary > (select avg(salary)
                from employee 
                where nvl(dept_code,'D0') = nvl(e.dept_code, 'D0'));

-- exists (sub-query)
-- 서브쿼리의 결과집합이 1행 이상인 경우 true로 처리, 0행인 경우 false처리
select *
from employee
where
--    1 = 1; -- 무조건 true
    1 = 0; -- 무조건 false

select *
from employee
where 
--    exists (select * from employee); -- 조회된 행이 있으므로 true 처리
    exists (select * from employee where 1 = 0); -- 조회된 행이 없으므로 false 처리
    

-- 실제 부서원이 존재하는 부서만 조회
select *
from
    department d
where
    exists (
        select * 
        from employee 
        where dept_code = d.dept_id
    );

-- 실제 부서원이 존재하지 않는 부서만 조회
-- 서브쿼리의 행이 존재하면 false, 서브쿼리의 행이 존재하지 않으면 true -> 결과집합에 포함
select *
from
    department d
where
    not exists (
        select 1 -- 실제 데이터는 중요하지 않기때문에 임의 값으로 처리 가능
        from employee 
        where dept_code = d.dept_id
    );

-- 관리자 사원 조회(부하직원이 manager_id가 관리 자 사원의 emp_id를 가리킨다)
-- 관리자 emp_id가 부하직원의 manager_id로 참조되는 사원 조회
select *
from employee e
where
    exists (
        select *
        from employee
        where manager_id = e.emp_id
    );

-- not exists 활용해 최대/최소에 해당하는 행 조회
select *
from employee e
where
    not exists (
        select * 
        from employee 
        where salary > e.salary
    ) -- 최고 급여 수령자 조회
    or not exists (
        select * 
        from employee 
        where salary < e.salary
    ) -- 최저 급여 수령자 조회
;

-------------------------------------------------------
-- SCALA 서브쿼리
-------------------------------------------------------
-- scala값은 단일값
-- select 절에 사용하는 결과값이 하나(1행1열)인 상관서브쿼리

-- 사번, 이름, 관리자사번, 관리자명
-- self-join으로 처리
select
    e.emp_id 사번,
    e.emp_name 이름,
    e.manager_id 관리자사번,
    m.emp_name 관리자명
from
    employee e left join employee m
        on e.manager_id = m.emp_id ;

-- 스칼라 서브쿼리로 처리
select
    emp_id,
    emp_name,
    manager_id,
    (select emp_name from employee where emp_id = e.manager_id) manager_name
from employee e;

-- 사원명, 부서명, 급여, 부서별 평균급여 조회(scala서브쿼리)
select
    emp_name 사원명,
    nvl((select dept_title from department where dept_id = e.dept_code),'인턴') 부서명,
    salary 급여,
    (
        select trunc(avg(salary)) avg_sal
        from employee
        where nvl(dept_code, 'D0') = nvl(e.dept_code, 'D0')
    ) "부서별 평균급여"
from employee e;


-------------------------------------------------------
-- INLINE VIEW
-------------------------------------------------------
-- from 절에 사용한 subquery
/*
    view란?
    실제테이블을 주어진 view를 통해 제한적으로 사용가능하도록 함.
    1. inline view (1회용)
    2. stored view - 별도의 객체로 저장해 재사용 가능
*/

-- 사원테이블에서 여사원의 사번, 사원명, 부서코드, 성별 조회
-- 방법1.
select
    emp_id,
    emp_name,
    dept_code,
    decode(substr(emp_no, 8, 1), '2', '여', '4', '여', '남') gender
from employee
where decode(substr(emp_no, 8, 1), '2', '여', '4', '여', '남') = '여';

-- 방법2. 인라인뷰
select
    emp_id,
    emp_name,
    dept_code,
    gender
from(
    select
        e.*,
        decode(substr(emp_no, 8, 1), '2', '여', '4', '여', '남') gender
    from employee e
)
where gender = '여';

-- 입사년도가 1990~1999년인 사원 조회(사번, 사원명, 입사년도)
select
    emp_id,
    emp_name,
    hire_year
from(
    select
        e.*,
        extract(year from hire_date) hire_year
    from employee e
)
where hire_year between 1990 and 1999;

-- 사원 중에 30/40대(30~49) 여자사원의 사번, 부서명, 성별, 나이를 조회 -- 이거 오류남 다시해보기
select
    emp_id,
    nvl((
        select dept_title
        from department 
        where e.dept_code = dept_id)
    , '인턴') dept_title,
    emp_name,
    gender,
    age
from(
    select
        e.*,
        decode(substr(emp_no, 8, 1), '2', '여', '4', '여', '남') gender,
        (extract(year from sysdate) -
            (decode(substr(emp_no, 8, 1), '1', 1900, '2', 1900, 2000) + substr(emp_no,1,2)) + 1
        ) age
    from employee e
)
where
    gender = '여'
    and age between 30 and 49;


-- ====================================================
-- 고급쿼리
-- ====================================================
-------------------------------------------------------
-- TOP-N 분석
-------------------------------------------------------
-- 특정 컬럼 기준으로 정렬 후 에 가장 앞선 n개의 행ㄹ만 결과집합에 담아 리턴

-- rownum
-- 테이블생성 후 각 행이 insert될 때 oracle에서 자동으로 부여하는 각 행에 대한 일련번호
-- 한번 부여되면 변경불가
-- where절에 새로운 조건이 추가되었을때, inline-view를 사용했을때 새로 부여됨
select
    rownum,
    e.*
from employee e
where dept_code in ('D5', 'D6');

-- 회사에서 급여가 높은 TOP-5 조회
-- 1. 급여내림차순 정렬
-- 2. inline-view(rownum새로부여)
-- 3. rownum 필터링
select
    rownum,
    e.*
from(
    select emp_name, salary
    from employee
    order by salary desc
) e
where rownum between 1 and 5;

-- 최근 입사한 순으로 5명 조회
select
    rownum,
    e. *
from(
    select emp_name, hire_date
    from employee
    order by hire_date desc
) e
where rownum between 1 and 5;

-- 직급이 대리인 사원중에서 연봉상위 3명 조회
select 
    rownum, e.*
from(
    select
        emp_name,
        j.job_name,
        (salary + (salary * nvl(bonus, 0)))*12 연봉
    from employee join job j
        using(job_code)
    where j.job_name = '대리'
    order by 3 desc
) e
where rownum <= 3;


-- 부서별 급여평균 top3 조회(부서명, 평균급여)
select
    (select dept_title from department d where d.dept_id = e.dept_code) 부서명,
    e.avg_sal_by_dept 평균급여
from (
    select dept_code, trunc(avg(salary)) avg_sal_by_dept
    from employee
    group by dept_code
    order by trunc(avg(salary)) desc
) e
where rownum <= 3;

-- 급여 상위 랭킹 6 ~ 10위 조회
-- rownum은 where절이 완전히 끝났을때 부여 또한 끝난다.
-- 1부터 시작하지 않고 offset이 있는 경우 inline-view가 한 레벨 더 필요
select *
from(
    select
        rownum rnum, e.*
    from(
        select emp_name, salary
        from employee
        order by salary desc
    ) e
)
where rnum between 6 and 10;

-- whith절
-- inlineview에 이름을 붙여서 재사용 가능하도록 만드는 구문

-- 부서별 급여평균 top3 조회(부서명, 평균급여)
with some_view
as (
    select dept_code, trunc(avg(salary)) avg_sal_by_dept
    from employee
    group by dept_code
    order by trunc(avg(salary)) desc
)
select
    (select dept_title from department d where d.dept_id = e.dept_code) 부서명,
    e.avg_sal_by_dept 평균급여
from ( some_view ) e
where rownum <= 3;


-------------------------------------------------------
-- WINDOW FUNCTION
-------------------------------------------------------
-- 행과 행간의 관계를 쉽게 파악/정의하기위한 ANSI표준함수
-- select절에서만 사용가능
-- 순위관련처리, 집계관련처리, 순서관련처리, 비율/통계관리처리

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 순위관련 윈도우함수
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
    window_function(args) over([partition by절][order by절][windowing절])
    - args : 함수인자(컬럼명). 0~n개
    - partition by 절 : 전체집합을 다시 그룹핑하기위한 구문
    - order by 절 : 행간의 정렬
    - windowing 절 : 대상행을 지정
*/

-- rank() over()
-- 중복된 값이 있다면 중복된 만큼 건너뛰고 순위부여
-- dense_rank() over()
-- 중복된 값이 있어도 중복된 만큼 건너뛰지 않고 순위부여
select
    emp_name,
    salary,
    rank() over(order by salary desc) rank,
    dense_rank() over(order by salary desc) rank
from
    employee;

-- top-n분석에 활용
select *
from (
    select
        emp_name,
        salary,
        rank() over(order by salary desc) rank
    from
        employee
)
where rank between 1 and 5;

-- 부서별 급여순위를 조회
select
    emp_name,
    dept_code,
    rank() over(partition by dept_code order by salary desc) rank_by_dept,
    rank() over(order by salary desc) rank
from employee
order by dept_code;

-- 부서별 입사순서 조회(사원명, 부서명, 입사일, 부서별입사순번)
select
    emp_name 사원명,
    nvl((select dept_title from department d where e.dept_code = d.dept_id), '인턴') 부서명,
    hire_date 입사일,
    rank() over(partition by dept_code order by hire_date) 부서별입사순번,
    dense_rank() over(partition by dept_code order by hire_date) rank,
    row_number() over(partition by dept_code order by hire_date) rank
from employee e
order by dept_code;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 집계처리 윈도우함수
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 집계/누계 관련 처리를 하는 윈도우 함수

-- sum() over()
-- 그룹함수와 일반컬럼은 같이 쓸 수 없지만, 윈도우함수 일반컬럼은 함께 사용가능.
select
    emp_name,
    dept_code,
    salary,
    sum(salary) over() 전사원급여합,
    trunc(salary / sum(salary) over() * 100, 1) "전체급여대비%",
    sum(salary) over(partition by dept_code) 부서별급여합,
    sum(salary) over(partition by dept_code order by salary) 부서별누계
from employee;

-- 판매테이블 지난 3개월 제품별 누계
select
    s.*,
    sum(pcount) over(partition by p_name order by sale_date) "제품별 누계"
from(
    select * from tb_sales_202201
    union all
    select * from tb_sales_202202
    union all
    select * from tb_sales
) s;

-- 사원정보 조회(사번, 사원명, 부서코드, 급여, 부서별평균급여, 전체사원평균급여, 부서별인원)
select
    emp_id 사번,
    emp_name 사원명,
    nvl(dept_code, '인턴') 부서코드,
    to_char(salary, 'fm999,999,999') 급여,
    to_char(trunc(avg(salary) over(partition by dept_code)), 'fm999,999,999') 부서별평균급여,
    to_char(trunc(avg(salary) over()), 'fm999,999,999') 전체사원평균급여,
    count(*) over(partition by dept_code) 부서별인원
from employee
order by dept_code;


-- ====================================================
-- DML
-- ====================================================
-- Data Manipulation Language 데이터 조작어
-- 테이블의 데이터를 조작하는 명령어 모음
-- insert / update / delete / select
-- insert, update, delete : 처리된 행의 개수를 리턴
-- 명령어 실행으로는 DB에 실제 반영되지 않으므로, TCL commit명령어를 실행해야한다.
-- rollback처리하면 마지막 commit시점으로 복귀

-------------------------------------------------------
-- INSERT
-------------------------------------------------------
-- 특정 테이블에 새로운 행(row/record)을 추가하는 명령어
-- 정상실행 시 테이블에 행이 추가됨

/*
    문법1 - 컬럼명을 지정하지 않는 경우(모든 컬럼을 테이블에 정의된 순서로 작성)
        insert into 테이블명
        values(컬럼1값, 컬럼2값 ... );
    
    문법2 - 컬럼명을 지정하는 경우(지정한 컬럼만 데이터를 작성. not null컬럼은 생략불가)
        insert into 테이블명 (컬럼명1, 컬럼명2, ... )
        values(컬럼1값, 컬럼2값 ... );
*/

create table sample(
    code number,
    name varchar2(100) not null,
    nickname varchar2(100) default '홍길동',
    email varchar2(100) default 'honggd@gmail.com' not null,
    enroll_date date default sysdate
);

-- 데이터추가
insert into
    sample
values(
    123, '고길동', '미스터고고', 'go@gmail.com', default
);
insert into
    sample
values(
    123, '고길동', null, 'go@gmail.com', default
);
select * from sample;

-- 자료형 일치하지 않을때 ORA-01722: 수치가 부적합합니다
-- 컬럼수가 맞지 않는 경우 ORA-00947: 값의 수가 충분하지 않습니다
-- not null 컬럼에 null값 대입하는 경우 ORA-01400: NULL을 ("KH"."SAMPLE"."NAME") 안에 삽입할 수 없습니다
-- 지정한 자료형 크기보다 큰 값을 추가 할 경우 ORA-12899: "KH"."SAMPLE"."NAME" 열에 대한 값이 너무 큼(실제: 126, 최대값: 100)
insert into
    sample
values(
    '가나다', '고길동', '미스터고고', 'go@gmail.com', default
);

insert into
    sample
values(
    '고길동', '미스터고고', 'go@gmail.com', default
);

insert into
    sample
values(
    123, null, '미스터고고', 'go@gmail.com', default
);

insert into
    sample
values(
    123, '고길동동도도도도도도도도도도도도도도도도도도도도도도도도도도도도도도도도도도도도도도', '미스터고고', 'go@gmail.com', default
);

-- 생략한 값은 null이 대입되거나, default값이 지정된 경우 default값으로 처리
insert into
    sample (code, name, email)
values(
    345, '신사', 'sinsa@gmail.com'
);
select * from sample;

-- not null 컬럼은 생략할 수 없다.
-- ORA-01400: NULL을 ("KH"."SAMPLE"."NAME") 안에 삽입할 수 없습니다
-- not null이어도 default값이 지정된 경우는 생략할 수 있다.
insert into
    sample (code, email)
values(
    345, 'sinsa@gmail.com'
);
insert into
    sample (code, name)
values(
    555, '세종'
);
select * from sample;


-- 데이터 몇개 추가해보기
insert into sample
values(
    600, '김뫄뫄', '뫄뫄라네','kmm6@naver.com', '22/02/16'
);
insert into
    sample(code, name, nickname, email)
values(
    603, '박솨솨', '솨솨박','sspark@gmail.com'
);
insert into sample
values(
    605, '김탁구', '제빵왕','bakingkim@gmail.com', '21/07/04'
);
insert into
    sample(name, code)
values(
    '홍감자', 609
);
commit;


-- ex_employee 생성!
-- subquery 이용해 table을 생성하면, not null을 제외한 제약조건, 기본값은 모두 제거된다.
create table ex_employee
as
select *
from employee;

select * from ex_employee;

-- not null 확인
desc employee;
-- 기본값 확인
select *
from user_tab_cols
where table_name = 'EMPLOYEE'; -- 이때는 테이블명 대문자로 작성할것

desc ex_employee;
-- 기본값 확인
-- 설정값까지 동일하게 생성되지 않았음을 확인 가능
select *
from user_tab_cols
where table_name = 'EX_EMPLOYEE';

alter table ex_employee
add constraint pk_ex_employee primary key(emp_id) -- emp_id 기본키지정(식별자컬럼)
modify quit_yn default 'N' -- 기본값 지정
modify hire_date default sysdate; -- 기본값 지정

-- 데이터 추가
-- 301 함지민 - 모든 컬럼에 데이터 추가(문법1)
-- 302 김태리 - not null 컬럼만 데이터 추가(문법2)
insert into ex_employee
values(
    '301', '함지민', '941223-2233445', 'hjm94@gmail.com', '01033327575',
    'D2', 'J4', 'S5', 2200000, null, '204', '22/01/23', null, default
);

insert into
    ex_employee(emp_id, emp_name, emp_no, job_code, sal_level)
values('302', '김태리', '930708-2123456', 'J5', 'S6');

select * from ex_employee;

-- 서브쿼리를 이용한 insert
create table ex_employee_info(
    emp_id char(3),
    emp_name varchar2(30),
    email varchar2(100)
);

insert into ex_employee_info(
    select
        emp_id, emp_name, email
    from
        ex_employee
);

select * from ex_employee_info;

-- ex_employee_manager 테이블 생성
-- 사번, 사원명, 매니저사번, 매니저명
create table ex_employee_manager(
    emp_id char(3),
    emp_name varchar2(20),
    manager_id char(3),
    manager_name varchar2(20)
);

insert into ex_employee_manager(
    select
        e.emp_id,
        e.emp_name,
        e.manager_id,
        (select emp_name from employee where e.manager_id = emp_id)
    from
        employee e
);
select * from ex_employee_manager;

-- 특정 테이블의 데이터를 여러 테이블에 동시에 insert 하기
create table ex_employee_hire_date(
    emp_id char(3),
    emp_name varchar2(20),
    hire_date date
);
create table ex_employee_salary(
    emp_id char(3),
    emp_name varchar2(20),
    salary number
);

-- insert all
insert all
    into ex_employee_salary values(emp_id, emp_name, salary)
    into ex_employee_hire_date values(emp_id, emp_name, hire_date)
select
    emp_id, emp_name, salary, hire_date
from
    ex_employee ;

select * from ex_employee_hire_date;
select * from ex_employee_salary;


-------------------------------------------------------
-- UPDATE
-------------------------------------------------------
-- 특정 행을 찾고, 해당 행의 컬럼값을 변경
-- 처리이후 행 수의 변화는 없음
-- 요청 후 수정된 행의 수를 반환

-- 205번 사원의 급여를 100,000원 인상, 직급은 J2로 변경
select *
from employee
where emp_id = '205';

update
    ex_employee
set
    job_code = 'J4',
    salary = salary + 100000 -- 복합대입연산자 없음
where
    emp_id = '205';

commit;
--rollback;

-- where절에 행이 여러개 조회되면 동시에 여러행 수정 가능
-- D5부서원의 급여를 10% 인상
select * from ex_employee where dept_code = 'D5';

update
    ex_employee
set
    salary = salary * 1.1
where
    dept_code = 'D5';

-- 임시환 사원의 직급을 과장으로 변경
select * from ex_employee where emp_name = '임시환'; 
update
    ex_employee
set
    job_code = (select job_code from job where job_name = '과장')
where
    emp_name = '임시환';

-- where절에 조건컬럼은 식별자 컬럼을 사용하는 것이 좋다.

-------------------------------------------------------
-- DELETE
-------------------------------------------------------
-- 특정 행을 삭제하는 구문.
-- 처리결과 행의 수가 줄어든다.

delete from
    ex_employee
where
    emp_id = '302';

select * from ex_employee;

commit;

-- where절 사용하지 않으면 전체 행 삭제
delete from
    ex_employee;
select * from ex_employee;
rollback;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- TRUNCATE
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DDL로써, 전체행 삭제
-- auto-commit 되므로 rollback으로 복구할 수 없음
-- delete와 달리 before-image를 생성하지 않으므로 처리속도 매우 빠름

truncate table ex_employee;
select * from ex_employee;

-- 복구
insert into ex_employee(
    select * from employee
);
commit;

-- DDL/DML 혼용 시 주의할 점
create table tb_test(
    id varchar2(20)
);

insert into tb_test values('honggd');
insert into tb_test values('sinsa');

-- 중간에 끼어든 DDL 작업
-- commit 실행 시, 이전 작업내용 포함
create table tb_test2(
    id varchar2(20)
);

rollback;
select * from tb_test;


-- ====================================================
-- DDL
-- ====================================================
-- Data Definition Language 데이터 정의어
-- database 객체를 생성/수정/삭제하는 명령어
-- create / alter / drop / truncate
-- 자동커밋되므로 DML과 혼용시 주의 필요

-- DB의 객체 조회
select
    distinct object_type
from
    all_objects; -- Data Dictionary 객체의 메타정보를 관리하는 테이블

/*
    오라클 database객체 종류
    - table
    - user
    - view
    - sequence
    - index
    - package
    - procedure
    - function
    - trigger
    - synonym
    - job scheduler
    ...
    
*/

-------------------------------------------------------
-- CREATE
-------------------------------------------------------
-- 주석
-- 테이블 생성 시, 테이블/컬럼에 대해 주석을 작성 할 수 있음
select *
from user_tab_comments;

select *
from user_tab_comments
where table_name = 'EMPLOYEE';

select *
from user_col_comments
where table_name = 'EMPLOYEE';

-- 테이블 / 컬럼 주석
comment on table ex_employee is '사원관리 연습테이블';
comment on table ex_employee is '사원관리 연습테이블이다!'; -- 주석 수정(덮어쓰기)

select *
from user_tab_comments
where table_name = 'EX_EMPLOYEE';

comment on table ex_employee is ''; -- 주석 삭제

comment on column ex_employee.emp_id is '사번';
comment on column ex_employee.emp_name is '사원명';
comment on column ex_employee.emp_no is '주민번호';

select *
from user_col_comments
where table_name = 'EX_EMPLOYEE';


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 제약조건 constraint
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 각 컬럼에 대해 데이터 제약을 설정할 수 있음
-- 하나의 레코드에서 하나의 컬럼이라도 제약조건을 위반하면 레코드 자체가 insert되지 않음
-- 데이터 무결성을 지키기위해 필수적
-- (데이터의 정확성, 일관성을 지켜내는 것)

/*
    1. not null     (C) : null을 허용하지 않음. 필수 컬럼
    2. unique       (U) : 다른 레코드와 중복값을 허용하지 않음
    3. primary key  (P) : 식별자컬럼. 기본키.
        - 다른 레코드와 중복값을 허용하지 않고, null도 허용하지 않음
        - 테이블당 하나만 지정 가능
    4. foreign key  (R) : 왜래키. 부모테이블에 있는 값만 참조 할 수 있음
        - department.dept_id -> employee.dept_code(FK)
    5. check        (C) : 지정한 도메인의 값만 사용할 수 있음
        - 도메인의 범위를 지정
    
    CONSTRAINT_TYPE C는 not null 또는 check제약조건을 의미하므로
    serch_condition 컬럼을 확인해야 구체적으로 어떤 제약조건인지 확인 가능
*/

-- 제약조건 조회
select *
from
    user_constraints
where
    table_name = 'EMPLOYEE';

select *
from
    user_cons_columns
where
    table_name = 'EMPLOYEE';


-- 자주 사용되는 제약조건 조회 쿼리
select 
    constraint_name,
    uc.table_name,
    ucc.column_name,
    uc.constraint_type,
    uc.search_condition
from
    user_constraints uc join user_cons_columns ucc
        using(constraint_name)
where
     uc.table_name = 'EMPLOYEE';


-- 제약조건 작성방법
-- 1. 컬럼레벨 : not null, pk, uq, fk, ck
-- 2. 테이블레벨 : pk, uq, fk, ck

-- 제약조건 테스트용 테이블
create table tb_member(
    id varchar2(20),
    name varchar2(50) not null,
    password varchar2(20) not null,

    -- 알아보기 좋은 이름 지정하기
    email varchar2(50) constraint uq_tb_member_email unique,

    gender char(1),
    reg_date date
);

-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- unique 제약조건
-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +

-- unique제약조건
-- 각 레코드별로 고유한 값을 사용해야 함
insert into
    tb_member
values(
    'honggd', '홍길동', '1234', 'gd@naver.com', 'M', sysdate
);

insert into
    tb_member
values(
    'gogd', '고길동', '1234', 'gd@naver.com', 'M', sysdate
); --ORA-00001: 무결성 제약 조건(KH.UQ_TB_MEMBER_EMAIL)에 위배됩니다

-- uq제약조건이 걸려있어도 null은 허용
-- null에 대한 허용은 dbms에 따라 차이가 있을 수 있음
insert into
    tb_member
values(
    'gogd', '고길동', '1234', null, 'M', sysdate
);

insert into
    tb_member
values(
    'sinsa', '신사', '1234', null, 'F', sysdate
);

select * from tb_member;

-- 여러컬럼을 포함하는 unique제약조건 생성가능
create table abc(
    a varchar2(10) not null,
    b varchar2(20) not null,
    constraint uq_abc_ab unique(a, b)
);
-- drop table abc;

insert into abc
values(
    '안녕', '잘가'
);

insert into abc
values(
    '안녕', '잘자'
);

insert into abc
values(
    '안녕', null
); -- ORA-01400: NULL을 ("KH"."ABC"."B") 안에 삽입할 수 없습니다

select * from abc;




-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- PRIMARY KEY 제약조건
-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- 식별자 컬럼. 다른 레코드와 구분할 수 있는 식별자. 테이블당 하나만 허용
-- RDBMS에서 테이블간 참조를 위한 컬럼으로 주로 사용

-- 제약조건 테스트용 테이블
-- drop table tb_member;
create table tb_member(
    id varchar2(20),
    --id varchar2(20) constraint pk_tb_member_id primary key, 컬럼 레벨 작성
    name varchar2(50) not null,
    password varchar2(20) not null,
    email varchar2(50),
    gender char(1),
    reg_date date,
    
    constraint pk_tb_member_id primary key(id), -- 테이블 레벨 작성
    constraint uq_tb_member_email unique(email) -- 테이블 레벨 작성
);

insert into tb_member values('honggd', '홍길동', '1234', null, null, sysdate);

-- ORA-00001: 무결성 제약 조건(KH.PK_TB_MEMBER_ID)에 위배됩니다
insert into tb_member values('honggd', '황길동', '1234', null, null, sysdate);
-- ORA-01400: NULL을 ("KH"."TB_MEMBER"."ID") 안에 삽입할 수 없습니다
insert into tb_member values(null, '황길동', '1234', null, null, sysdate);


-- 기본키도 복합키(여러컬럼)로 설정이 가능
create table tb_order_composite(
    product_id varchar2(20),
    user_id varchar2(20),
    cnt number default 1,
    order_date date default sysdate,
    
    constraint pk_tb_order_composite primary key(product_id, user_id, order_date)
);

insert into tb_order_composite values('samsung_1234', 'honggd', 5, default); -- 두번 실행
-- ORA-01400: NULL을 ("KH"."TB_ORDER_COMPOSITE"."USER_ID") 안에 삽입할 수 없습니다
insert into tb_order_composite values('samsung_1234', null, 5, default);

select
    product_id,
    user_id,
    cnt,
    to_char(order_date, 'yyyy-mm-dd hh:mi:ss') order_date
from tb_order_composite;


select 
    constraint_name,
    uc.table_name,
    ucc.column_name,
    uc.constraint_type,
    uc.search_condition
from
    user_constraints uc join user_cons_columns ucc
        using(constraint_name)
where
     uc.table_name = 'TB_ORDER_COMPOSITE';


-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--  CHECK 제약조건
-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- 컬럼값의 범위를 한정하는 제약조건


-- 제약조건 테스트용 테이블
-- drop table tb_member;
create table tb_member(
    id varchar2(20),
    name varchar2(50) not null,
    password varchar2(20) not null,
    email varchar2(50),
    gender char(1),
    point number,
    reg_date date,
    
    -- 테이블 레벨 작성
    constraint pk_tb_member_id primary key(id),
    constraint uq_tb_member_email unique(email),
    constraint ck_tb_member_gender check(gender in('M', 'F')),
    constraint ck_tb_member_point check(point >= 0)
);

-- ORA-02290: 체크 제약조건(KH.CK_TB_MEMBER_POINT)이 위배되었습니다
insert into tb_member values('honggd', '홍길동', '1234', null, 'M', -10, default);
-- ORA-02290: 체크 제약조건(KH.CK_TB_MEMBER_GENDER)이 위배되었습니다
insert into tb_member values('honggd', '홍길동', '1234', null, 'm', 100, default);

insert into tb_member values('honggd', '홍길동', '1234', null, 'M', 100, default);

-- ORA-02290: 체크 제약조건(KH.CK_TB_MEMBER_POINT)이 위배되었습니다
update tb_member set point = point - 1000 where id = 'honggd';


-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
--  FOREIGN KEY 제약조건
-- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- + -- +
-- 참조무결성을 유지하기 위한 제약조건
-- 부모테이블(참조하는 테이블)에서 제공하는 값만 사용할 수 있게 제한함
-- 자식테이블에서 FK 지정
--      ex.) department - employee : employee.dept_code가 FK
-- null은 기본적으로 허용
-- 참조하는 부모테이블 컬럼은 pk또는 uq 제약조건이 걸려있어야 함

select 
    constraint_name,
    uc.table_name,
    ucc.column_name,
    uc.constraint_type,
    uc.search_condition
from
    user_constraints uc join user_cons_columns ucc
        using(constraint_name)
where
    uc.table_name = 'EMPLOYEE';

-- 회원테이블
create table shop_member(
    member_id varchar2(20),
    member_name varchar2(30),
    constraint pk_shop_member_id primary key(member_id)
);

insert into shop_member values('honggd', '홍길동');
insert into shop_member values('sinsa', '신사임당');

select * from shop_member;

-- 구매테이블
-- drop table shop_buy;
create table shop_buy(
    buy_no number,
    member_id varchar2(20),
    product_name varchar2(30),
    constraint pk_shop_buy_no primary key(buy_no),
    
    constraint fk_shop_buy_member_id foreign key(member_id)
                                     references shop_member(member_id)
                                     on delete cascade
);

-- ORA-02291: 무결성 제약조건(KH.FK_SHOP_BUY_MEMBER_ID)이 위배되었습니다- 부모 키가 없습니다
insert into shop_buy values(1, 'honggggggd', '축구화');

insert into shop_buy values(1, 'honggd', '축구화');
insert into shop_buy values(2, 'sinsa', '볼링화');
select * from shop_buy;


-- 부모테이블의 데이터를 삭제하려면?

-- RA-02292: 무결성 제약조건(KH.FK_SHOP_BUY_MEMBER_ID)이 위배되었습니다- 자식 레코드가 발견되었습니다
delete from shop_member where member_id = 'honggd';

-- 외래키 삭제옵션
-- 부모테이블의 데이터를 삭제할 경우, 처리방식을 결정
-- 1. on delete restricted - 기본값
-- 2. on delete set null - 부모데이터 삭제 시 자식fk컬럼값을 null로 처리
-- 3. on delete cascade - 부모데이터 삭제시 참조하는 자식 레코드를 따라서 삭제

-- 식별관계 / 비식별관계
-- fk컬럼을 다시 pk로 사용하면 식별관계, pk로 사용하지 않으면 비식별관계
-- 식별관계인 경우 0~1개 행이 존재할 수 있음
-- 비식별관계인 경우 0~n개 행이 존재할 수 있음

create table tb_person(
    id varchar2(20) primary key
);
insert into tb_person values('sinsa');
select * from tb_person;

create table tb_person_address(
    person_id varchar2(20),
    addr varchar2(500),
    constraint fk_tb_person_address 
        foreign key(person_id) references tb_person(id),
    constraint pk_tb_person_address 
        primary key(person_id)
);

insert into tb_person_address values('sinsa', '서울시 강남구 역삼동');

--ORA-00001: 무결성 제약 조건(KH.PK_TB_PERSON_ADDRESS)에 위배됩니다
insert into tb_person_address values('sinsa', '서울시 강동구 신내동');

select * from tb_person_address;


-------------------------------------------------------
-- ALTER
-------------------------------------------------------
-- 객체를 수정하는 명령어
-- table에 대해서 수정가능한 것 : 컬럼, 제약조건(추가만 가능), 테이블명

-- 서브명령어
/*
    add     : 컬럼/제약조건 추가
    modify  : 컬럼수정(자료형, default값, not null여부)
    rename  : 컬럼/제약조건 이름 변경
    drop    : 컬럼/제약조건 삭제
*/

create table tb_user (
    no number primary key,
    id varchar2(20),
    pw varchar2(20)
);
desc tb_user;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ADD
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 컬럼/제약조건을 추가

alter table
    tb_user
add
    name varchar2(50);

alter table
    tb_user
add
    age number default 0;

desc tb_user;

alter table
    tb_user
add
    constraint uq_tb_user_id unique(id);

desc tb_user;

select 
    constraint_name,
    uc.table_name,
    ucc.column_name,
    uc.constraint_type,
    uc.search_condition
from
    user_constraints uc join user_cons_columns ucc
        using(constraint_name)
where
    uc.table_name = 'TB_USER';


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- MODIFY
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 컬럼에 대해서만 수정 가능
-- 제약조건 중 not null은 수정 가능
-- null 작성시 not null 해제

alter table
    tb_user
modify
    name varchar2(100) not null;

desc tb_user;

-- 데이터가 있는 상황에서 자료형의 크기를 기존값 크기보다 작게 수정불가
insert into tb_user values (1, 'honggd', '1234', '홍길동길동길동길동', 33);
commit;

-- ORA-01441: 일부 값이 너무 커서 열 길이를 줄일 수 없음
alter table
    tb_user
modify
    name varchar2(20);

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- RENAME
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 컬럼명 / 제약조건명 수정

alter table
    tb_user
rename
    column pw to password;

desc tb_user;

select 
    constraint_name,
    uc.table_name,
    ucc.column_name,
    uc.constraint_type,
    uc.search_condition
from
    user_constraints uc join user_cons_columns ucc
        using(constraint_name)
where
    uc.table_name = 'TB_USER';

alter table
    tb_user
rename
    constraint SYS_C007790 to pk_tb_user_no;

-- gender컬럼 및 check제약조건 추가
alter table tb_user
    add gender char(1)
    add constraint ck_tb_user_gender check(gender in('M', 'F'));

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DROP
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 컬럼 삭제, 제약조건 삭제
-- not null제약조건은 modify로 수정(null 지정)

alter table
    tb_user
drop column age;

alter table
    tb_user
drop constraint ck_tb_user_gender;

desc tb_user;

select 
    constraint_name,
    uc.table_name,
    ucc.column_name,
    uc.constraint_type,
    uc.search_condition
from
    user_constraints uc join user_cons_columns ucc
        using(constraint_name)
where
    uc.table_name = 'TB_USER';

-- 테이블 이름 변경
-- 방법1
alter table
    tb_user
rename to
    tb_user_after;

-- 방법2
rename
    tb_user_after to tb_user_after2;

select * from tb_user_after2;


-------------------------------------------------------
-- DROP
-------------------------------------------------------
-- 객체 삭제
-- 돌이킬 수 없기때문에 정말 신중하게 사용할 것
-- drop은 주석 안에 작성하는 습관을 들일 것

-- drop table tb_user_after2

-- 자식테이블이 참조하는 부모테이블을 삭제

insert into shop_member values ('honggd', '홍길동');
insert into shop_buy values (123, 'honggd', '농구화');
insert into shop_buy values (127, 'honggd', '등산화');
select * from shop_member;
select * from shop_buy;
-- 두 테이블은 비식별관계의 부모-자식 테이블인 상황

-- ORA-02449: 외래 키에 의해 참조되는 고유/기본 키가 테이블에 있습니다
--drop table shop_member;

--drop table shop_member cascade constraint;

select 
    constraint_name,
    uc.table_name,
    ucc.column_name,
    uc.constraint_type,
    uc.search_condition
from
    user_constraints uc join user_cons_columns ucc
        using(constraint_name)
where
    uc.table_name = 'SHOP_BUY';


-- ====================================================
-- DCL
-- ====================================================
-- Data Control Language 데이터 제어어
-- 권한 할당, 권한 회수 등에 사용하는 명령어
-- TCL을 포함하는 상위개념

-- 역할(role) connect, resouce
-- 권한(privilige) create session/table/view, select on tb


-------------------------------------------------------
-- GRANT
-------------------------------------------------------
-- 권한을 사용자나 롤(권한묶음)에 부여하는 명령어
-- 문법 : grant (특정권한 | 롤) to (사용자 | 롤) [with admin option]
-- with admin option은 부여받은 권한을 다시 부여할 수 있는 옵션


--------------------관리자계정으로 실행-------------------
-- (관리자계정) qwerty 생성 -> 접속시도(실패) : create session권한 부재
-- create session | connect 을 qwerty에 부여 -> 접속시도(성공)

alter session set "_oracle_script" = true; -- 이전 버전 방식으로 이용할 수 있도록 함
-- 관리자 계정 아닐때 : ORA-65096: 공통 사용자 또는 롤 이름이 부적합합니다.
create user qwerty identified by qwerty default tablespace users;

grant create session to qwerty; -- 권한
grant connect to qwerty; -- 롤

alter user qwerty quota unlimited on users;
grant resource to qwerty; -- 객체 생성 role

-- 롤이 가지고 있는 권한 조회
select *
from
    dba_sys_privs
where
    grantee in ('CONNECT', 'RESOURCE');
/*
RESOURCE	CREATE SEQUENCE
RESOURCE	CREATE PROCEDURE
CONNECT	    SET CONTAINER
RESOURCE	CREATE CLUSTER
CONNECT	    CREATE SESSION
RESOURCE	CREATE INDEXTYPE
RESOURCE	CREATE OPERATOR
RESOURCE	CREATE TYPE
RESOURCE	CREATE TRIGGER
RESOURCE	CREATE TABLE
*/
-------------------------------------------------------

--------------------- kh 계정으로 실행--------------------

-- 특정 테이블에 대한 권한 부여
create table tb_coffee(
    name varchar2(50),
    price number not null,
    company varchar2(50) not null,
    constraint pk_tb_coffee_name primary key(name)
);
insert into tb_coffee values ('맥심', 3000, '동서식품');
insert into tb_coffee values ('카누', 5000, '동서식품');
insert into tb_coffee values ('네스카페', 4000, '네슬레');
commit;

-- kh(소유주)가 qwerty에게 tb_coffee 조회권한 부여
grant select on tb_coffee to qwerty;
grant insert, update, delete on tb_coffee to qwerty;

select * from tb_coffee;

-------------------------------------------------------
-- REVOKE
-------------------------------------------------------
-- 권한을 회수하는 명령어
-- revoke (권한 | 롤) from (사용자 | 롤)

revoke insert, update, delete on tb_coffee from qwerty;
revoke select on tb_coffee from qwerty;


-- ====================================================
-- TCL
-- ====================================================
-- Transaction Control Language 트랜잭션 제어어
-- commit / rollback / savepoint

-- Transaction
-- 한번에 처리되어야 할 최소한의 작업단위
-- 하위 작업들은 모두 성공 or 모두 실패되어야 함

-- 계좌이체 a -----> b 50,000전송
-- 1. a 계좌에서 50,000원 차감
-- 2. b 계좌에서 50,000원 증액
-- 두 단계가 하나의 트랜잭션을 구성

-- 1, 2번 update 실행 후 모두 성공 시 commit, 하나라도 실패 시 rollback


-- ====================================================
-- DATABASE OBJECT 1
-- ====================================================

-------------------------------------------------------
-- DATA DICTIONARY
-------------------------------------------------------
-- db를 효율적으로 관리하기위해 다양한 객체의 정보를 가지고 있는 시스템 테이블
-- 모두 read-only이므로, 추가/수정/삭제 작업은 일절 없음
-- 객체정보가 변경되면, 자동으로 DD(Data Dictionary)에 반영

-- DD의 종류
-- 1. 일반사용자용 : user_xxxs
-- 2. 일반사용자용(부여받은 객체 포함) : all_xxxs
-- 3. 관리자용 : dba_xxxxs

-- DD조회
select * from dictionary;
select * from dict;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- USER_XXXS
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++

-- 내가 소유한 table 조회
select * from user_tables;

-- 내가 가진 권한조회
select * from user_sys_privs;

-- 내가 가진 롤 조회
select * from user_role_privs;

-- 내가 가진 롤에 포함된 권한 조회
select * from role_sys_privs;


select * from user_constraints; -- 제약조건
select * from user_sequences; -- 시퀀스
select * from user_indexes; -- 인덱스
select * from user_views; -- 뷰

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ALL_XXXS
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 소유하거나 사용권한을 부여받은 모든 객체 조회

select * from all_tables;
select * from all_tab_comments; -- 테이블 코멘트
select * from all_col_comments; -- 컬럼 코멘트

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DBA_XXXS
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 관리자만 접근이 가능한 객체 정보 조회
-- 관리자는 모든 테이블, 모든 사용자에 대한 조회가 가능하다.

--------------------관리자계정으로 실행-------------------
select * from dba_tables;

select * from dba_tables where owner = 'KH';

select * from dba_sys_privs where grantee = 'KH';
select * from dba_role_privs where grantee = 'KH';

-- 특정 계정이 가지는 테이블에 대한 권한 관리
select * from dba_tab_privs where owner = 'KH';
-------------------------------------------------------

-------------------------------------------------------
-- STORED VIEW
-------------------------------------------------------
-- 하나 이상의 테이블로부터 원하는 데이터를 선별적으로 제공하는 가상테이블
-- 실제 데이터를 소유하지 않고, 실제 테이블에 대한 통로역할
-- 이 객체에는 inline view쿼리를 가지고 있다가 쿼리 실행시 해당 inline view를 처리

select * from user_views;

-- create view권한은 resource롤에 포함되지 않으므로 새로 부여해야함
-- (관리자계정으로 권한 부여) create view권한을 kh에 부여
grant create view to kh;


create view view_emp
as
select * from employee;

-- (선택) or replace : 없으면 생성, 있으면 갱신
create or replace view view_emp
as
select emp_id, emp_name, email, phone from employee;

select * from view_emp; -- 테이블처럼 사용

-- 1. 타 사용자에게 선별적으로 데이터 제공
-- qwerty에게 view_emp조회권한 부여
grant select on view_emp to qwerty;

-- 2. 가상컬럼, relation에 대한 조회를 손쉽게 할 수 있다.
-- 사번, 사원명, 성별, 나이, 직급명, 부서명 조회
create or replace view view_emp_read
as
select
    emp_id,
    emp_name,
    decode(substr(emp_no, 8, 1), '1', '남', '3', '남', '여') gender,
    extract(year from sysdate) - 
        (decode(substr(emp_no, 8, 1), '1', 1900, '2', 1900, 2000) + substr(emp_no, 1, 2)) + 1 age,
    (select job_name from job where e.job_code = job_code) job_name,
    nvl((select dept_title from department where e.dept_code = dept_id),'인턴') dept_title
from
    employee e ;

select * from view_emp_read where gender = '여';


-------------------------------------------------------
-- SEQUENCE
-------------------------------------------------------
-- 정수값을 순차적으로 발행하는 객체(채번기)
-- pk값을 정수로 관리하는 경우 sequence발급한 번호를 사용
-- 시퀀스 객체의 start with값은 수정불가
-- 수정하고싶다면 시퀀스 삭제 후 다시 생성할 것
-- increment by 옵션은 수정가능

/*
    create sequence 시퀀스명
    [start with 시작값]                -- 기본값: 1
    [increment by 증감값]              -- 1
    [maxvalue 최대값 | nomaxvalue]     -- nomax value
    [minvalue 최소값 | nominvalue]     -- nominvalue
    [cycle | nocycle]                 -- nocycle(최대/최소값 도달시 순환여부)
    [cache 수량 | nocache]             -- 20
*/

create table tb_advice(
    no number primary key, --고유한 값
    user_id varchar2(20) not null,
    reg_date date default sysdate
);

create sequence seq_tb_advice_no;

insert into tb_advice(no, user_id) values (seq_tb_advice_no.nextval, 'honggd');
insert into tb_advice(no, user_id) values (seq_tb_advice_no.nextval, 'sinsa');
insert into tb_advice(no, user_id) values (seq_tb_advice_no.nextval, 'sejong');

select * from tb_advice;

-- 현재 sequence상태 조회 (마지막 발급번호)
select seq_tb_advice_no.currval from dual;

-- cacheing된 숫자가 건너뛸 수 있다.
-- pk는 고유하기만하면 문제가 되지 않는다.
-- 연속된 숫자로 관리하고자 한다면 sequence사용 시 nocache옵션으로 지정
select * from user_sequences;

-- 시퀀스 객체의 start with값은 수정불가
-- 수정하고싶다면 시퀀스 삭제 후 다시 생성할 것
-- increment by 옵션은 수정가능
alter sequence seq_tb_advice_no increment by 10;


-- 복합문자열을 pk로 처리하세요
-- 주문테이블 kh_order
create table kh_order(
    no varchar2(30), -- 포맷: kh-220324-0001
    user_id varchar2(20) not null,
    prod_id varchar2(20) not null,
    cnt number default 1,
    order_date date default sysdate,
    constraint pk_kh_order_no primary key(no)
);

-- 적절한 seqence를 생성하고, 위와 같은 pk를 생성할 수 있도록 insert문을 작성
create sequence seq_kh_order_no;

insert into kh_order(no, user_id, prod_id)
values (
    'kh-' || to_char(sysdate, 'yymmdd-') || lpad(seq_kh_order_no.nextval, 4, '0'),
    'dldmswl',
    'orange7'
);
insert into kh_order(no, user_id, prod_id)
values (
    'kh-' || to_char(sysdate, 'yymmdd-') || lpad(seq_kh_order_no.nextval, 4, '0'),
    'honggd',
    'apple12'
);
commit;

select * from kh_order;

-------------------------------------------------------
-- INDEX
-------------------------------------------------------
-- 색인. sql명령의 처리속도 향상을 위해 table의 컬럼에 대해 생성하는 색인 객체.
-- key-value형태로 저장.
-- key : 컬럼값 보관,  value : 행이 저장된 주소값 보관

-- 장점
-- 1. 검색속도가 빨라지고, 시스템부하가 줄어든다.
-- 2. 전체적인 성능향상

-- 단점
-- 1. 인덱스를 위한 추가 저장공간이 필요.
-- 2. 인덱스 생성/수정/삭제 시 별도의 작업시간이 소요
-- 3. 데이터 생성/수정/삭제가 빈번하다면 인덱스로인해 성능저하 야기

-- 어떤 컬럼에 대해 인덱스를 만들어야 하는가?
-- 1. 선택도(selectivity)가 좋은 컬럼을 인덱스로 만든다.
--  선택도 : 고유한 값을 많이 가지는 것.
--      ex1) employee.emp_id : 중복X -> 선택도 아주 좋음
--      ex2) employee.emp_no : 중복X -> 선택도 아주 좋음
--      ex3) employee.emp_name : 중복가능-> 선택도 좋음
--      ex4) employee.dept_code : 중복O, 중복빈도 보통 -> 선택도 보통
--      ex5) employee.gender : 중복O, 중복빈도 높음 -> 선택도 나쁨
-- 2. where절에 자주 사용되는 컬럼을 선택
-- 3. join조건컬럼을 선택
-- 4. 한번 입력된 데이터가 변경이 자주 없는 컬럼

-- 중복값 많은 컬럼, null값이 많은 컬은 가능한 지양할 것

-- index 조회
-- pk, uq 제약조건이 걸린 컬럼은 자동으로 인덱스를 생성
select * from user_indexes;
select * from user_ind_columns;

-- index 조회 한문장으로 join
-- pk, uq로  생성된 인덱스는 제약조건명과 인덱스명이 같음
-- 제약조건명을 잘 지으면(테이블명, 컬럼명 포함) 인덱스정보 확인 시 유용
select *
from user_indexes join user_ind_columns
        using(index_name);

-- 실행계획(F10) 확인
select * from employee where job_code = 'J2'; -- job_code 인덱스 없음
select * from employee where emp_id = '203'; -- emp_id 인덱스 있음
select * from employee where dept_code = 'D5';
select * from employee where emp_no = '070910-4653546';
select * from employee where emp_name = '송종기';

-- 인덱스 생성
-- 인덱스이름 on 테이블(컬럼)
create index idx_employee_emp_name on employee(emp_name);
select * from employee where emp_name = '송종기';

-- 인덱스 사용시 주의사항
-- 인덱스 사용여부는 optimizer(최적화처리기)가 결정하지만, 다음 경우는 index사용하지 않음
-- 1. 인덱스 컬럼을 변형해 조회하는 경우
--      ex) where substr(emp_no, 8, 1) = '1'
-- 2. null 비교하는 경우
--      ex) where emp_name is null
-- 3. not 비교하는 경우
--      ex) where emp_name != '송종기'
-- 4. 인덱스컬럼과 자료형이 다른 경우
--      ex) where emp_id = 201

select * from employee where emp_id = '201';
select * from employee where emp_id = 201; -- 비용 3배 증가


-- index 삭제
-- drop index 인덱스명
-- pk, uq 제약조건으로 생성된 인덱스는 직접삭제 불가능
-- pk, uq 제약조건 제거 시 자동으로 삭제처리


-- ====================================================
-- PL/SQL
-- ====================================================
-- Procedural Language extension to SQL
-- 기존 sql에 절차적 언어 방식을 추가하여 변수선언, 조건처리, 반복처리 지원하는 문법

-- pl/sql 유형
-- 1. 익명블럭 Anonymous Block 매번실행
-- 2. 프로시저 - pl/sql구문을 저장하여 호출로 재사용 가능
-- 3. 함수 - pl/sql구문을 저장하여 호출로 재사용 가능(반드시 하나의 리턴값 가짐)

-- 익명블럭 구조
/*
    declare
        -- 변수선언부(선택)
    begin
        -- 실행부(필수)
    exception
        -- 예외처리부(선택)
    end;
    /
    
    sql문은 ;(세미콜론)으로 각 sql문을 구분했으나,
    pl/sql에서는 블럭안에 여러개의 sql문이 올 수 있다.

    /(슬래시)가 익명블럭의 종료를 의미함.
*/

-- 서버콘솔 출력
-- 이 설정이 있어야 pl/sql 결과를 콘솔로 확인가능
-- 기본값이 off이므로 session생성 시 마다 매번 1회 실행 할 것
set serveroutput on; -- 만약 오류뜨면 대문자로 ON 해보자

-- 콘솔 출력 테스트
begin
    dbms_output.put_line('hello world');
end;
/

declare
    v_emp_id char(3); -- 변수 선언
begin
    select
        emp_id
    into
        v_emp_id
    from
        employee
    where
        emp_name = '김김김'; -- 없는 이름
        
    dbms_output.put_line('emp_id : ' || v_emp_id);
exception
    when no_data_found then dbms_output.put_line('찾으시는 사원이 없습니다.');
end;
/

-------------------------------------------------------
-- 익명블럭
-------------------------------------------------------
-- declare 변수
-- 변수명 [constant] 자료형 [not null] := 값

declare
    name varchar2(100);
    num number := 10 * 2;
    KKK constant number := 333;
begin
    name := '김사랑';
    
--    RA-06550: 줄 7, 열5:PLS-00363: 'KKK' 식은 피할당자로 사용될 수 없습니다
--    KKK := KKK * 100;
    
    dbms_output.put_line(name);
    dbms_output.put_line(num);
    dbms_output.put_line(KKK);
end;
/


-- 변수의 자료형
-- 1. 기본자료형
--      - varchar2, char, clob
--      - number, binary_integer, pls_integer
--      - date
--      - boolean (true, false, null)
-- 2. 복합자료형
--      - record
--      - cursor
--      - collection (varray(배열), nested_table(List), associative array(Map) ...)

-- 변수유형
-- 1. 스칼라변수(값)
-- 2. 참조변수(테이블.컬럼타입)

-- 참조변수1. %type
-- 변수 자료형을 직접 선언하지 않고, (다른 테이블).(특정 컬럼)을 참조

declare
    v_emp_name employee.emp_name%type;
    v_phone employee.phone%type;
    v_dept_title department.dept_title%type;
begin
    select
        emp_name, phone,
        (select dept_title from department where dept_code = dept_id)
    into
        v_emp_name, v_phone, v_dept_title
    from employee
    where emp_id = '&사번'; -- 사용자 임시변수에 사용자입력값 받아서 조회
    
    dbms_output.put_line('이름 : ' || v_emp_name);
    dbms_output.put_line('전화번호 : ' || v_phone);
    dbms_output.put_line('부서명 : ' || v_dept_title);
end;
/

-- 참조변수2. %rowtype
-- 테이블의 모든 컬럼을 참조하는 타입

declare
    emp_row employee%rowtype;
begin
    select *
    into emp_row
    from employee
    where emp_id = '&사번';
    
    dbms_output.put_line('사원명 : ' || emp_row.emp_name);
    dbms_output.put_line('이메일 : ' || emp_row.email);
end;
/

-- 참조변수3. record
-- 원하는 컬럼만 가지고 있는 record자료형을 만들고, 사용한다.

declare
    type my_emp_type is record(
        emp_name employee.emp_name%type,
        dept_title department.dept_title%type
    );
    
    erow my_emp_type;
begin
    select
        emp_name, dept_title
    into
        erow
    from
        employee left join department
            on dept_code = dept_id
    where emp_id = '&사번';
    
    dbms_output.put_line('이름 : ' || erow.emp_name);
    dbms_output.put_line('부서 : ' || erow.dept_title);
end;
/


-- 사원명, 직급명 처리할 수 있는 레코드를 선언하고 사번을 통해 조회하세요.
declare
    type my_emp_type is record(
        emp_name employee.emp_name%type,
        job_name job.job_name%type
    );
    
    erow my_emp_type;
begin
    select
        emp_name,
        (select job_name from job where e.job_code = job_code)
    into erow
    from employee e
    where emp_id = '&사번';
    
    dbms_output.put_line('이름 : ' || erow.emp_name);
    dbms_output.put_line('직급 : ' || erow.job_name);
end;
/

-- begin절에서 DML 사용하기
-- 익명블럭 안에서 TCL 처리까지 완료해야함
select * from tb_member;
desc tb_member;

begin
    insert into 
        tb_member
    values(
        'sinsa', '신사임당', '1234', 'sinsa@gmail.com', 'F', 1000, default
    );
    commit; -- 트랜잭션 처리까지 완료하기
end;
/
select * from tb_member;


-- ex_employee의 마지막 번호를 조회한 후, +1 사번을 부여해서 다음 정보를 insert하기
-- 김테리 880808-2345678 teari@gmail.com 01012341234 null J4 S3 3500000 null 200
select * from ex_employee;
desc ex_employee;

declare
    v_emp_id employee.emp_id%type;
begin
    -- 1. 마지막 사번 조회
    select max(emp_id) + 1
    into v_emp_id
    from employee;
    dbms_output.put_line('emp_id : ' || v_emp_id);

    -- 2. insert
    insert into
        ex_employee
    values (
        v_emp_id, '김테리', '880808-2345678', 'teari@gmail.com', 
        '01012341234', null, 'J4', 'S3', 3500000, null, '200',
        sysdate, null, 'N'
    );
    -- 3.트랜잭션
    commit;
end;
/

-------------------------------------------------------
-- 조건문
-------------------------------------------------------
-- if, else if, if else
/*
    if 조건식 then
        실행구문
    end if;
    
    if 조건식 then
        참일 때 실행코드
    else
        거짓일 때 실행코드
    end if;
    
    if 조건식1 then
        실행코드1
    elsif 조건식2 then
        실행코드2
    elsif 조건식3 then
        실행코드3
    ...
    end if;
*/

declare
    n number := &숫자;
begin
    dbms_output.put_line(n);
    
--    if mod(n, 2) = 0 then
--        dbms_output.put_line('짝수를 입력하셨습니다.');
--    else
--        dbms_output.put_line('홀수를 입력하셨습니다.');
--    end if;

    if n > 0 then
        dbms_output.put_line('양수입니다.');
    elsif n = 0 then
        dbms_output.put_line('0입니다.');
    else
        dbms_output.put_line('음수입니다.');
    end if;
    
    dbms_output.put_line('끝');
end;
/


-- case문
/*
    -- 문법1.
    case 표현식
        when 값1 then
            실행코드1 ;
        when 값2 then
            실행코드2 ;
        ...
        else
            기본실행코드 ;
    end case;
    
    -- 문법2.
    case
        when 조건식1 then 실행코드1 ;
        when 조건식2 then 실행코드2 ;
        when 조건식3 then 실행코드3 ;
        else 기본실행코드 ;
    end case;
*/

-- 가위(1) 바위(2) 보(3)
declare
    n number := &가위바위보123 ;
begin
    case (n)
        when 1 then dbms_output.put_line('가위');
        when 2 then dbms_output.put_line('바위');
        when 3 then dbms_output.put_line('보');
        else dbms_output.put_line('잘못 입력하셨습니다.');
    end case;
end;
/

declare
    n number := &가위바위보123 ;
    com number := dbms_randum.value(1, 4); -- 1.0보다 크거나 같고 4.0보다 작은 실수 반환
begin
    dbms_output.put_line(com);
    case
        when n = 1 then dbms_output.put_line('가위');
        when n = 2 then dbms_output.put_line('바위');
        when n = 3 then dbms_output.put_line('보');
        else dbms_output.put_line('잘못 입력하셨습니다.');
    end case;
end;
/

-- 가위(1) 바위(2) 보(3)
declare
    com number := trunc(dbms_random.value(1, 4)); -- 1.0보다 크거나 같고 4.0보다 작은 실수 반환
    n number := &가위바위보123 ;
begin
    dbms_output.put_line('사용자 : ' || n);
    dbms_output.put_line('컴퓨터 : ' || com);
    
    case (n)
        when 1 then
            if com = 1 then dbms_output.put_line('비겼습니다.');
            elsif com = 2 then dbms_output.put_line('졌습니다.');
            elsif com = 3 then dbms_output.put_line('이겼습니다.');
            end if;
        when 2 then
            if com = 1 then dbms_output.put_line('이겼습니다.');
            elsif com = 2 then dbms_output.put_line('비겼습니다.');
            elsif com = 3 then dbms_output.put_line('졌습니다.');
            end if;
        when 3 then dbms_output.put_line('보');
            if com = 1 then dbms_output.put_line('졌습니다.');
            elsif com = 2 then dbms_output.put_line('이겼습니다.');
            elsif com = 3 then dbms_output.put_line('비겼습니다.');
            end if;
        else dbms_output.put_line('잘못 입력하셨습니다.');
    end case;
    
    -- 강사님 풀이
    case 
        when n = 1 then dbms_output.put_line('가위를 냈습니다.');
        when n = 2 then dbms_output.put_line('바위를 냈습니다.');
        when n = 3 then dbms_output.put_line('보를 냈습니다.');
        else dbms_output.put_line('잘못 입력하셨습니다.'); return;
    end case;
    case
        when com = n then dbms_output.put_line('> 비겼습니다.');
        when ((n = 1 and com = 3) or (n = 2 and com = 1) or (n = 3 and com = 2)) then dbms_output.put_line('> 당신이 이겼습니다.');
        else dbms_output.put_line('> 당신이 졌습니다.');
    end case;
    
end;
/

-- 사번을 입력받고, 관리자에 대한 성과급을 지급하려한다.
-- 관리하는 사원이 5명이상은 급여의 15% 지급 : '성과급은 ??원입니다.'
-- 관리하는 사원이 5명미만은 급여의 10% 지급 : ' 성과급은 ??원입니다.'
-- 관리하는 사원이 없는 경우는 '대상자가 아닙니다.'

declare
    v_emp_id employee.emp_id%type := '&사번';
    v_manage_num number;
    v_bonus employee.salary%type; -- 성과급
begin
    -- 관리 사원 수 조회
    select
        count(*) manage_num
    into
        v_manage_num
    from
        employee e join employee m
            on e.manager_id = m.emp_id
    where m.emp_id = v_emp_id
    group by m.emp_id;
    
    -- 관리자 봉급 조회
    select salary
    into v_bonus
    from employee
    where emp_id = v_emp_id;
    dbms_output.put_line('기본 봉급은' || v_bonus || '원 입니다.');
    
    -- 성과급 출력
    case
        when v_manage_num >= 5
            then dbms_output.put_line('성과급은' || v_bonus*0.15 || '원 입니다.');
        when v_manage_num < 5
            then dbms_output.put_line('성과급은' || v_bonus*0.1 || '원 입니다.');
    end case;
exception
    when no_data_found then dbms_output.put_line('대상자가 아닙니다.');
end;
/

-- 수진님 풀이
declare
    v_emp_id_cnt ex_employee.emp_id%type;
    v_bonus ex_employee.salary%type;
begin
    select
        (select count(*) from employee where e.emp_id = manager_id), salary
    into
        v_emp_id_cnt, v_bonus
    from
        ex_employee e
    where emp_id = '&사번';
    
    if  v_emp_id_cnt >= 5 then
            dbms_output.put_line('성과금은 ' || (v_bonus * 0.15) || '원입니다.');
    elsif  v_emp_id_cnt < 5 then
            dbms_output.put_line('성과금은 ' || (v_bonus * 0.10) || '원입니다.');
    elsif v_emp_id_cnt < 0 then
            dbms_output.put_line('대상자가 아닙니다.');
    end if;        
end;
/

-- 강사님 풀이
declare
    salary employee.salary%type;
    num number; -- 부하직원수
begin
    -- 1. 사번으로 부하직원수, 급여 조회
    select
        (select count(*) from employee where manager_id = e.emp_id), 
        salary
    into
        num, salary
    from
        employee e
    where
        emp_id = '&사번';
        
    dbms_output.put_line(num || ', ' || salary);

    -- 2. 성과금 평가
    if num >= 5 then
        dbms_output.put_line('성과금 : ' || salary * 0.15 || '원');
    elsif num > 0 then
        dbms_output.put_line('성과금 : ' || salary * 0.1 || '원');
    else
        dbms_output.put_line('성과금 대상자가 아닙니다');
    end if;
end;
/

-------------------------------------------------------
-- 반복문
-------------------------------------------------------
-- loop, while loop, for loop

-- loop 무한반복 + 탈출문 exit
declare
    n number := 1;
begin
    
    loop
        dbms_output.put_line(n);
        n := n + 1;
        
        -- 탈출조건(필수)
        exit when n > 5;
    end loop;
end;
/

-- while (조건식) loop
declare
    n number := 1;
begin
    while  n <= 5 loop
        dbms_output.put_line(n);
        n := n + 1;
    end loop;
end;
/

-- for loop : 증감변수 별도 선언 불필요
-- 증감변수 범위만큼 반복후 자동 종료
-- for 증감변수 in [reverse] 시작값 .. 종료값
-- 증감처리는 +1이며, 변경불가
begin
    for n in 1..5 loop
        dbms_output.put_line(n);
    end loop;
    
    for n in reverse 1..5 loop -- 역방향으로 돌려 -1 증감처리 역할
        dbms_output.put_line(n);
    end loop;
end;
/

-- 구구단에서 사용자 입력 단 출력
declare
    dan number := &구구단수 ;
begin
    for n in 1 .. 9 loop
        dbms_output.put_line(dan || ' * ' || n || ' = ' || (dan * n));
    end loop;
end;
/

-- 2단~ 9단 출력
begin
    for n in 2 .. 9 loop
        for m in 1..9 loop
            dbms_output.put_line(n || ' * ' || m || ' = ' || (n * m));
        end loop;
        dbms_output.new_line; -- 공백행 출력
    end loop;
end;
/

-- 사원정보 출력
-- select문의 조회결과를 1행씩 처리
declare
    erow employee%rowtype ;
    v number := 200;
begin
    for n in 200..223 loop        
        select *
        into erow
        from employee
        where emp_id = n;
    
        dbms_output.put_line(erow.emp_id || '   ' || erow.emp_name || '     ' || erow.email);
    end loop;
end;
/


-- ====================================================
-- DATABASE OBJECT2
-- ====================================================
-- pl/sql문법을 사용하는 db 객체(function, procedure, cursor, trigger, ...)


-------------------------------------------------------
-- STORED FUNCTION
-------------------------------------------------------
-- 리턴값이 반드시 존재하는 프로시저 객체
-- 함수 객체는 일반 sql문, 다른 프로시저, 익명블럭에서 호출가능
-- 기존 sql 실행과 달리, 미리 컴파일하므로 실행속도 빠름

/*
    create [or replace] function 함수명(매개변수1, 매개변수2, ...)
    return 자료형
    is
        -- 지역변수선언
    begin
        -- 실행코드
        return 리턴값;
    [exception]
        -- 예외처리
        return 예외발생시 리턴값;
    end;
    /
*/

-- 양모자 씌우기
-- 매개변수, 리턴타입에 자료형의 크기는 지정하지 않음
-- pl/sql의 varchar2(32,676byte)가 최대
create or replace function myfunc(p_emp_name employee.emp_name%type)
return varchar2
is
    result varchar2(32676);
begin
    result := 'd' || p_emp_name || 'b';
    dbms_output.put_line(result || '@myfunc');
    return result;
end;
/

-- 1. 익명블럭에서 호출
begin
    dbms_output.put_line(myfunc('&이름'));
end;
/

-- 2. 일반 sql문에서 호출
-- 함수 내부의 로그출력 없음
select
    myfunc(emp_name)
from employee;

-- data dictionary에서 확인
-- user_procedures에서 object_type='FUNCTION'
select *
from user_procedures
where object_type = 'FUNCTION';


-- 주민번호를 인자로 성별을 리턴하는 저장함수 fn_get_gender
create or replace function fn_get_gender(
    p_emp_no employee.emp_no%type
)
return char
is
    v_gender char(3);
begin
    case substr(p_emp_no, 8, 1)
        when '1' then v_gender := '남';
        when '3' then v_gender := '남';
        else v_gender := '여';
    end case;
    
    return v_gender;
end;
/

select
    emp_name,
    emp_no,
    fn_get_gender(emp_no) gender
from employee;


-- 주민번호를 인자로 받아서 한국나이를 리턴하는 fn_get_age
create or replace function fn_get_age(p_emp_no employee.emp_no%type)
return number
is
    v_age number;
begin
    case substr(p_emp_no, 8, 1)
        when '1' then v_age := 1900;
        when '2' then v_age := 1900;
        else v_age := 2000;
    end case;
    v_age := extract(year from sysdate) - (v_age + substr(p_emp_no, 1, 2)) + 1;
    return v_age;
end;
/

select
    emp_name, 
    emp_no, 
    fn_get_age(emp_no) age
from employee;


-------------------------------------------------------
-- STORED PROCEDURE
-------------------------------------------------------
-- 일련의 작업절차를 객체로 저장하고 호출해서 사용하는 객체
-- 리턴값이 없음
-- out매개변수를 이용해서 호출부로 값전달 가능
-- 미리 컴파일하므로 일반 sql대비 처리효율이 좋음
-- select문에서 호출불가. 익명블럭 혹은 다른 프로시저에서 호출가능

/*
    create [or replace] procedure 프로시저명(매개변수1 mode 자료형, 매개변수2 mode 자료형, ...)
    is
        -- 지역변수선언
    begin
        -- 실행코드
    end;
    /
    
    mode : in(기본값), out, inout
        - in : 프로시저 값을 전달
        - out : 프로시저의 처리내용을 담아서 호출부로 전달
        - inout : 두가지 기능 모두 사용
*/

create or replace procedure proc_get_emp(
    p_emp_id in employee.emp_id%type,
    p_emp_name out employee.emp_name%type,
    p_phone out employee.phone%type
)
is
begin
    -- 해당사원 조회
    select
        emp_name, phone
    into
        p_emp_name, p_phone
    from
        employee
    where
        emp_id = p_emp_id;
    
    dbms_output.put_line('사원명@proc_get_emp : ' || p_emp_name);
    dbms_output.put_line('전화번호@proc_get_emp : ' || p_phone);
end;
/

-- 익명블럭에서 호출
declare
    v_emp_id employee.emp_id%type := '&사번';
    v_emp_name employee.emp_name%type;
    v_phone employee.phone%type;
begin
    -- 프로시저 호출
    proc_get_emp(v_emp_id, v_emp_name, v_phone);
    
    -- 값확인
    dbms_output.put_line('사원명 : ' || v_emp_name);
    dbms_output.put_line('전화번호 : ' || v_phone);
end;
/

-- 사원 삭제 프로시저
-- DML처리시에는 트랜젝션처리까지 함께 할 것

create or replace procedure proc_del_emp(
    p_emp_id ex_employee.emp_id%type -- in mode(기본값)
)
is
begin
    -- 삭제
    delete from 
        ex_employee
    where
        emp_id = p_emp_id;
    -- 트랜잭션처리
    commit;
    -- 콘솔로깅
    dbms_output.put_line(p_emp_id || '번 사원을 삭제했습니다.');
end;
/

begin
    proc_del_emp('&사번');
end;
/

select * from ex_employee;


-- upsert 예제
-- 특정 행이 없으면 insert
-- 특정 행이 존재하면 update

-- ex_job테이블
create table ex_job
as
select * from job;

-- 기본키, 자료형 수정
alter table
    ex_job
add constraint pk_ex_job_code primary key(job_code)
modify job_code varchar2(5)
modify job_name not null;

select * from ex_job;

-- 인자로 전달한 직급코드, 직급명에 따라 insert또는 update처리를 하는 프로시저
create or replace procedure proc_upsert_ex_job(
    p_job_code ex_job.job_code%type,
    p_job_name ex_job.job_name%type
)
is
    v_cnt number;
begin
    -- 1. p_job_code의 존재여부 확인
    select
        count(*)
    into
        v_cnt
    from
        ex_job
    where
        job_code = p_job_code;
    
    -- 2. 존재하면 update, 존재하지 않으면 insert
    if v_cnt = 0 then
        insert into 
            ex_job
        values(
            p_job_code, p_job_name
        );
    else
        update
            ex_job
        set
            job_name = p_job_name
        where
            job_code = p_job_code;
    end if;
    
    -- 3. 트랜잭션 처리
    commit;
end;
/

begin
--    proc_upsert_ex_job('J8','인턴'); -- insert
    proc_upsert_ex_job('J8','수습'); -- update
end;
/
select * from ex_job;

-- dd에서 조회
select * from user_procedures where object_type = 'PROCEDURE';


-------------------------------------------------------
-- CURSOR
-------------------------------------------------------
-- 커서란 sql실행결과를 가지고 있는 메모리 영역(private sql)에 대한 포인터객체
-- 한 행 이상의 결과집합의 경우도 순차적 접근가능

-- 1. 암시적 커서
-- 2. 명시적 커서

-- open - fetch - close의 단계를 거쳐 처리함

-- 커서 속성
-- %rowcount : 최근 실행된 sql문의 결과행 수
-- %notfound : 결과집합에서 fetch된 행이 존재하면 false, 존재하지 않으면 true
-- %found    : 결과집합에서 fetch된 행이 존재하면 true, 존재하지 않으면 false
-- %isopen   : 최근 실행된 sql문 커서가 open상태이면 true

-- 암시적 커서 확인
declare
    v_emp_id employee.emp_id%type := '&사번';
    v_emp_name employee.emp_name%type;
begin
    select emp_name
    into v_emp_name
    from employee
    where emp_id = v_emp_id;
    
    if sql%found then
        dbms_output.put_line('조회된 행수 : ' || sql%rowcount);
    end if;
end;
/

-- 명시적 커서
-- 선언 - open - fetch - close
-- 직접 결과집합에 접근해서 행에 대한 처리가능
-- for .. in문 안에서는 open/close를 자동처리해주어서 간단하게 커서 사용가능


declare
    -- 커서선언
    cursor mycursor
    is
    select * from employee;
    
    erow employee%rowtype;
begin
    -- 커서 open
    open mycursor;
    
    loop
        -- 커서 fetch
        fetch mycursor into erow; -- 한행씩 가져오기
        exit when mycursor%notfound; -- 더이상 가져올 행이 없는 경우 exit
        dbms_output.put_line('사번 ' || erow.emp_id || '  사원명 ' || erow.emp_name);
    end loop;
    
    -- 커서 close
    close mycursor;
end;
/

-- for..in문에서 명시적 커서 사용하기
-- open, fetch, close 대신 처리
-- fetch된 행을 담을 변수도 for..in안에서 선언
-- 별도의 exit 작성 불필요
declare
    -- 커서선언
    cursor mycursor
    is
    select * from employee;
begin
    -- open, fetch, close 자동처리
    for erow in mycursor loop
        dbms_output.put_line('사번 ' || erow.emp_id || '  사원명 ' || erow.emp_name);
    end loop;
end;
/

-- 매개변수가 있는 커서
-- 커서 선언시 매개변수도 함께 선언, open할 때 매개인자 전달
declare
   cursor cs_emp_by_dept(p_dept_code employee.dept_code%type)
   is
   select * from employee where dept_code = p_dept_code;
   
   v_dept_code employee.dept_code%type := '&부서코드';
begin
   dbms_output.put_line('사번  사원명    부서코드');
   dbms_output.put_line('====================================');
   for erow in cs_emp_by_dept(v_dept_code) loop
        dbms_output.put_line(erow.emp_id || '   ' || erow.emp_name || '    ' || erow.dept_code);
   end loop;
end;
/

-- 사용자에게 부서명을 입력받고 해당 부서원을 모두 조회하는 proc_print_emp_by_dept 작성
-- 익명블럭에서 호출 proc_print_emp_by_dept('총무부');
-- 사번 사원명 부서명

-- 프로시저 선언
create or replace procedure proc_print_emp_by_dept(
    p_emp_dept department.dept_title%type
)
is
    cursor cs_emp_by_deptname(p_dept_name department.dept_title%type)
    is
    select *
    from employee join department
         on dept_code = dept_id
    where
       dept_title = p_emp_dept;
begin
    dbms_output.put_line('사번  사원명    부서명');
    dbms_output.put_line('====================================');
    
    for erow in cs_emp_by_deptname(p_emp_dept) loop
        dbms_output.put_line(erow.emp_id || '  ' || erow.emp_name || '    ' || erow.dept_title);
    end loop;
       
end;
/
-- 강사님 풀이
create or replace procedure proc_print_emp_by_dept(
    p_dept_title department.dept_title%type
)
is
    cursor cs_emp_by_dept(pc_dept_title department.dept_title%type)
    is
    select
        e.emp_id, e.emp_name, d.dept_title
    from
        employee e left join department d
            on e.dept_code = d.dept_id
    where
        d.dept_title = pc_dept_title;
begin

    for erow in cs_emp_by_dept(p_dept_title) loop
        dbms_output.put_line(erow.emp_id || '   ' || erow.emp_name || '     ' || erow.dept_title);
    end loop;

end;
/

begin
    proc_print_emp_by_dept('&부서명');
end;
/


-------------------------------------------------------
-- TRIGGER
-------------------------------------------------------
-- 의미 : 연쇄반응, 방아쇠
-- 특정 이벤트, DDL, DML 등이 실행되었을 때 자동적으로 특정 처리가 일어나게 하는 객체

-- 종료
-- 1. Logon/Logoff Trigger
-- 2. DDL Trigger
-- 3. DML Trigger - inser/update/delete구문이 실행되었을 때 트리거의 내용을 실행

-- 예시)
-- 회원탈퇴시 탈퇴회원테이블에 자동으로 추가
-- 프로필변경 시, 변경내역을 로그테이블에 추가

/*
    create [or replace] trigger 트리거명
        before | after
        insert or update or delete on 테이블명
        [for each row]
    declare
        -- 지역변수 선언
    begin
        -- 실행코드
    end;
    /
    
    - before | after : 원DML의 실행전/후 트리거 설정
    - for each row
        - 생략시 문장레벨 트리거 : 원DML문 당 1번 실행
        - 작성시 행레벨 트리거 : 처리되는 레코드 당 1번 실행
    
    - 행레벨 트리거 시 의사레코드(pseudo record)
                DML실행전      DML실행후
    --------------------------------------
    insert      null          :new.컬럼명
    update      :old.컬럼명    :new.컬럼명
    delete      :old.컬럼명    null
*/


create table tb_user(
    no number,
    name varchar2(100) not null,
    constraint pk_tb_user_no primary key(no)
);
-- drop table tb_user;

create sequence seq_tb_user_no;
-- drop sequence seq_tb_user_no;

create table tb_user_log(
    no number,
    log varchar2(4000) not null,
    log_date date default sysdate,
    constraint pk_tb_user_log_no primary key(no)
);
-- drop table tb_user_log;

create sequence seq_tb_user_log_no;
-- drop sequence seq_tb_user_log_no;

-- tb_user에 insert/update/delete할때마다 tb_user_log에 insert
-- trigger
create or replace trigger trig_tb_user_log
    before
    insert or update or delete on tb_user
    for each row
begin
    -- 상태를 나타내는 boolean형 키워드
    -- inserting : insert시 true
    -- updating, updating('컬럼명') : 컬럼을 수정하면 true
    -- deleting : delete시 true
    
    if inserting then
        insert into 
            tb_user_log(no, log)
        values(
            seq_tb_user_log_no.nextval,
            :new.no || '번 ' || :new.name || '님이 회원가입했습니다.'
        );
    elsif updating then
        insert into
            tb_user_log(no, log)
        values(
            seq_tb_user_log_no.nextval,
            :new.no || '번 회원이 ' || :old.name || '에서 ' || :new.name || '으로 이름변경했습니다.'
        );
    elsif deleting then
        insert into
            tb_user_log(no, log)
        values(
            seq_tb_user_log_no.nextval,
            :old.no || '번 ' || :old.name || '님이 탈퇴했습니다.'
        );
    end if;
    
    -- 트랜잭션처리 하지 않는다.
    -- 트리거의 트랜잭션은 원 DML문에 따라 commit또는 rollback처리
end;
/

-- 원 DML 실행
insert into 
    tb_user
values(
    seq_tb_user_no.nextval,
    '홍길동'
);

update
    tb_user
set
    name = '고길동'
where
    no = 2;

delete from tb_user
where no = 2;

rollback;
commit;

select * from tb_user;
select * from tb_user_log;


-- 트리거를 이용한 재고관리
-- 상품테이블(재고)
-- 입출고테이블
create table tb_product(
    pcode varchar2(20),
    pname varchar2(50),
    price number,
    stock number default 0,
    constraint pk_tb_product primary key(pcode),
    constraint ck_tb_product check(stock >= 0)
);

create table tb_product_io(
    no number,
    pcode varchar2(20),
    status char(1), -- 입고 I, 출고 O
    amount number,
    io_date date default sysdate,
    constraint pk_tb_product_io_no primary key(no),
    constraint fk_tb_product_io_pcode 
        foreign key(pcode) references tb_product(pcode)
);

create sequence seq_tb_product_io_no;

-- 상품데이터
insert into tb_product
values(
    'apple_iphone_X', '아이폰X', 1000000, default
);
insert into tb_product
values(
    'samsung_galaxy_20', '갤럭시20', 1500000, default
);

-- 트리거 생성
create or replace trigger trig_tb_product_stock
    before
    insert on tb_product_io
    for each row
begin
    if :new.status = 'I' then
    -- 입고 시 +amount
        update 
            tb_product
        set
            stock = stock + :new.amount
        where
            pcode = :new.pcode;
    else
    -- 출고 시 -amount
        update 
            tb_product
        set
            stock = stock - :new.amount
        where
            pcode = :new.pcode;
    end if;
end;
/

select * from tb_product;
select * from tb_product_io;

-- 입출고데이터
insert into tb_product_io values(
    seq_tb_product_io_no.nextval, 'apple_iphone_X', 'I', 10, default
);
insert into tb_product_io values(
    seq_tb_product_io_no.nextval, 'apple_iphone_X', 'O', 3, default
);

