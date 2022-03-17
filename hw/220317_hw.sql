-- #1번
-- 2020년 12월 25일이 무슨 요일인지 조회하시오.
select
    to_char(to_date(20201225), 'day')
from dual;


-- #2번
-- 주민번호가 70년대 생이면서 성별이 여자이고, 성이 전씨인 직원들의 
-- 사원명, 주민번호, 부서명, 직급명을 조회하시오.
select
    emp_name 사원명,
    emp_no 주민번호,
    dept_title 부서명,
    job_name 직급명
from
    employee e
        left join department d
            on e.dept_code = d.dept_id
        join job j
            on e.job_code = j.job_code
where
    substr(emp_no, 1, 1) = 7
    and substr(emp_no, 8, 1) = 2
    and emp_name like '전%';


-- #3번
-- 가장 나이가 적은 직원의 사번, 사원명, 나이, 부서명, 직급명을 조회하시오.
select
    emp_id 사번,
    emp_name 사원명,
    trunc((sysdate - 
        to_date(decode(substr(emp_no, 8, 1), '1', 1900, '2', 1900, 2000 ) + substr(emp_no, 1, 2)
        || substr(emp_no,3, 4),'yyyymmdd'))/365) 나이,
    d.dept_title 부서명,
    j.job_name 직급명
from
    employee e
        left join department d
            on e.dept_code = d.dept_id
        join job j
            on e.job_code = j.job_code
        cross join (
                select 
                    trunc(min(sysdate - 
                    to_date(decode(substr(emp_no, 8, 1), '1', 1900, '2', 1900, 2000 ) + substr(emp_no, 1, 2)
                    || substr(emp_no,3, 4),'yyyymmdd'))/365) min_age
                from employee
            )tb_min_age
where tb_min_age.min_age
        = trunc((sysdate - 
            to_date(decode(substr(emp_no, 8, 1), '1', 1900, '2', 1900, 2000 ) + substr(emp_no, 1, 2)
            || substr(emp_no,3, 4),'yyyymmdd'))/365);


-- #4번
-- 이름에 '형'자가 들어가는 직원들의 사번, 사원명, 부서명을 조회하시오.
select
    e.emp_id,
    e.emp_name,
    d.dept_title
from employee e left join department d
    on e.dept_code = d.dept_id
where e.emp_name like '%형%';


-- #5번
-- 해외영업팀에 근무하는 사원명, 직급명, 부서코드, 부서명을 조회하시오.
select
    e.emp_name,
    j.job_name,
    d.dept_id,
    d.dept_title
from employee e
    join job j
        on e.job_code = j.job_code
    left join department d
        on e.dept_code = d.dept_id
where d.dept_title like '해외영업_부';


-- #6번
-- 보너스포인트를 받는 직원들의 사원명, 보너스포인트, 부서명, 근무지역명을 조회하시오.
select
    e.emp_name 사원명,
    e.bonus 보너스포인트,
    nvl(d.dept_title, ' - ') 부서명,
    nvl(l.local_name, ' - ') 근무지역명
from employee e
    left join department d
        on e.dept_code = d.dept_id
    left join location l
        on d.location_id = l.local_code
where e.bonus is not null;


-- #7번
-- 부서코드가 D2인 직원들의 사원명, 직급명, 부서명, 근무지역명을 조회하시오.
select
    e.emp_name 사원명,
    j.job_name 직급명,
    d.dept_title 부서명,
    l.local_name 근무지역명
from employee e
    join job j
        on e.job_code = j.job_code
    left join department d
        on e.dept_code = d.dept_id
    left join location l
        on d.location_id = l.local_code
where e.dept_code = 'D2';
    


-- #8번
-- 급여등급테이블의 등급별 최대급여(MAX_SAL)보다 많이 받는 직원들의 사원명, 직급명, 급여, 연봉을 조회하시오.
-- (사원테이블과 급여등급테이블을 SAL_LEVEL컬럼기준으로 동등 조인할 것)
select
    e.emp_name 사원명,
    j.job_name 직급명,
    to_char(e.salary, 'fml999,999,999') 급여,
    to_char((e.salary + (e.salary * nvl(e.bonus, 0))) * 12, 'fml999,999,999') 연봉
from employee e
    join job j
        on e.job_code = j.job_code
    join sal_grade s
        on e.sal_level = s.sal_level
where e.salary > s.max_sal;


-- #9번
-- 한국(KO)과 일본(JP)에 근무하는 직원들의 
-- 사원명, 부서명, 지역명, 국가명을 조회하시오.
select
    e.emp_name 사원명,
    d.dept_title 부서명,
    l.local_name 지역명,
    n.national_name 국가명
from employee e
    left join department d
        on e.dept_code = d.dept_id
    left join location l
        on d.location_id = l.local_code
    left join nation n
        on l.national_code = n.national_code
where l.national_code in ('KO', 'JP');


-- #10번
-- 같은 부서에 근무하는 직원들의 사원명, 부서코드, 동료이름을 조회하시오.
-- self join 사용
select 
    e1.emp_name 사원명,
    e1.dept_code 부서코드,
    e2.emp_name 동료이름
from employee e1 join employee e2
    on e1.dept_code = e2.dept_code
where e1.emp_name != e2.emp_name
order by e1.dept_code, e1.emp_name;


-- #11번
-- 보너스포인트가 없는 직원들 중에서 직급이 차장과 사원인 직원들의 사원명, 직급명, 급여를 조회하시오.
select
    e.emp_name 사원명,
    j.job_name 직급명,
    to_char(e.salary, 'fml999,999,999') 급여
from employee e
    join job j
        on e.job_code = j.job_code
where e.bonus is null and j.job_name in ('차장', '사원');


-- #12번
-- 재직중인 직원과 퇴사한 직원의 수를 조회하시오.
select
    nvl(nvl2(quit_date, '재직자', '퇴사자'), '총계'),
--    grouping(nvl2(quit_date, '재직자', '퇴사자')) is_rollup,
    count(*) 인원수
from employee
group by
    rollup(nvl2(quit_date, '재직자', '퇴사자'));
