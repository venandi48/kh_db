
-- ====================================================
-- 1. 다중열 서브쿼리
-- 2. 220317 과제 JOIN문제 oracle 문법으로 변환
-- ====================================================
-------------------------------------------------------
-- 1. 다중열 서브쿼리
-------------------------------------------------------

-- #1번
-- 부서별 최대급여를 받는 사원의 사원명, 부서명, 급여를 출력. 
select
    e.emp_name 사원명,
    d.dept_title 부서명,
    to_char(salary, 'fm999,999,999') 급여
from employee e
    join department d
        on e.dept_code = d.dept_id
where
    salary in (
        select
            max(salary)
        from employee
        group by dept_code
        );

-- 강사님 답안
select emp_name, dept_title, salary
from
    employee left join department
        on dept_code = dept_id
where
    (dept_code, salary) in (
                    select
                        dept_code, max(salary) 
                    from employee
                    group by dept_code)
order by 2,1;


-- #심화1
-- 최소급여를 받는 사원도 출력.
select
    e.emp_name 사원명,
    d.dept_title 부서명,
    to_char(salary, 'fm999,999,999') 급여
from employee e
    join department d
        on e.dept_code = d.dept_id
where
    (dept_code, salary) in (
            select dept_code, max(salary) from employee group by dept_code
            union
            select dept_code, min(salary) from employee group by dept_code
        );
-- 풀이2
--where
--    salary in (select max(salary) from employee group by dept_code)
--    or salary in (select min(salary) from employee group by dept_code);

-- 강사님 답안
select emp_name, dept_title, salary
from employee left join department on dept_code = dept_id
where (dept_code, salary) in (select dept_code, max(salary) 
                        from employee
                        group by dept_code)
    or (dept_code, salary) in (select dept_code, min(salary) 
                        from employee
                        group by dept_code)
order by 2,1;


-- #심화2
-- 인턴사원도 포함시키기
select
    e.emp_name 사원명,
    nvl(d.dept_title, '인턴') 부서명,
    to_char(salary, 'fm999,999,999') 급여
from employee e
    left join department d
        on e.dept_code = d.dept_id
where
    (nvl(dept_code,'D0'), salary) in (
            select nvl(dept_code, 'D0'), max(salary) from employee group by dept_code
            union
            select nvl(dept_code, 'D0'), min(salary) from employee group by dept_code
        );


-------------------------------------------------------
-- 2. 220317 과제 JOIN문제 oracle 문법으로 변환
-------------------------------------------------------

-- #2번
-- 주민번호가 70년대 생이면서 성별이 여자이고, 성이 전씨인 직원들의 
-- 사원명, 주민번호, 부서명, 직급명을 조회하시오.
select
    emp_name 사원명, emp_no 주민번호, dept_title 부서명, job_name 직급명
from
    employee e, department d, job j
where
    e.dept_code = d.dept_id(+)
    and e.job_code = j.job_code
    and substr(emp_no, 1, 1) = 7
    and substr(emp_no, 8, 1) = 2
    and emp_name like '전%';


-- #3번
-- 가장 나이가 적은 직원의 사번, 사원명, 나이, 부서명, 직급명을 조회하시오.
select
    emp_id 사번,
    emp_name 사원명, 
    extract(year from sysdate) -
        (decode(substr(emp_no,8,1),'1',1900,'2',1900,2000)) - substr(emp_no,1,2) + 1 나이,
    d.dept_title 부서명,
    j.job_name 직급명
from
    employee e,
    department d,
    job j,
    (
        select 
            min(extract(year from sysdate) -
            (decode(substr(emp_no,8,1),'1',1900,'2',1900,2000)) - substr(emp_no,1,2) + 1) min_age
        from employee
    ) tb_min_age
where
    e.dept_code = d.dept_id(+)
    and e.job_code = j.job_code
    and tb_min_age.min_age
        = extract(year from sysdate) -
        (decode(substr(emp_no,8,1),'1',1900,'2',1900,2000)) - substr(emp_no,1,2) + 1;


