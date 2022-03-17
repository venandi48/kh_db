-- ==================================================
-- #1번
-- ==================================================
/*
1. 직원명과 이메일 , 이메일 길이를 출력하시오
          이름        이메일        이메일길이
    ex)     홍길동 , hong@kh.or.kr         13
*/
select
    emp_name 이름,
    email 이메일,
    length(email) 이메일길이
from employee;


-- ==================================================
-- #2번
-- ==================================================
/*
2. 직원의 이름과 이메일 주소중 아이디 부분만 출력하시오
    ex) 노옹철    no_hc
    ex) 정중하    jung_jh
*/
select
    emp_name 이름,
    substr(email, 1, instr(email, '@')-1) "이메일 아이디"
from employee;

-- ==================================================
-- #3번
-- ==================================================
/*
3. 60년대에 태어난 직원명과 년생, 보너스 값을 출력하시오 
    그때 보너스 값이 null인 경우에는 0 이라고 출력 되게 만드시오
        직원명    년생      보너스
    ex) 선동일    1962    0.3
    ex) 송은희    1963      0
*/
select
    emp_name 직원명,
    substr(emp_no, 1, 2) + 1900 생년,
--    extract(year from to_date(substr(emp_no,1,2),'rr')) as 년생, --강사님 답안
    nvl(bonus, 0) 보너스
from employee
where substr(emp_no, 1, 1) = '6';


-- ==================================================
-- #4번
-- ==================================================
/*
4. '010' 핸드폰 번호를 쓰지 않는 사람의 수를 출력하시오 (뒤에 단위는 명을 붙이시오)
       인원
    ex) 3명
*/
select count(*) || '명' "인원"
from employee
--where not phone like '010%'; -- 강사님 답안
where substr(phone, 1, 3) != '010';

-- ==================================================
-- #5번
-- ==================================================
/*
5. 직원명과 입사년월을 출력하시오 
    단, 아래와 같이 출력되도록 만들어 보시오
        직원명        입사년월
    ex) 전형돈        2012년12월
    ex) 전지연        1997년 3월
*/
desc employee;
select
    emp_name 직원명,
    to_char(hire_date, 'yyyy"년"mm"월"') 입사년월
from employee;


-- ==================================================
-- #6번
-- ==================================================
/*
6. 직원명과 주민번호를 조회하시오
    단, 주민번호 9번째 자리부터 끝까지는 '*' 문자로 채워서출력 하시오
    ex) 홍길동 771120-1******
*/
select
    emp_name 직원명,
    rpad(substr(emp_no, 1, 8), 14, '*') 주민번호
from employee;


-- ==================================================
-- #7번
-- ==================================================
/*
7. 직원명, 직급코드, 연봉(원) 조회
  단, 연봉은 ￦57,000,000 으로 표시되게 함
     연봉은 보너스포인트가 적용된 1년치 급여임
*/
select
    emp_name 직원명,
    job_code 직급코드,
    to_char(salary + (salary * nvl(bonus, 0)) * 12, 'fml999,999,999')
from employee;


-- ==================================================
-- #8번
-- ==================================================
/*
8. 부서코드가 D5, D9인 직원들 중에서 2004년도에 입사한 직원중에 조회함.
   사번 사원명 부서코드 입사일
*/
select
    emp_id 사번,
    emp_name 사원명,
    dept_code 부서코드,
    hire_date 입사일
from employee
where
    dept_code in ('D5', 'D9') and substr(hire_date, 1, 2) = '04';


-- ==================================================
-- #9번
-- ==================================================
/*
9. 직원명, 입사일, 오늘까지의 근무일수 조회 
    * 주말도 포함 , 소수점 아래는 버림
*/
select
    emp_name 직원명,
    hire_date 입사일,
    quit_date, -- 강사님 답안
    trunc(nvl(quit_date, sysdate) - hire_date) as 근무일수 -- 강사님 답안
--    , trunc(sysdate - hire_date) 근무일수
from employee;


-- ==================================================
-- #10번
-- ==================================================
/*
10. 직원명, 부서코드, 생년월일, 만나이 조회
   단, 생년월일은 주민번호에서 추출해서, 
   ㅇㅇㅇㅇ년 ㅇㅇ월 ㅇㅇ일로 출력되게 함.
   나이는 주민번호에서 추출해서 날짜데이터로 변환한 다음, 계산함
*/
select
    emp_name 직원명,
    dept_code 부서코드,
    to_char(to_date
        (decode(substr(emp_no, 8, 1), '1', 1900, '2', 1900, 2000) + substr(emp_no, 1, 2) || substr(emp_no, 3, 4)
    ,'yyyymmdd'), 'yyyy"년" mm"월" dd"일"') 생년월일,
    trunc((sysdate -
        to_date(decode(substr(emp_no, 8, 1), '1', 1900, '2', 1900, 2000) + substr(emp_no, 1, 2) || substr(emp_no, 3, 4),'yyyymmdd')
    )/365) 만나이
