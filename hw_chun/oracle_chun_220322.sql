-- ====================================================
-- 실습문제 chun 계정
-- ====================================================

select * from tb_department; -- 학과
select * from tb_student; -- 학생
    -- (tb_department.department_no = tb_student.department_no)
    -- (tb_professor.professor_no = tb_student.coach_professor_no)
select * from tb_professor; -- 교수
    -- (tb_department.department_no = tb_professor.department_no)
select * from tb_class; -- 수업
    -- (tb_department.department_no = tb_class.department_no)
select * from tb_class_professor; -- 수업-교수
    -- (tb_class.class_no = tb_class_professor.class_no)
    -- (tb_professor.professor_no = tb_class_professor.professor_no)
select * from tb_grade; -- 학점
    -- (tb_student.student_no = tb_grade.student_no)
    -- (tb_class.class_no = tb_grade.class_no)

-------------------------------------------------------

-------------------------------------------------------
-- 220322
-------------------------------------------------------
-- #1번
-- 영어영문학과(학과코드 002) 학생들의 학번과 이름, 입학 년도를
-- 입학 년도가 빠른 순으로 표시하는 SQL 문장을 작성하시오.
--( 단, 헤더는 "학번", "이름", "입학년도" 가 표시되도록 한다.)
select
    student_no 학번,
    student_name 이름,
    to_char(entrance_date, 'yyyy-mm-dd') 입학년도
from tb_student
where department_no = 002
order by entrance_date ;



-- #2번
-- 춘 기술대학교의 교수 중 이름이 세 글자가 아닌 교수가 한 명 있다고 한다.
-- 그 교수의 이름과 주민번호를 화면에 출력하는 SQL 문장을 작성해 보자.
-- (* 이때 올바르게 작성한 SQL문장의 결과 값이 예상과 다르게 나올 수 있다. 원인이 무엇일지 생각해볼 것)
select
    professor_name,
    professor_ssn
from tb_professor
where professor_name not like '___' ;



-- #3번
-- 춘 기술대학교의 남자 교수들의 이름과 나이를 출력하는 SQL 문장을 작성하시오.
-- 단 이때 나이가 적은 사람에서 많은 사람 순서로 화면에 출력되도록 만드시오.
-- (단, 교수 중 2000 년 이후 출생자는 없으며 출력 헤더는 "교수이름", "나이"로 한다.
-- 나이는 ‘만’으로 계산한다.)
select
    professor_name 교수이름,
    trunc((sysdate - to_date(('19' || (substr(professor_ssn, 1, 6))),'yyyymmdd'))/365) 나이
from tb_professor
order by 2 ;



-- #4번
-- 교수들의 이름 중 성을 제외한 이름만 출력하는 SQL 문장을 작성하시오.
-- 출력 헤더는 "이름" 이 찍히도록 한다. (성이 2 자인 경우는 교수는 없다고 가정하시오)
select
    substr(professor_name, 2) 이름
from tb_professor ;



-- #5번
-- 춘 기술대학교의 재수생 입학자를 구하려고 한다.
-- 어떻게 찾아낼 것인가? 이때, 19 살에 입학하면 재수를 하지 않은 것으로 간주한다.
select to_char(entrance_date,'yyyymmdd')
from tb_student;

select
    student_no,
    student_name
from tb_student
where
    (extract(year from entrance_date) -
        extract(year from to_date('19' || substr(student_ssn, 1, 6), 'yyyymmdd'))) > 19 ;



-- #6번
-- 2020 년 크리스마스는 무슨 요일인가?
select
    to_char(to_date('2020/12/25'), 'day')
from dual;