-- #4번
-- 이름에 '형'자가 들어가는 직원들의 사번, 사원명, 부서명을 조회하시오.
select
    e.emp_id 사번, e.emp_name 사원명, d.dept_title 부서명
from employee e, department d
where
    e.dept_code = d.dept_id(+)
    and e.emp_name like '%형%';


-- #5번
-- 해외영업팀에 근무하는 사원명, 직급명, 부서코드, 부서명을 조회하시오.
select
    e.emp_name 사원명, j.job_name 직급명, d.dept_id 부서코드, d.dept_title 부서명
from
    employee e, job j, department d
where 
    e.job_code = j.job_code
    and e.dept_code = d.dept_id(+)
    and d.dept_title like '해외영업%';


-- #6번
-- 보너스포인트를 받는 직원들의 사원명, 보너스포인트, 부서명, 근무지역명을 조회하시오.
select
    e.emp_name 사원명,
    e.bonus 보너스포인트,
    nvl(d.dept_title, ' - ') 부서명,
    nvl(l.local_name, ' - ') 근무지역명
from
    employee e, department d, location l
where 
    e.dept_code = d.dept_id(+)
    and d.location_id = l.local_code(+)
    and e.bonus is not null;


-- #7번
-- 부서코드가 D2인 직원들의 사원명, 직급명, 부서명, 근무지역명을 조회하시오.
select
    e.emp_name 사원명,
    j.job_name 직급명,
    d.dept_title 부서명,
    l.local_name 근무지역명
from
    employee e, job j, department d, location l
where
    e.job_code = j.job_code
    and e.dept_code = d.dept_id
    and d.location_id = l.local_code
    and e.dept_code = 'D2';


-- #8번
-- 급여등급테이블의 등급별 최대급여(MAX_SAL)보다 많이 받는 직원들의 사원명, 직급명, 급여, 연봉을 조회하시오.
-- (사원테이블과 급여등급테이블을 SAL_LEVEL컬럼기준으로 동등 조인할 것)
select
    e.emp_name 사원명,
    j.job_name 직급명,
    to_char(e.salary, 'fml999,999,999') 급여,
    to_char((e.salary + (e.salary * nvl(e.bonus, 0))) * 12, 'fml999,999,999') 연봉
from
    employee e, job j, sal_grade s
where
    e.job_code = j.job_code
    and s.sal_level = e.sal_level
    and e.salary > s.max_sal;


-- #9번
-- 한국(KO)과 일본(JP)에 근무하는 직원들의 
-- 사원명, 부서명, 지역명, 국가명을 조회하시오.
select
    e.emp_name 사원명, d.dept_title 부서명, l.local_name 지역명, n.national_name 국가명
from
    employee e, department d, location l, nation n
where 
    e.dept_code = d.dept_id(+)
    and d.location_id = l.local_code(+)
    and l.national_code = n.national_code(+)
    and l.national_code in ('KO', 'JP');


-- #10번
-- 같은 부서에 근무하는 직원들의 사원명, 부서코드, 동료이름을 조회하시오.
-- self join 사용
select 
    e.emp_name 사원명, e.dept_code 부서코드, co_e.emp_name 동료이름
from
    employee e, employee co_e, department d
where
    e.dept_code = co_e.dept_code
    and e.dept_code = d.dept_id(+)
    and e.emp_name != co_e.emp_name
order by e.emp_name;


-- #11번
-- 보너스포인트가 없는 직원들 중에서 직급이 차장과 사원인 직원들의 사원명, 직급명, 급여를 조회하시오.
select
    e.emp_name 사원명,
    j.job_name 직급명,
    to_char(e.salary, 'fml999,999,999') 급여
from employee e, job j
where
    e.job_code = j.job_code
    and e.bonus is null and j.job_name in ('차장', '사원');


-- #12번
-- 재직중인 직원과 퇴사한 직원의 수를 조회하시오.
select
    decode(quit_yn,'N','재직자','퇴사자') 재직여부,
    count(*) 인원수
from employee
group by quit_yn;