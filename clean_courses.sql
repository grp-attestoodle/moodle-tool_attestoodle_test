-- Script de nettoyage de cours de production
-- pour protéger la propriété intellectuelle
-- et les rendre intéressants pour Attestoodle
--

-- Date d'achèvement attendu ---------------------------------------------------------
-- date aléatoirement répartie sur une année univesitaire :
update mdl_course_modules 
set completionexpected = unix_timestamp(DATE_ADD('2019-09-01', INTERVAL rand()*300 day))
where completion > 0
;

-- Suppression de quelques dates (pour plus de vraisemblance)
update mdl_course_modules
set completionexpected = 0
where id % 9 = 0
;

-- Nettoyage cours ---------------------------------------------------
update mdl_course 
set summary = ''
;

-- Nettoyage sections ---------------------------------------------------
update mdl_course_sections
set name = '', 
	summary = '';

-- Nettoyage modules dans les cours -------------------------------------
-- Connaitre les types de modules à traiter
select cm.module, m.name, count(*) as nbre
from mdl_course_modules cm
	join mdl_modules m on m.id = cm.module
group by cm.module, m.name;

-- Labels
update mdl_label 
set name = 'Un label, bla bla bla...',
	intro = '<p>Un label, bla bla bla...</p>';

-- Devoirs 
update mdl_assign 
set name = concat('Devoir n°', id), 
	intro = '<h2>Un devoir à rendre...</h2>';

update mdl_assignfeedback_comments 
set commenttext = '<p>Un feedback quelconque...</p>';

update mdl_assignsubmission_onlinetext 
set onlinetext = '';

-- quiz
update mdl_quiz 
set name = concat('Exercice n°', id), 
	intro = '';

update mdl_quiz_feedback 
set feedbacktext = '';
	
update mdl_question 
set questiontext = '<p>Une question quelconque...</p>',
	name = concat('Question n°', id),
	generalfeedback = '';
	
update mdl_question_answers 
set answer = 'Une réponse quelconque...';

update mdl_question_categories 
set name = concat('Banque n°', id),
	info = '';

update mdl_question_attempts 
set questionsummary = 'Résumé de la question',
	rightanswer = 'Une réponse correcte...', 
	responsesummary = '';

update mdl_qtype_match_subquestions 
set answertext = '', questiontext = '';


-- bbb 
update mdl_bigbluebuttonbn
set name = concat('Webconf n°', id), 
	intro = '';

-- chat 
update mdl_chat
set name = concat('Chat n°', id), 
	intro = '';

update mdl_chat_messages 
set message = '<p>Un message quelconque</p>';

-- choice 
update mdl_choice 
set name = concat('Choix n°', id), 
	intro = '';

update mdl_choice_options 
set `text` = concat('Choix n°', id);

-- forum 
update mdl_forum 
set name = concat('Forum n°', id), 
	intro = '';

update mdl_forum_posts 
set message = '<p>Un message quelconque</p>',
	subject = 'Un sujet quelconque';

update mdl_forum_discussions 
set name = 'Un sujet quelconque';

-- page 
update mdl_page 
set name = concat('Page n°', id), 
	intro = '',
	content = '<p>Un contenu quelconque</p>'; 

-- resource 
update mdl_resource 
set name = concat('Resource n°', id), 
	intro = '';

-- url 
update mdl_url
set name = concat('Url n°', id), 
	intro = '',
	externalurl = 'https://attestoodle.univ-lemans.fr/';