-- #7번
-- TO_DATE('99/10/11','YY/MM/DD'), TO_DATE('49/10/11','YY/MM/DD') 은 각각 몇 년 몇 월 몇 일을 의미할까?
-- 또 TO_DATE('99/10/11','RR/MM/DD'), TO_DATE('49/10/11','RR/MM/DD') 은 각각 몇 년 몇 월 몇 일을 의미할까?
select
    to_char(TO_DATE('99/10/11','YY/MM/DD'),'yyyy-mm-dd') "1",
    to_char(TO_DATE('49/10/11','YY/MM/DD'),'yyyy-mm-dd') "2",
    to_char(TO_DATE('99/10/11','RR/MM/DD'),'yyyy-mm-dd') "3",
    to_char(TO_DATE('49/10/11','RR/MM/DD'),'yyyy-mm-dd') "4"
from dual;



-- #8번
-- 춘 기술대학교의 2000 년도 이후 입학자들은 학번이 A 로 시작하게 되어있다.
-- 2000 년도 이전 학번을 받은 학생들의 학번과 이름을 보여주는 SQL 문장을 작성하시오.
select
    student_no,
    student_name
from tb_student
where student_no not like 'A%' ;



-- #9번
-- 학번이 A517178 인 한아름 학생의 학점 총 평점을 구하는 SQL 문을 작성하시오.
-- 단, 이때 출력 화면의 헤더는 "평점" 이라고 찍히게 하고, 점수는 반올림하여 소수점 이하 한 자리까지만 표시한다.
select round(avg(point), 1) 평점
from tb_grade
where student_no = 'A517178' ;


-- #10번
-- 학과별 학생수를 구하여 "학과번호", "학생수(명)" 의 형태로 헤더를 만들어 결과값이 출력되도록 하시오.
select
    department_no 학과번호,
    count(*) "학생수(명)"
from tb_student
group by department_no
order by department_no ;



-- #11번
-- 지도 교수를 배정받지 못한 학생의 수는 몇 명 정도 되는 알아내는 SQL 문을 작성하시오
select count(*)
from tb_student
where coach_professor_no is null ;



-- #12번
-- 학번이 A112113 인 김고운 학생의 년도 별 평점을 구하는 SQL 문을 작성하시오.
-- 단, 이때 출력 화면의 헤더는 "년도", "년도 별 평점" 이라고 찍히게 하고,
-- 점수는 반올림하여 소수점 이하 한 자리까지만 표시한다.
select
    term_year 년도,
    round(avg(point), 1) "년도 별 평점"
from (
    select g.*, substr(term_no, 1, 4) term_year
    from tb_grade g
    where g.student_no = 'A112113'
) t
group by term_year 
order by 1;


-- #13번
-- 학과 별 휴학생 수를 파악하고자 한다. 학과 번호와 휴학생 수를 표시하는 SQL 문장을 작성하시오.
select 
    s.department_no 학과코드명,
    (
        select count(*) 
        from tb_student
        where 
            absence_yn = 'Y' 
            and s.department_no = department_no) "휴학생 수"
from tb_student s
group by s.department_no
order by s.department_no ;



-- #14번
-- 춘 대학교에 다니는 동명이인(同名異人) 학생들의 이름을 찾고자 한다.
-- 어떤 SQL 문장을 사용하면 가능하겠는가?
select
    student_name 동일이름,
    same_name "동명이인 수"
from (
    select student_name, count(*) same_name
    from tb_student
    group by student_name
)
where same_name != 1
order by 1 ;



-- #15번
-- 학번이 A112113 인 김고운 학생의 년도, 학기 별 평점과 년도 별 누적 평점 , 총 평점을 구하는 SQL 문을 작성하시오.
-- (단, 평점은 소수점 1 자리까지만 반올림하여 표시한다.)
select *
from tb_grade g
where student_no = 'A112113'
;

select
    decode(grouping(g.term_year), 0, g.term_year, 1, ' ') 년도,
    decode(grouping(g.term_no), 0, substr(g.term_no, 5, 2), 1, ' ') 학기,
    round(avg(point),1) 평점
from (
    select t.*, substr(t.term_no, 1, 4) term_year
    from tb_grade t
    where student_no = 'A112113'
) g
group by
    rollup(g.term_year, g.term_no) ;