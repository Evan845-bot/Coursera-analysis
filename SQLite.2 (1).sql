-- Let's clean up the ccourse_students_enrolled column. It contains values such as '480k' rather than '480000'. 
UPDATE UCoursera_Courses1
SET course_students_enrolled = CASE WHEN
  		course_students_enrolled LIKE '%k%' THEN 
    CAST((REPLACE(REPLACE(course_students_enrolled, 'k', '000'), '.', '')) AS INT)
    ELSE CAST(REPLACE(REPLACE(course_students_enrolled, 'm', '000000'), '.', '') AS INT)
  	END 
    
 -- What are the top ten trending courses on Coursera? 
 SELECT
 	course_title
    FROM (
      SELECT
      	course_title,
      	SUM(course_students_enrolled),
      	DENSE_RANK() OVER (ORDER BY SUM(course_students_enrolled) DESC) AS rank
      FROM UCoursera_Courses1
      GROUP BY course_title
      ) x
      WHERE x.rank <= 10
      
 -- Is there a relationship between course difficulty and enrollment? Are students inclined to take easier courses or harder courses?
 SELECT
 	course_difficulty,
    ROUND(AVG(course_students_enrolled),0) AS avg_students,
    ROUND(AVG(course_rating),2) AS avg_rating
    FROM UCoursera_Courses1
    GROUP BY course_difficulty
    ORDER BY AVG(course_students_enrolled) DESC
      
 -- Which organizations have the highest average course student enrollment and highest average course rating? (reputable organizations)
  SELECT course_organization
 	FROM (SELECT
      	course_organization,
      	AVG(course_rating) AS avg_rating,
      	AVG(course_students_enrolled) AS avg_student_num,
        ROW_NUMBER() OVER (ORDER BY AVG(course_rating) DESC) AS rank
      FROM UCoursera_Courses1
      GROUP BY course_title
      ) x
      WHERE rank <= 20
     
     SELECT * 
     FROM UCoursera_Courses1
     WHERE course_organization = 'Imperial College London'
     
 -- How does the course enrollment and rating vary for courses offered by universities compared to courses offered by other organizations
  SELECT
  	CASE WHEN course_organization LIKE '%University%' OR '%College%' THEN 'Educational Institution'
    ELSE 'Other'
    END as organization_type,
    ROUND(AVG(course_rating), 4) AS avg_rating,
    ROUND(AVG(course_students_enrolled), 0) AS avg_num_of_students
    FROM UCoursera_Courses1
    GROUP BY organization_type
    
  
 -- Are courses offered by educational institutions easier? 
 
 SELECT
  	CASE WHEN course_organization LIKE '%University%' OR '%College%' THEN 'Educational Institution'
    ELSE 'Not Educational Institution'
    END as organization_type,
    ROUND(SUM(CASE WHEN course_difficulty = 'Beginner' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS beginner_percentage
    FROM UCoursera_Courses1
    GROUP BY organization_type
    
    -- What is the distribution of certificate types for educational institutions vs others?
  SELECT
  	CASE WHEN course_organization LIKE '%University%' OR '%College%' THEN 'Educational Institution'
    ELSE 'Other'
    END as organization_type,
    ROUND(SUM(CASE WHEN course_certificate_type = 'COURSE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS course_percentage,
    ROUND(SUM(CASE WHEN course_certificate_type = 'SPECIALIZATION' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS specialization_percentage,
    ROUND(SUM(CASE WHEN course_certificate_type = 'PROFESSIONAL CERTIFICATE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS professional_certificate_percentage
    FROM UCoursera_Courses1
    GROUP BY organization_type
    
    -- Which course certificate types are the hardest? What about the easiest?
    
    SELECT
    	course_certificate_type,
        ROUND(SUM(CASE WHEN course_difficulty = 'Beginner' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),1) AS beginner_percentage,
        ROUND(SUM(CASE WHEN course_difficulty = 'Mixed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),1) AS medium_percentage,
        ROUND(SUM(CASE WHEN course_difficulty = 'Intermediate' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),1) AS intermediate_percentage,
        ROUND(SUM(CASE WHEN course_difficulty = 'Advanced' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),1) AS advanced_percentage
        FROM UCoursera_Courses1
        GROUP BY course_certificate_type
    
    
    

 
      

 -- What percentage of courses offered by organizations/universities are "beginner", 'mixed' (medium), 'intermediate' or 'advanced'?
 SELECT
 	course_organization,
    ROUND(SUM(CASE WHEN course_difficulty = 'Beginner' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS beginner_percentage
    ROUND(SUM(CASE WHEN course_difficulty = 'Mixed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS medium_percentage
    ROUND(SUM(CASE WHEN course_difficulty = 'Intermediate' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS intermediate_percentage,2),
    AVG(course_students_enrolled)
FROM UCoursera_Courses1
GROUP BY course_organization
ORDER BY avg_students DESC

SELECT *
FROM UCoursera_Courses1