from employee;

-- 한국나이 : 현재년도 - 출생년도 + 1
-- 만나이 : 생일기준 + 1
-- to_date(yyyymmdd) 일 경우 포맷생략가능
select
    emp_name 직원명,
    dept_code 부서코드,
    to_char(to_date
        (decode(substr(emp_no, 8, 1), '1', 1900, '2', 1900, 2000) + substr(emp_no, 1, 2) || substr(emp_no, 3, 4)
    ,'yyyymmdd'), 'yyyy"년" mm"월" dd"일"') 생년월일,
    (extract(year from sysdate)) - (decode(substr(emp_no, 8, 1), '1', 1900, '2', 1900, 2000) + substr(emp_no, 1, 2)) + 1 한국나이,
    trunc((sysdate -
        to_date(decode(substr(emp_no, 8, 1), '1', 1900, '2', 1900, 2000) + substr(emp_no, 1, 2) || substr(emp_no, 3, 4),'yyyymmdd')
    )/365) 만나이
    -- 강사님 답안 방법2
--    trunc(months_between(sysdate, to_date((decode(substr(emp_no,8,1),'1',1900,'2',1900,2000)+substr(emp_no,1,2)) || substr(emp_no,3,4)))/12) 나이
from employee;


-- ==================================================
-- #11번
-- ==================================================
/*
11. 직원들의 입사일로 부터 년도만 가지고, 각 년도별 입사인원수를 구하시오.
  아래의 년도에 입사한 인원수를 조회하시오. 마지막으로 전체직원수도 구하시오
  => decode, sum 사용

    -------------------------------------------------------------------------
     1998년   1999년   2000년   2001년   2002년   2003년   2004년  전체직원수
    -------------------------------------------------------------------------
*/
select
--    sum(decode(extract(year from hire_date),1998,1)) as "1998년" -- 강사님 답안
--    count(decode(extract(year from hire_date),1998,100)) as "1998년" -- 강사님 답안, count도 가능
    nvl(sum(decode(substr(hire_date, 1, 2), '98', 1)), 0) "1998년",
    nvl(sum(decode(substr(hire_date, 1, 2), '99', 1)),0) "1999년",
    nvl(sum(decode(substr(hire_date, 1, 2), '00', 1)), 0) "2000년",
    nvl(sum(decode(substr(hire_date, 1, 2), '01', 1)), 0) "2001년",
    nvl(sum(decode(substr(hire_date, 1, 2), '02', 1)), 0) "1002년",
    nvl(sum(decode(substr(hire_date, 1, 2), '03', 1)), 0) "2003년",
    nvl(sum(decode(substr(hire_date, 1, 2), '04', 1)), 0) "2004년",
    count(*) 전체직원수
from employee
where quit_yn = 'N'; -- 강사님 답안

select
    extract(year from hire_date) 입사년도,
    count(*) 인원수
from employee
where quit_yn = 'N'
group by extract(year from hire_date)
having extract(year from hire_date) in (1998, 1999, 2000, 2001, 2002, 2003, 2004)
order by 1;


-- ==================================================
-- #12번
-- ==================================================
/*
12.  부서코드가 D5이면 총무부, D6이면 기획부, D9이면 영업부로 처리하시오.(case 사용)
   단, 부서코드가 D5, D6, D9 인 직원의 정보만 조회하고, 부서코드 기준으로 오름차순 정렬함.
*/
select
    emp_name 직원명,
    dept_code 부서코드,
    case dept_code
        when 'D5' then '총무부'
        when 'D6' then '기획부'
        when 'D9' then '영업부'
    end 부서명
from employee
where dept_code in ('D5', 'D6', 'D9')
order by dept_code;


-- ==================================================
-- #group by & having
-- ==================================================
/*
manager_id컬럼은 관리자사원의 emp_id를 가리킨다.
관리하는 사원이 2명이상인 매니져의 사원아이디와 관리하는 사원수를 출력하세요.
*/
select
    manager_id "관리자 사원ID",
    count(*) "관리 사원 수"
from employee
group by manager_id
having count(manager_id) >= 2;

-- 방법2
select
    manager_id "관리자 사원ID",
    count(*) "관리 사원 수"
from employee
where manager_id is not null
group by manager_id
having count(*) >= 2;